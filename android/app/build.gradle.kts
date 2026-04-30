import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services") 
}

val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()
if (keystorePropertiesFile.exists()) {
    FileInputStream(keystorePropertiesFile).use {
        keystoreProperties.load(it)
    }
}

android {
    namespace = "com.satviktechnologies.geetanexus"
    
    // SDK 34 stable hai aur Play Store ki requirements ko pura karta hai
    compileSdk = 34 
    ndkVersion = flutter.ndkVersion

    signingConfigs {
        create("release") {
            if (keystorePropertiesFile.exists()) {
                keyAlias = keystoreProperties["keyAlias"]?.toString()
                keyPassword = keystoreProperties["keyPassword"]?.toString()
                storePassword = keystoreProperties["storePassword"]?.toString()
                
                val sFile = keystoreProperties["storeFile"]?.toString()
                if (sFile != null) {
                    storeFile = file(sFile)
                }
            }
        }
    }

    defaultConfig {
        applicationId = "com.satviktechnologies.geetanexus"
        minSdk = 21 
        targetSdk = 34 
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        
        // MultiDex release builds ke liye zaroori hai
        multiDexEnabled = true 
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
            
            // Code ko chota aur secure banane ke liye
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }

    // Isse metadata mismatch ke errors solve ho jate hain
    packaging {
        resources {
            excludes += "/META-INF/{AL2.0,LGPL2.1}"
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Firebase setup
    implementation(platform("com.google.firebase:firebase-bom:33.1.0"))
    implementation("com.google.firebase:firebase-analytics")
    implementation("com.google.firebase:firebase-messaging") 
    implementation("com.google.firebase:firebase-auth")
    implementation("com.google.android.gms:play-services-auth:21.1.1")
    
    // Multidex support
    implementation("androidx.multidex:multidex:2.0.1")
}
