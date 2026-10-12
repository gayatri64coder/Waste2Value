plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val localProperties = java.util.Properties()
val localPropertiesFile = rootProject.file("local.properties")
if (localPropertiesFile.exists()) {
    localPropertiesFile.inputStream().use { localProperties.load(it) }
}

// Maps API key resolution: reads from local.properties, gradle properties, or environment variables.
// Fallback is the explicit placeholder "YOUR_GOOGLE_MAPS_API_KEY".
val mapsApiKey: String = localProperties.getProperty("MAPS_API_KEY")
    ?: project.findProperty("MAPS_API_KEY") as? String
    ?: System.getenv("MAPS_API_KEY")
    ?: "YOUR_GOOGLE_MAPS_API_KEY"

android {
    namespace = "com.waste2value.app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.waste2value.app"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        // Injected into AndroidManifest.xml
        manifestPlaceholders["GOOGLE_MAPS_API_KEY"] = mapsApiKey
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}

// Firebase Android Configuration:
// If android/app/google-services.json exists, apply the official google-services plugin.
// If the file is not yet supplied by the team, gracefully warn without failing compilation.
if (file("google-services.json").exists()) {
    apply(plugin = "com.google.gms.google-services")
} else {
    logger.warn("⚠️ [waste2value] android/app/google-services.json not found! Firebase Android services will be pending until you place your real configuration file. See README.md for instructions.")
}

