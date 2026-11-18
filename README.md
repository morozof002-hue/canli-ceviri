# HUAN Translator

HUAN is a new Android voice-translator project being rebuilt in this repository.

## Product goals

- Two large conversation buttons: Language 1 and Language 2.
- Russian, Chinese, Turkish and English included as the four core languages.
- Additional languages can be added as downloadable language packs.
- Three microphone interaction modes:
  1. Tap to start, tap again to stop.
  2. Hold to speak, release to stop.
  3. Start once and automatically finish after a detected pause (VAD).
- On-device speech recognition, translation and speech output wherever supported.
- No advertising, subscription or mandatory cloud translation API.
- User-selected languages and microphone mode persist after restart.

## Current development status

The HUAN rebuild is on the `huan-rebuild` branch.

Implemented in this first step:
- New HUAN-branded Compose screen.
- Local microphone recording with tap, hold-to-speak and silence-stop modes.
- Whisper.cpp small multilingual model download and on-device speech recognition.
- ML Kit on-device translation for Russian, Chinese, Turkish and English after language model download.
- Android Text-to-Speech output when the installed voice supports the selected language.
- Two language selectors for the four core languages.
- Settings dialog with all three planned microphone modes.
- Persistent language, microphone mode and automatic language-detection setting using Android preferences.
- Simplified Android manifest and standalone app Gradle configuration.
- A dedicated GitHub Actions workflow for building a debug APK.

Still to implement or validate:
- Dedicated neural VAD (current first pass uses an energy/silence threshold).
- A dedicated offline translation engine that does not depend on Google ML Kit model downloads.
- Explicit translation-model download management and storage controls.
- Conversation history and editing/replay.
- Device-level testing of recognition speed, heat, memory and TTS voices.

The microphone buttons now run the local Whisper recognition path. Translation models are downloaded by ML Kit when a language pair is first used; first-time model download therefore needs internet. The full app still requires a successful CI build and real-device testing before it should be treated as a finished translator.

## Planned architecture

| Layer | Planned implementation |
|---|---|
| Android UI | Kotlin, Jetpack Compose, Material 3 |
| Settings | Persistent local preferences; migrate to DataStore |
| Speech recognition | whisper.cpp, subject to device performance tests |
| Voice activity detection | Local VAD implementation |
| Translation | Pluggable on-device translation engine |
| Speech output | Android TextToSpeech with installed offline voices |
| Model management | Download, verify, update and remove language models |

## Build

Run the GitHub Actions workflow **Build HUAN Translator APK** or build locally:

```bash
./gradlew assembleDebug
```

The debug APK is produced at:

```
app/build/outputs/apk/debug/app-debug.apk
```

## Device testing

The first target is a modern Android ARM64 phone. Real-world speed, memory use, offline voice availability and translation quality must be measured on the target device before any offline-performance claims are made.
