package com.alterra.canliceviri

import android.content.Context
import android.media.AudioFormat
import android.media.AudioRecord
import android.media.MediaRecorder
import android.speech.tts.TextToSpeech
import android.speech.tts.UtteranceProgressListener
import android.util.Log
import com.alterra.canliceviri.asr.WhisperModel
import com.google.android.gms.tasks.Tasks
import com.google.mlkit.nl.translate.TranslateLanguage
import com.google.mlkit.nl.translate.Translation
import com.google.mlkit.nl.translate.Translator
import com.google.mlkit.nl.translate.TranslatorOptions
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.cancel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import java.io.File
import java.net.HttpURLConnection
import java.net.URL
import java.util.Locale
import kotlin.math.sqrt

data class HuanSpeechState(
    val status: String = "Скачайте модель распознавания, чтобы начать",
    val sourceText: String = "",
    val translatedText: String = "",
    val error: String? = null,
    val recording: Boolean = false,
    val modelReady: Boolean = false,
    val downloading: Boolean = false,
    val downloadProgress: Int = 0,
    val processing: Boolean = false
)

/**
 * Локальная запись и Whisper ASR. Перевод выполняется ML Kit на устройстве после загрузки пары моделей.
 * Никакой аудиозаписи на сервер не отправляется.
 */
class HuanSpeechController(context: Context) {
    private val app = context.applicationContext
    private val scope = CoroutineScope(SupervisorJob() + Dispatchers.Main.immediate)
    private val modelFile = File(app.getExternalFilesDir("models"), "ggml-small.bin")
    private var whisper: WhisperModel? = null
    private var recorder: AudioRecord? = null
    private var recordingJob: Job? = null
    private var recordingSamples = ArrayList<Short>(16_000 * 12)
    @Volatile private var stopRequested = false
    private var tts: TextToSpeech? = null
    private var ttsReady = false

    private val _state = MutableStateFlow(HuanSpeechState(modelReady = modelFile.exists()))
    val state: StateFlow<HuanSpeechState> = _state.asStateFlow()

    init {
        tts = TextToSpeech(app) { result ->
            ttsReady = result == TextToSpeech.SUCCESS
        }
    }

    fun downloadModel() {
        if (_state.value.downloading) return
        scope.launch {
            _state.value = _state.value.copy(downloading = true, downloadProgress = 0, error = null, status = "Скачивание модели Whisper…")
            try {
                withContext(Dispatchers.IO) {
                    modelFile.parentFile?.mkdirs()
                    val part = File(modelFile.parentFile, modelFile.name + ".part")
                    val connection = (URL(MODEL_URL).openConnection() as HttpURLConnection).apply {
                        connectTimeout = 20_000
                        readTimeout = 60_000
                        instanceFollowRedirects = true
                    }
                    connection.connect()
                    if (connection.responseCode !in 200..299) error("HTTP " + connection.responseCode)
                    val total = connection.contentLengthLong
                    connection.inputStream.use { input ->
                        part.outputStream().use { output ->
                            val buffer = ByteArray(1024 * 256)
                            var count: Int
                            var received = 0L
                            while (input.read(buffer).also { count = it } >= 0) {
                                if (count == 0) continue
                                output.write(buffer, 0, count)
                                received += count
                                if (total > 0) {
                                    val progress = ((received * 100) / total).toInt().coerceIn(0, 100)
                                    scope.launch { _state.value = _state.value.copy(downloadProgress = progress) }
                                }
                            }
                        }
                    }
                    connection.disconnect()
                    if (part.length() < 400_000_000L) error("Файл Whisper неполный: загрузка прервана")
                    if (!part.renameTo(modelFile)) {
                        part.copyTo(modelFile, overwrite = true)
                        part.delete()
                    }
                }
                _state.value = _state.value.copy(downloading = false, modelReady = true, downloadProgress = 100, status = "Модель готова. Можно говорить.")
            } catch (e: Exception) {
                _state.value = _state.value.copy(downloading = false, error = e.message ?: "Не удалось скачать модель", status = "Ошибка загрузки модели")
            }
        }
    }

