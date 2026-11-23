package ai.lingua.mobile

object NativeWhisper {
    init {
        System.loadLibrary("lingua_whisper")
    }

    external fun transcribeNative(audioPath: String, modelPath: String, language: String): String
}
