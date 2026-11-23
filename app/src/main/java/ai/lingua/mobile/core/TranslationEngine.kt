package ai.lingua.mobile.core

/**
 * Contract between the app and the on-device inference runtime.
 *
 * The first implementation will be backed by llama.cpp/JNI. Keeping this
 * boundary independent from Compose prevents UI code from depending on
 * a particular model/runtime implementation.
 */
interface TranslationEngine {
    val isModelLoaded: Boolean

    suspend fun loadModel(modelPath: String)

    suspend fun translate(request: TranslationRequest): TranslationResult

    fun release()
}

data class TranslationRequest(
    val text: String,
    val source: Language,
    val target: Language
)

data class TranslationResult(
    val translatedText: String,
    val elapsedMillis: Long
)

class ModelNotLoadedException :
    IllegalStateException("Локальная модель ещё не загружена")
