# LINGUA AI

LINGUA AI is an Android voice translator focused on natural two-way conversations.

## First release goals

- Push-to-talk: press and hold one language button while speaking; release to stop recording and start translation.
- Russian, Chinese, Turkish and English as the initial language set.
- No advertisements and no mandatory paid API.
- On-device speech recognition with whisper.cpp.
- On-device translation through downloadable ML Kit language models in the initial build.
- Speech playback through Android Text-to-Speech when a compatible voice is installed.
- Language pair and microphone mode saved on the device.

## Current implementation

The initial Android app is based on the existing HUAN voice-translator foundation in this repository. The LINGUA AI branch applies the new product name, defaults the language pair to Russian ↔ Chinese, and selects push-to-talk as the default interaction mode.

Speech recognition uses a downloadable Whisper small multilingual model (approximately 466 MB). Translation uses on-device ML Kit language models, which are downloaded on first use of a language pair. The app does not send recorded speech to a translation API. TTS uses installed Android voices; offline voice availability depends on the phone's installed language packs.

This is a functional prototype, not yet a finished context-aware AI interpreter. Conversation context, camera/menu translation, translation history, model management and robust device-level performance testing remain planned work. Translation quality and responsiveness must be tested on the target Honor phone before making quality claims.

## Build

GitHub Actions workflow: **Build HUAN Translator APK**.

The debug APK is generated at:

```
app/build/outputs/apk/debug/app-debug.apk
```

The build can be triggered from GitHub Actions or by pushing to the `lingua-ai` branch.
