import java.util.Properties

plugins {
    alias(libs.plugins.android.application)
    alias(libs.plugins.kotlin.android)
    alias(libs.plugins.kotlin.serialization)
    alias(libs.plugins.compose.compiler)
    // NOTE: No google-services plugin — Firebase initialized programmatically
}

val localProps = Properties().apply {
    val f = rootProject.file("local.properties")
    if (f.exists()) load(f.inputStream())
}

// Resolve secrets: CI/CD env vars take priority over local.properties
fun secret(envKey: String, localKey: String, default: String = "") =
    System.getenv(envKey) ?: localProps.getProperty(localKey, default)

android {
    namespace   = "com.nexuswavetech.geetanexus"
    compileSdk  = 35

    defaultConfig {
        applicationId = "com.nexuswavetech.geetanexus"
        minSdk        = 24
        targetSdk     = 35
        versionCode   = 2
        versionName   = "2.0.0"

        // Ed25519 private key (PKCS8 Base64) — injected from CI/CD secret or local.properties
        // NEVER hardcode this value here
        buildConfigField("String", "ED25519_PRIVATE_KEY",
            "\"${secret("ED25519_PRIVATE_KEY", "ed25519.private.key")}\"")

        // Google Credential Manager
        buildConfigField("String", "GOOGLE_WEB_CLIENT_ID",
            "\"${secret("GOOGLE_WEB_CLIENT_ID", "google.web.client.id")}\"")

        buildConfigField("String", "SUPABASE_URL",
            "\"https://cpbwiarqlvtlnwbkmpws.supabase.co\"")
        buildConfigField("String", "SUPABASE_PUBLISHABLE_KEY",
            "\"${secret("SUPABASE_PUBLISHABLE_KEY", "supabase.publishable.key")}\"")

    }

    buildTypes {
        debug {
            isMinifyEnabled = false
        }
        release {
            isMinifyEnabled   = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }

    buildFeatures {
        compose      = true
        buildConfig  = true
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }
    kotlinOptions { jvmTarget = "17" }
    packaging { resources.excludes += "/META-INF/{AL2.0,LGPL2.1}" }
}

dependencies {
    implementation(project(":shared"))

    // Compose BOM
    val composeBom = platform(libs.compose.bom)
    implementation(composeBom)
    implementation("androidx.compose.ui:ui")
    implementation("androidx.compose.ui:ui-graphics")
    implementation("androidx.compose.ui:ui-tooling-preview")
    implementation("androidx.compose.material3:material3")
    implementation("androidx.compose.material:material-icons-extended")
    debugImplementation("androidx.compose.ui:ui-tooling")

    // AndroidX
    implementation(libs.androidx.activity.compose)
    implementation(libs.androidx.navigation.compose)
    implementation(libs.androidx.lifecycle.viewmodel.compose)
    implementation(libs.androidx.datastore.prefs)

    // Credentials / Google Sign-In (Credential Manager)
    implementation(libs.androidx.credentials)
    implementation(libs.androidx.credentials.play)
    implementation(libs.googleid)

    // Media3 / ExoPlayer
    implementation(libs.media3.exoplayer)
    implementation(libs.media3.ui)
    implementation(libs.media3.session)
    implementation(libs.media3.okhttp)

    // Koin
    implementation(libs.koin.android)
    implementation(libs.koin.compose)

    // Coroutines
    implementation(libs.kotlinx.coroutines.android)

    // Crypto (Ed25519 signing)
    implementation(libs.bouncycastle)

    // Image
    implementation(libs.coil.compose)

    // Firebase BOM — no google-services plugin; initialized with FirebaseOptions.Builder
    val firebaseBom = platform(libs.firebase.bom)
    implementation(firebaseBom)
    implementation(libs.firebase.messaging)
    implementation(libs.firebase.analytics)

    // WorkManager (daily verse notifications)
    implementation(libs.work.manager)
}
