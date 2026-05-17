plugins {
    id("com.android.application")
    id("com.google.gms.google-services")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.habitflow"

    // 1. MUST BE 36 to satisfy shared_preferences and google_sign_in
    compileSdk = 36
    ndkVersion = "27.0.12077973"

    compileOptions {
        isCoreLibraryDesugaringEnabled = true

        // 2. CHANGE THESE BACK TO 1.8 to fix the notification error
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
    }

    kotlinOptions {
        // 3. CHANGE THIS TO "1.8"
        jvmTarget = "1.8"
    }

    defaultConfig {
        applicationId = "com.example.habitflow"

        // 4. Manual override for Firestore compatibility
        minSdk = flutter.minSdkVersion
        targetSdk = 36

        versionCode = flutter.versionCode
        versionName = flutter.versionName
        multiDexEnabled = true
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
