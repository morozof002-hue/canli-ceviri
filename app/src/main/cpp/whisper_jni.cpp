#include <jni.h>
#include <android/log.h>
#include "whisper.h"
#include <cstdint>
#include <fstream>
#include <vector>
#include <string>

#define LOG_TAG "LINGUA_WHISPER"
#define LOGE(...) __android_log_print(ANDROID_LOG_ERROR, LOG_TAG, __VA_ARGS__)

extern "C"
JNIEXPORT jstring JNICALL
Java_ai_lingua_mobile_NativeWhisper_transcribeNative(
        JNIEnv *env, jobject,
        jstring audio_path, jstring model_path, jstring language) {
    const char *audio = env->GetStringUTFChars(audio_path, nullptr);
    const char *model = env->GetStringUTFChars(model_path, nullptr);
    const char *lang = env->GetStringUTFChars(language, nullptr);

    std::ifstream input(audio, std::ios::binary);
    std::vector<int16_t> pcm;
    if (input) {
        input.seekg(0, std::ios::end);
        const auto bytes = input.tellg();
        input.seekg(0, std::ios::beg);
        if (bytes > 0) {
            pcm.resize(static_cast<size_t>(bytes) / sizeof(int16_t));
            input.read(reinterpret_cast<char *>(pcm.data()), static_cast<std::streamsize>(pcm.size() * sizeof(int16_t)));
        }
    }

    std::string result;
    if (pcm.empty()) {
        result = "Не удалось получить аудиоданные.";
    } else {
        whisper_context_params context_params = whisper_context_default_params();
        context_params.use_gpu = false;
        whisper_context *ctx = whisper_init_from_file_with_params(model, context_params);
        if (!ctx) {
            result = "Не удалось загрузить модель Whisper.";
        } else {
            std::vector<float> samples(pcm.size());
            for (size_t i = 0; i < pcm.size(); ++i) samples[i] = static_cast<float>(pcm[i]) / 32768.0f;

            whisper_full_params params = whisper_full_default_params(WHISPER_SAMPLING_GREEDY);
            params.print_progress = false;
            params.print_realtime = false;
            params.print_timestamps = false;
            params.no_context = true;
            params.n_threads = 4;
            params.language = (lang && std::string(lang) != "auto") ? lang : nullptr;

            if (whisper_full(ctx, params, samples.data(), static_cast<int>(samples.size())) != 0) {
                result = "Whisper не смог распознать речь.";
            } else {
                const int count = whisper_full_n_segments(ctx);
                for (int i = 0; i < count; ++i) {
                    const char *segment = whisper_full_get_segment_text(ctx, i);
                    if (segment) result += segment;
                }
            }
            whisper_free(ctx);
        }
    }

    env->ReleaseStringUTFChars(audio_path, audio);
    env->ReleaseStringUTFChars(model_path, model);
    env->ReleaseStringUTFChars(language, lang);
    return env->NewStringUTF(result.c_str());
}