    fun startRecording(language: String?, autoFinishOnSilence: Boolean) {
        if (_state.value.recording || _state.value.processing || _state.value.downloading) return
        if (!modelFile.exists()) {
            _state.value = _state.value.copy(error = "Сначала скачайте модель Whisper")
            return
        }
        recordingJob = scope.launch(Dispatchers.IO) {
            try {
                _state.value = _state.value.copy(error = null, sourceText = "", translatedText = "", status = "Подготовка микрофона…")
                val model = withContext(Dispatchers.IO) {
                    whisper ?: WhisperModel.load(modelFile)?.also { whisper = it }
                } ?: error("Не удалось открыть модель Whisper")
                recordingSamples = ArrayList(16_000 * 15)
                stopRequested = false
                val minBuffer = AudioRecord.getMinBufferSize(16_000, AudioFormat.CHANNEL_IN_MONO, AudioFormat.ENCODING_PCM_16BIT)
                if (minBuffer <= 0) error("Телефон не поддерживает запись 16 кГц")
                val audio = AudioRecord(
                    MediaRecorder.AudioSource.VOICE_RECOGNITION,
                    16_000,
                    AudioFormat.CHANNEL_IN_MONO,
                    AudioFormat.ENCODING_PCM_16BIT,
                    maxOf(minBuffer * 2, 16_000)
                )
                if (audio.state != AudioRecord.STATE_INITIALIZED) {
                    audio.release()
                    error("Не удалось открыть микрофон")
                }
                recorder = audio
                audio.startRecording()
                _state.value = _state.value.copy(recording = true, status = "Говорите…")
                val buffer = ShortArray(1024)
                var voiceSeen = false
                var silentSamples = 0L
                val silenceLimit = 16_000L * 1.1
                val maxSamples = 16_000L * 25
                while (!stopRequested && recordingSamples.size < maxSamples) {
                    val n = audio.read(buffer, 0, buffer.size)
                    if (n <= 0) break
                    var power = 0.0
                    for (i in 0 until n) power += buffer[i].toDouble() * buffer[i].toDouble()
                    val rms = sqrt(power / n).toInt()
                    if (rms > 550) {
                        voiceSeen = true
                        silentSamples = 0
                    } else if (voiceSeen) {
                        silentSamples += n
                    }
                    for (i in 0 until n) recordingSamples.add(buffer[i])
                    if (autoFinishOnSilence && voiceSeen && silentSamples >= silenceLimit) break
                }
                runCatching { audio.stop() }
                audio.release()
                recorder = null
                _state.value = _state.value.copy(recording = false, processing = true, status = "Распознавание речи…")
                if (recordingSamples.size < 4_000) error("Слишком короткая запись. Попробуйте ещё раз.")
                val pcm = FloatArray(recordingSamples.size) { recordingSamples[it] / 32768f }
                val first = app.getSharedPreferences("huan_settings", Context.MODE_PRIVATE).getString("language_1", "ru") ?: "ru"
                val second = app.getSharedPreferences("huan_settings", Context.MODE_PRIVATE).getString("language_2", "zh") ?: "zh"
                val chosenLanguage = language ?: withContext(Dispatchers.Default) {
                    model.detectLanguage(pcm, listOf(first, second))?.best?.first
                } ?: first
                val result = withContext(Dispatchers.Default) {
                    model.transcribeWithRetry(pcm, chosenLanguage, threads = WhisperModel.DEFAULT_THREADS, maxTokens = 180)
                }
                if (!result.ok || result.text.isBlank()) error("Не удалось распознать речь. Попробуйте говорить ближе к микрофону.")
                _state.value = _state.value.copy(sourceText = result.text, status = "Перевод…")
                val detected = result.lang.ifBlank { chosenLanguage ?: first }
                if (detected != first && detected != second) error("Определён язык вне выбранной пары: $detected")
                val translated = translate(result.text, detected, targetFor(detected, language))
                _state.value = _state.value.copy(
                    sourceText = result.text,
                    translatedText = translated,
                    processing = false,
                    status = "Готово · ${detected.uppercase(Locale.ROOT)} → перевод"
                )
                speak(translated, targetFor(detected, language))
            } catch (e: Exception) {
                stopRecorder()
                _state.value = _state.value.copy(recording = false, processing = false, error = e.message ?: "Ошибка обработки", status = "Не удалось выполнить перевод")
            }
        }
    }

    /** Останавливает ручной режим; в автоматическом режиме запись завершается по паузе. */
    fun stopRecording() {
        stopRequested = true
        runCatching { recorder?.stop() }
    }

    private suspend fun translate(text: String, detected: String, target: String): String = withContext(Dispatchers.IO) {
        val sourceCode = toMlKitLanguage(detected)
        val targetCode = toMlKitLanguage(target)
        if (sourceCode == null || targetCode == null) error("Перевод этой языковой пары пока не поддерживается")
        if (sourceCode == targetCode) return@withContext text
        val translator: Translator = Translation.getClient(
            TranslatorOptions.Builder().setSourceLanguage(sourceCode).setTargetLanguage(targetCode).build()
        )
        try {
            Tasks.await(translator.downloadModelIfNeeded())
            Tasks.await(translator.translate(text))
        } finally {
            translator.close()
        }
    }

    private fun targetFor(detected: String, selected: String?): String {
        val first = app.getSharedPreferences("huan_settings", Context.MODE_PRIVATE).getString("language_1", "ru") ?: "ru"
        val second = app.getSharedPreferences("huan_settings", Context.MODE_PRIVATE).getString("language_2", "zh") ?: "zh"
        return if (selected == null) {
            if (detected == first) second else first
        } else {
            if (detected == first) second else first
        }
    }

    private fun toMlKitLanguage(code: String): String? = when (code.lowercase(Locale.ROOT)) {
        "zh", "zh-cn" -> TranslateLanguage.CHINESE
        "ru" -> TranslateLanguage.RUSSIAN
        "tr" -> TranslateLanguage.TURKISH
        "en" -> TranslateLanguage.ENGLISH
        else -> null
    }

    private fun speak(text: String, language: String) {
        if (!ttsReady || text.isBlank()) return
        val locale = when (language) {
            "ru" -> Locale("ru")
            "zh" -> Locale.SIMPLIFIED_CHINESE
            "tr" -> Locale("tr")
            else -> Locale.ENGLISH
        }
        val engine = tts ?: return
        val offlineVoice = engine.voices
            ?.filter { it.locale.language == locale.language && !it.isNetworkConnectionRequired }
            ?.maxByOrNull { it.quality }
        if (offlineVoice == null) {
            _state.value = _state.value.copy(status = _state.value.status + " · Нет установленного офлайн-голоса для озвучивания")
            return
        }
        engine.voice = offlineVoice
        engine.speak(text, TextToSpeech.QUEUE_FLUSH, null, "huan-" + System.currentTimeMillis())
    }

    fun clear() {
        _state.value = _state.value.copy(sourceText = "", translatedText = "", error = null)
    }

    private fun stopRecorder() {
        stopRequested = true
        recorder?.let { runCatching { it.stop() }; runCatching { it.release() } }
        recorder = null
    }

    fun close() {
        stopRecorder()
        recordingJob?.cancel()
        whisper?.close()
        whisper = null
        tts?.stop()
        tts?.shutdown()
        tts = null
        scope.cancel()
    }

    companion object {
        private const val MODEL_URL = "https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-small.bin"
    }
}
