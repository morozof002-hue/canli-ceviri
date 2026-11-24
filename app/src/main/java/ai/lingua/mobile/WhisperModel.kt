package ai.lingua.mobile

import android.content.Context
import java.io.File
import java.net.HttpURLConnection
import java.net.URL

object WhisperModel {
    private const val MODEL_URL =
        "https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-large-v3-turbo-q5_0.bin"

    fun modelFile(context: Context) = File(context.filesDir, "ggml-large-v3-turbo-q5_0.bin")

    // Turbo Q5_0 is roughly 575 MB; keep the previous Large V3 file untouched.
    fun isInstalled(context: Context) = modelFile(context).length() > 500L * 1024L * 1024L

    fun download(context: Context, onProgress: (Int) -> Unit): File {
        val destination = modelFile(context)
        val temporary = File(context.filesDir, "ggml-large-v3-turbo-q5_0.bin.part")
        val connection = (URL(MODEL_URL).openConnection() as HttpURLConnection).apply {
            connectTimeout = 20_000
            readTimeout = 60_000
            instanceFollowRedirects = true
        }
        try {
            connection.connect()
            if (connection.responseCode !in 200..299) {
                error("Не удалось скачать модель Whisper Turbo: HTTP ${connection.responseCode}")
            }
            val total = connection.contentLengthLong
            connection.inputStream.use { input ->
                temporary.outputStream().use { output ->
                    val buffer = ByteArray(64 * 1024)
                    var received = 0L
                    while (true) {
                        val count = input.read(buffer)
                        if (count < 0) break
                        output.write(buffer, 0, count)
                        received += count
                        if (total > 0) onProgress(((received * 100) / total).toInt().coerceIn(0, 100))
                    }
                }
            }
            check(temporary.length() > 500L * 1024L * 1024L) { "Файл модели Turbo слишком маленький или повреждён." }
            if (destination.exists()) destination.delete()
            check(temporary.renameTo(destination)) { "Не удалось сохранить модель Whisper Turbo." }
            return destination
        } finally {
            connection.disconnect()
            if (temporary.exists()) temporary.delete()
        }
    }
}
