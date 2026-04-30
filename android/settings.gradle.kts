pluginManagement {
    val flutterSdkPath = run {
        val properties = java.util.Properties()
        file("local.properties").inputStream().use { properties.load(it) }
        val flutterSdkPath = properties.getProperty("flutter.sdk")
        require(flutterSdkPath != null) { "flutter.sdk not set in local.properties" }
        flutterSdkPath
    }

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    
    // ✅ 8.3.0 ko hata kar 8.7.0 kiya gaya hai (Latest & Stable)
    id("com.android.application") version "8.7.0" apply false
    
    // ✅ Kotlin 2.1.0 naye plugins ke liye zaroori hai
    id("org.jetbrains.kotlin.android") version "2.1.0" apply false
    
    id("com.google.gms.google-services") version "4.4.1" apply false
}

include(":app")
