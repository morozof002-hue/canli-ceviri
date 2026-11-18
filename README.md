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

The first HUAN interface rebuild is on the `huan-rebuild` branch.

Implemented in this first step:
- New HUAN-branded Compose screen.
- Two language selectors for the four core languages.
- Settings dialog with all three planned microphone modes.
- Persistent language and mode selections using Android preferences.
- Simplified Android manifest and standalone app Gradle configuration.
- A dedicated GitHub Actions workflow for building a debug APK.

Not implemented yet:
- Actual microphone capture and speech recognition.
- Voice activity detection.
- Translation engine and model management.
- Text-to-speech output.
- Downloadable language packs and conversation history.

The microphone buttons currently display an explanatory message. They do not claim to translate until the speech pipeline is connected.

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
