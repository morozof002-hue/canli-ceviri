# LINGUA AI

A clean Android-first offline AI translator project. Legacy translator source code is not reused.

## Current milestone

- Native Android app shell using Kotlin and Jetpack Compose.
- Russian-first interface and language selector.
- Text input and translation-result surface.
- GitHub Actions debug APK build.
- Initial core contracts for supported languages and an on-device translation engine.

## Engine direction

- **Inference:** llama.cpp on Android arm64-v8a, connected through JNI.
- **Speech recognition:** whisper.cpp Android/native integration.
- **Speech output:** Android TextToSpeech with locally installed voice data where available.
- **First model candidate:** DeepSeek-R1-Distill-Qwen-1.5B in GGUF Q4_K_M (about 1.12 GB). This is a compact reasoning model, not a translation-specialist model; translation quality, speed, memory use and Russian/English/Turkish/Chinese behavior must be benchmarked on the target Honor phone before it is accepted.
- **Conversation mode:** push-to-talk; record while pressed, stop and translate on release. Translation-only prompt and output cleanup will be tested against questions, slang and mixed-language speech.

## Planned milestones

1. Build and package llama.cpp for Android arm64-v8a and connect the Kotlin engine contract through JNI.
2. Add model download/import, integrity checks, storage and memory checks.
3. Benchmark the DeepSeek GGUF candidate on the target phone; reject it if translation quality or speed is inadequate.
4. Integrate offline whisper.cpp speech recognition and push-to-talk recording.
5. Add offline TTS voice checks and complete conversation mode.

**Important:** the current APK is a UI/build foundation. It does not yet perform AI translation or speech recognition. The runtime and model are not represented as working until integrated and tested on-device.
