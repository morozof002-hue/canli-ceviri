cmake_minimum_required(VERSION 3.22)
project(canliceviri_native C CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Debug APK'da bile yerel kod optimize derlensin; yoksa Whisper 10 kat yavaş çalışır ve ölçümler anlamsız olur.
set(CMAKE_C_FLAGS_DEBUG   "-O3 -DNDEBUG")
set(CMAKE_CXX_FLAGS_DEBUG "-O3 -DNDEBUG")

set(WHISPER_DIR ${CMAKE_CURRENT_SOURCE_DIR}/../../../../third_party/whisper.cpp)
if (NOT EXISTS ${WHISPER_DIR}/CMakeLists.txt)
    message(FATAL_ERROR "whisper.cpp bulunamadı: ${WHISPER_DIR}. Önce scripts/kurulum.sh çalıştırın.")
endif()

set(BUILD_SHARED_LIBS      OFF CACHE BOOL "" FORCE)
set(WHISPER_BUILD_TESTS    OFF CACHE BOOL "" FORCE)
set(WHISPER_BUILD_EXAMPLES OFF CACHE BOOL "" FORCE)
set(WHISPER_BUILD_SERVER   OFF CACHE BOOL "" FORCE)
set(WHISPER_ALL_WARNINGS   OFF CACHE BOOL "" FORCE)
set(GGML_NATIVE            OFF CACHE BOOL "" FORCE)
set(GGML_OPENMP            OFF CACHE BOOL "" FORCE)
# Target a broad ARMv8.2 baseline; avoid requiring optional i8mm on mid-range phones.
set(GGML_CPU_ARM_ARCH "armv8.2-a+dotprod+fp16" CACHE STRING "" FORCE)

add_subdirectory(${WHISPER_DIR} whisper_build)

add_library(canliceviri SHARED whisper_jni.cpp)
target_link_libraries(canliceviri PRIVATE whisper log android)
target_compile_options(canliceviri PRIVATE -O3 -fvisibility=hidden)
target_link_options(canliceviri PRIVATE -Wl,--gc-sections -Wl,--exclude-libs,ALL)
