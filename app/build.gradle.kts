import java.util.Properties

plugins {
    alias(libs.plugins.android.application)
    alias(libs.plugins.kotlin.android)
    alias(libs.plugins.kotlin.compose)
}

fun localProperty(name: String): String {
    val file = rootProject.file("local.properties")
    if (!file.exists()) return ""
    return Properties().apply { file.inputStream().use { load(it) } }.getProperty(name, "")
}

android {
    namespace = "com.alterra.canliceviri"
    compileSdk = 36
    ndkVersion = "29.0.14206865"

    defaultConfig {
        applicationId = "com.alterra.canliceviri"
        minSdk = 26
        targetSdk = 36
        versionCode = 14
        versionName = "1.0.0"
        buildConfigField("String", "RAPOR_WHATSAPP", "\"\"")

        ndk {
            abiFilters += listOf("arm64-v8a")
        }
    }

    externalNativeBuild {
        cmake {
            path = file("src/main/cpp/CMakeLists.txt")
            version = "3.31.6"
        }
    }

    signingConfigs {
        create("musteri") {
            val file = localProperty("imza.dosya")
            if (file.isNotEmpty() && File(file).exists()) {
                storeFile = File(file)
                storePassword = localProperty("imza.parola")
                keyAlias = localProperty("imza.takma")
                keyPassword = localProperty("imza.parola")
            }
        }
    }

    buildTypes {
        release {
            isMinifyEnabled = true
            isShrinkResources = true
            val musteri = signingConfigs.getByName("musteri")
            signingConfig = if (musteri.storeFile != null) musteri else signingConfigs.getByName("debug").also {
                logger.warn("No release keystore configured; using debug signing")
            }
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }
    kotlin {
        compilerOptions {
            jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17)
        }
    }

    buildFeatures {
        compose = true
        buildConfig = true
    }

    packaging {
        resources {
            excludes += "/META-INF/{AL2.0,LGPL2.1}"
        }
    }
}

dependencies {
    implementation(project(":llm"))
    implementation(libs.androidx.core.ktx)
    implementation(libs.androidx.lifecycle.runtime.ktx)
    implementation(libs.androidx.lifecycle.viewmodel.compose)
    implementation(libs.androidx.activity.compose)
    implementation(platform(libs.androidx.compose.bom))
    implementation(libs.androidx.ui)
    implementation(libs.androidx.ui.graphics)
    implementation(libs.androidx.ui.tooling.preview)
    implementation(libs.androidx.material3)
    implementation(libs.kotlinx.coroutines.android)
    implementation("org.jetbrains.kotlinx:kotlinx-coroutines-play-services:1.10.2")
    implementation("com.google.mlkit:translate:17.0.3")
    debugImplementation(libs.androidx.ui.tooling)
}
