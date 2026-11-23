package ai.lingua.mobile

import android.media.AudioFormat
import android.media.AudioRecord
import android.media.MediaRecorder
import java.io.File
import java.io.FileOutputStream
import kotlin.concurrent.thread

class VoiceRecorder {
    @Volatile private var recording = false
    private var recorder: AudioRecord? = null
    private var worker: Thread? = null
    private var outputFile: File? = null

    fun start(file: File) {
        check(!recording)
        val minimum = AudioRecord.getMinBufferSize(16_000, AudioFormat.CHANNEL_IN_MONO, AudioFormat.ENCODING_PCM_16BIT)
        require(minimum > 0) { "Микрофон не поддерживает запись 16 кГц" }
        val audio = AudioRecord(MediaRecorder.AudioSource.VOICE_RECOGNITION, 16_000, AudioFormat.CHANNEL_IN_MONO, AudioFormat.ENCODING_PCM_16BIT, maxOf(minimum, 32_000))
        check(audio.state == AudioRecord.STATE_INITIALIZED) { "Не удалось открыть микрофон" }
        recorder = audio
        outputFile = file
        recording = true
        audio.startRecording()
        worker = thread(name = "lingua-audio-capture") {
            val samples = ShortArray(4096)
            FileOutputStream(file).use { stream ->
                while (recording) {
                    val n = audio.read(samples, 0, samples.size)
                    if (n > 0) {
                        val bytes = ByteArray(n * 2)
                        for (i in 0 until n) {
                            val v = samples[i].toInt()
                            bytes[i * 2] = (v and 255).toByte()
                            bytes[i * 2 + 1] = ((v shr 8) and 255).toByte()
                        }
                        stream.write(bytes)
                    }
                }
            }
        }
    }

    fun stop(): File? {
        recording = false
        try { recorder?.stop() } catch (_: Exception) { }
        worker?.join(2_000)
        recorder?.release()
        recorder = null
        worker = null
        return outputFile.also { outputFile = null }
    }
}