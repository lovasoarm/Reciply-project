plugins {
    id("com.android.application")
    id("com.google.gms.google-services")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.reciply"
    compileSdk = 34

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    defaultConfig {
        applicationId = "com.example.reciply"
        minSdk = 23
        targetSdk = 34
        versionCode = (flutter.versionCode?.toInt()) ?: 1
        versionName = flutter.versionName ?: "1.0"
        multiDexEnabled = true
    }

    buildTypes {
        getByName("release") {
            // Configuration temporaire pour les tests
            signingConfig = signingConfigs.getByName("debug")
            
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
        getByName("debug") {
            isDebuggable = true
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    implementation("androidx.multidex:multidex:2.0.1")
    // Dépendances optionnelles :
    // implementation(platform("com.google.firebase:firebase-bom:32.8.0"))
    // implementation("androidx.core:core-splashscreen:1.0.1")
}