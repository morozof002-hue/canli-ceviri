package ai.lingua.mobile

import android.media.AudioFormat
import android.media.AudioRecord
import android.media.MediaRecorder
import java.io.File
import java.io.FileOutputStream
import kotlin.concurrent.thread

class VoiceRecorder {
    @Volatile private var recording = false
    @Volatile private var workerFailure: Throwable? = null
    private var recorder: AudioRecord? = null
    private var worker: Thread? = null
    private var outputFile: File? = null

    @Synchronized
    fun start(file: File) {
        check(!recording && worker == null) { "Предыдущая запись ещё не завершена" }
        val minimum = AudioRecord.getMinBufferSize(16_000, AudioFormat.CHANNEL_IN_MONO, AudioFormat.ENCODING_PCM_16BIT)
        require(minimum > 0) { "Микрофон не поддерживает запись 16 кГц (код $minimum)" }
        file.parentFile?.mkdirs()
        if (file.exists()) file.delete()
        val audio = AudioRecord(
            MediaRecorder.AudioSource.VOICE_RECOGNITION,
            16_000,
            AudioFormat.CHANNEL_IN_MONO,
            AudioFormat.ENCODING_PCM_16BIT,
            maxOf(minimum, 32_000)
        )
        check(audio.state == AudioRecord.STATE_INITIALIZED) {
            audio.release()
            "Не удалось открыть микрофон"
        }
        try {
            audio.startRecording()
            check(audio.recordingState == AudioRecord.RECORDSTATE_RECORDING) { "Android не запустил запись микрофона" }
        } catch (e: Exception) {
            audio.release()
            throw e
        }

        recorder = audio
        outputFile = file
        workerFailure = null
        recording = true
        worker = thread(name = "lingua-audio-capture") {
            try {
                val samples = ShortArray(4096)
                FileOutputStream(file, false).use { stream ->
                    while (recording) {
                        val n = audio.read(samples, 0, samples.size, AudioRecord.READ_BLOCKING)
                        if (n > 0) {
                            val bytes = ByteArray(n * 2)
                            for (i in 0 until n) {
                                val value = samples[i].toInt()
                                bytes[i * 2] = (value and 255).toByte()
                                bytes[i * 2 + 1] = ((value shr 8) and 255).toByte()
                            }
                            stream.write(bytes)
                        } else if (recording) {
                            throw IllegalStateException("Ошибка чтения микрофона (код $n)")
                        }
                    }
                    stream.flush()
                }
            } catch (t: Throwable) {
                workerFailure = t
                recording = false
            }
        }
    }

    @Synchronized
    fun stop(): File? {
        recording = false
        val audio = recorder
        try {
            if (audio?.recordingState == AudioRecord.RECORDSTATE_RECORDING) audio.stop()
        } catch (_: Exception) {
        }

        val captureThread = worker
        if (captureThread != null) {
            captureThread.join(5_000)
            check(!captureThread.isAlive) { "Запись звука не завершилась вовремя" }
        }

        try {
            audio?.release()
        } finally {
            recorder = null
            worker = null
        }

        workerFailure?.let { throw IllegalStateException("Не удалось сохранить звук: ${it.message ?: it.javaClass.simpleName}", it) }
        return outputFile.also { outputFile = null }
    }
}
