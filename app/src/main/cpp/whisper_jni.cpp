#include <jni.h>
#include <android/log.h>
#include "whisper.h"
#include <algorithm>
#include <cstdint>
#include <fstream>
#include <mutex>
#include <string>
#include <thread>
#include <vector>

#define LOG_TAG "LINGUA_WHISPER"
#define LOGE(...) __android_log_print(ANDROID_LOG_ERROR, LOG_TAG, __VA_ARGS__)

// Keep the 1.1 GB model loaded between phrases. Loading it for every recording
// was the main avoidable source of long delays.
static std::mutex g_whisper_mutex;
static whisper_context *g_whisper_context = nullptr;
static std::string g_loaded_model_path;

extern "C"
JNIEXPORT jstring JNICALL
Java_ai_lingua_mobile_NativeWhisper_transcribeNative(
        JNIEnv *env, jobject,
        jstring audio_path, jstring model_path, jstring language) {
    const char *audio_chars = env->GetStringUTFChars(audio_path, nullptr);
    const char *model_chars = env->GetStringUTFChars(model_path, nullptr);
    const char *language_chars = env->GetStringUTFChars(language, nullptr);

    const std::string audio_file = audio_chars ? audio_chars : "";
    const std::string model_file = model_chars ? model_chars : "";
    const std::string lang = language_chars ? language_chars : "auto";

    if (audio_chars) env->ReleaseStringUTFChars(audio_path, audio_chars);
    if (model_chars) env->ReleaseStringUTFChars(model_path, model_chars);
    if (language_chars) env->ReleaseStringUTFChars(language, language_chars);

    std::ifstream input(audio_file, std::ios::binary);
    std::vector<int16_t> pcm;
    if (input) {
        input.seekg(0, std::ios::end);
        const auto bytes = input.tellg();
        input.seekg(0, std::ios::beg);
        if (bytes > 0) {
            pcm.resize(static_cast<size_t>(bytes) / sizeof(int16_t));
            input.read(reinterpret_cast<char *>(pcm.data()),
                       static_cast<std::streamsize>(pcm.size() * sizeof(int16_t)));
        }
    }

    std::string result;
    if (pcm.empty()) {
        result = "Не удалось получить аудиоданные.";
    } else {
        std::lock_guard<std::mutex> lock(g_whisper_mutex);

        if (g_whisper_context == nullptr || g_loaded_model_path != model_file) {
            if (g_whisper_context != nullptr) {
                whisper_free(g_whisper_context);
                g_whisper_context = nullptr;
            }

            whisper_context_params context_params = whisper_context_default_params();
            context_params.use_gpu = false;
            g_whisper_context = whisper_init_from_file_with_params(model_file.c_str(), context_params);
            if (g_whisper_context != nullptr) {
                g_loaded_model_path = model_file;
            } else {
                g_loaded_model_path.clear();
            }
        }

        if (g_whisper_context == nullptr) {
            result = "Не удалось загрузить модель Whisper. Проверьте файл модели.";
        } else {
            std::vector<float> samples(pcm.size());
            for (size_t i = 0; i < pcm.size(); ++i) {
                samples[i] = static_cast<float>(pcm[i]) / 32768.0f;
            }

            whisper_full_params params = whisper_full_default_params(WHISPER_SAMPLING_GREEDY);
            params.print_progress = false;
            params.print_realtime = false;
            params.print_timestamps = false;
            params.no_context = true;
            params.n_threads = 4;
            params.language = (lang.empty() || lang == "auto") ? nullptr : lang.c_str();

            if (whisper_full(g_whisper_context, params, samples.data(),
                             static_cast<int>(samples.size())) != 0) {
                result = "Whisper не смог распознать речь.";
            } else {
                const int count = whisper_full_n_segments(g_whisper_context);
                for (int i = 0; i < count; ++i) {
                    const char *segment = whisper_full_get_segment_text(g_whisper_context, i);
                    if (segment) result += segment;
                }
            }
        }
    }

    return env->NewStringUTF(result.c_str());
}

extern "C"
JNIEXPORT void JNICALL
JNI_OnUnload(JavaVM *, void *) {
    std::lock_guard<std::mutex> lock(g_whisper_mutex);
    if (g_whisper_context != nullptr) {
        whisper_free(g_whisper_context);
        g_whisper_context = nullptr;
    }
    g_loaded_model_path.clear();
}
