import java.util.Properties

plugins {
    alias(libs.plugins.android.application)
    alias(libs.plugins.kotlin.android)
    alias(libs.plugins.compose.compiler)
}

// ── Read local.properties ────────────────────────────────────────────────────
val localProps = Properties().apply {
    val f = rootProject.file("local.properties")
    if (f.exists()) load(f.inputStream())
}

android {
    namespace   = "com.nexuswavetech.geetanexus"
    compileSdk  = 34

    defaultConfig {
        applicationId = "com.nexuswavetech.geetanexus"
        minSdk        = 26
        targetSdk     = 34
        versionCode   = 1
        versionName   = "2.0.0"

        // Inject Ed25519 private key at build time from local.properties
        // NEVER commit the real key to source control.
        buildConfigField(
            "String", "ED25519_PRIVATE_KEY",
            "\"${localProps.getProperty("ed25519.private.key", "REPLACE_ME")}\""
        )

        // Inject Google Web Client ID
        buildConfigField(
            "String", "GOOGLE_WEB_CLIENT_ID",
            "\"${localProps.getProperty(
                "google.web.client.id",
                "479687771729-c2k3cfiv50m6h7agj0nkckj6i1tm9pkh.apps.googleusercontent.com"
            )}\""
        )
    }

    buildFeatures {
        compose      = true
        buildConfig  = true
    }

    buildTypes {
        release {
            isMinifyEnabled  = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions { jvmTarget = "17" }

    packaging {
        resources.excludes += "/META-INF/{AL2.0,LGPL2.1}"
    }
}

dependencies {
    implementation(project(":shared"))

    // Compose BOM
    val composeBom = platform("androidx.compose:compose-bom:2024.09.03")
    implementation(composeBom)
    implementation("androidx.compose.ui:ui")
    implementation("androidx.compose.ui:ui-tooling-preview")
    implementation("androidx.compose.material3:material3")
    implementation("androidx.compose.material:material-icons-extended")
    implementation("androidx.compose.animation:animation")
    debugImplementation("androidx.compose.ui:ui-tooling")

    // Core AndroidX
    implementation(libs.androidx.activity.compose)
    implementation(libs.androidx.navigation.compose)
    implementation(libs.lifecycle.viewmodel.compose)
    implementation(libs.lifecycle.runtime.ktx)

    // Credential Manager (Google Sign-In)
    implementation(libs.androidx.credentials)
    implementation(libs.androidx.credentials.play.auth)
    implementation(libs.googleid)

    // DI
    implementation(libs.koin.android)
    implementation(libs.koin.compose)

    // Coroutines
    implementation(libs.kotlinx.coroutines.android)

    // DataStore
    implementation(libs.datastore.preferences)

    // BouncyCastle (Ed25519 on JVM — also declared in :shared androidMain)
    implementation(libs.bouncycastle)

    // Coil for async image loading
    implementation("io.coil-kt:coil-compose:2.7.0")
}
