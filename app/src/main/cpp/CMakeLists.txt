cmake_minimum_required(VERSION 3.22.1)
project(lingua_whisper)

set(WHISPER_BUILD_TESTS OFF CACHE BOOL "" FORCE)
set(WHISPER_BUILD_EXAMPLES OFF CACHE BOOL "" FORCE)
set(WHISPER_BUILD_SERVER OFF CACHE BOOL "" FORCE)
set(GGML_NATIVE OFF CACHE BOOL "" FORCE)
set(GGML_OPENMP OFF CACHE BOOL "" FORCE)

include(FetchContent)
FetchContent_Declare(
    whisper_cpp
    GIT_REPOSITORY https://github.com/ggerganov/whisper.cpp.git
    GIT_TAG v1.7.6
    GIT_SHALLOW TRUE
)
FetchContent_MakeAvailable(whisper_cpp)

add_library(lingua_whisper SHARED whisper_jni.cpp)
target_include_directories(lingua_whisper PRIVATE ${whisper_cpp_SOURCE_DIR}/include)
find_library(log-lib log)
target_link_libraries(lingua_whisper PRIVATE whisper ${log-lib} android)
