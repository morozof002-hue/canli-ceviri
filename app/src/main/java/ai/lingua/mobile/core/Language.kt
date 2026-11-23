package ai.lingua.mobile.core

/**
 * Languages exposed by the first LINGUA AI milestone.
 * Stable codes are used by the translation prompt and speech pipeline.
 */
enum class Language(val code: String, val displayName: String) {
    RUSSIAN("ru", "Русский"),
    ENGLISH("en", "English"),
    TURKISH("tr", "Türkçe"),
    CHINESE_SIMPLIFIED("zh", "中文");

    companion object {
        fun fromCode(code: String): Language? =
            entries.firstOrNull { it.code == code }
    }
}
