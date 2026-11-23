# LINGUA AI

A new Android-first offline AI translator project. This is a clean replacement application; legacy translator source code is not reused.

## Current milestone

- Native Android app shell using Kotlin and Jetpack Compose.
- Russian-first interface and language selector.
- Text input and translation-result surface.
- GitHub Actions debug APK build.

## Planned milestones

1. Integrate an on-device GGUF inference runtime (llama.cpp Android/JNI).
2. Add an in-app model manager and a compatible quantized DeepSeek-family model.
3. Add offline speech recognition and text-to-speech with explicit language-pack checks.
4. Implement push-to-talk conversation mode and translation-only prompting.

**Important:** this initial milestone is a UI/build foundation. It does not yet perform AI translation or speech recognition. The model and speech runtimes are deliberately not represented as working until integrated and tested on the target phone.
