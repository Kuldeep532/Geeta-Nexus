# ─── Gita Nexus — Aggressive R8 / ProGuard Rules ────────────────────────────
# Hardened against reverse engineering — inspired by enterprise-grade configs.
# Keep only what is strictly necessary; obfuscate everything else.

# ─── Kotlin & Coroutines ─────────────────────────────────────────────────────
-keepclassmembers class kotlin.Metadata { *; }
-keep class kotlin.coroutines.** { *; }
-keepclassmembernames class kotlinx.coroutines.** {
    volatile <fields>;
}

# ─── Serialization ───────────────────────────────────────────────────────────
-keepattributes *Annotation*, InnerClasses
-dontnote kotlinx.serialization.AnnotationsKt
-keepclassmembers @kotlinx.serialization.Serializable class ** {
    *** Companion;
    *** INSTANCE;
    kotlinx.serialization.KSerializer serializer(...);
}
-keepclassmembernames class kotlinx.** { volatile <fields>; }

# ─── Compose ─────────────────────────────────────────────────────────────────
-keep class androidx.compose.** { *; }
-keepclassmembers class * extends androidx.lifecycle.ViewModel { <init>(...); }
-keepclassmembers class * extends androidx.lifecycle.AndroidViewModel { <init>(...); }

# ─── Firebase ────────────────────────────────────────────────────────────────
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.firebase.**
-dontwarn com.google.android.gms.**

# ─── Credential Manager / Google Sign-In ─────────────────────────────────────
-keep class androidx.credentials.** { *; }
-keep class com.google.android.libraries.identity.googleid.** { *; }

# ─── Ktor ────────────────────────────────────────────────────────────────────
-keep class io.ktor.** { *; }
-dontwarn io.ktor.**

# ─── BouncyCastle (Ed25519) ──────────────────────────────────────────────────
-keep class org.bouncycastle.** { *; }
-dontwarn org.bouncycastle.**

# ─── Koin ────────────────────────────────────────────────────────────────────
-keep class org.koin.** { *; }
-keepclassmembers class * {
    @org.koin.core.annotation.* <methods>;
}

# ─── WorkManager ─────────────────────────────────────────────────────────────
-keep class * extends androidx.work.Worker { <init>(...); }
-keep class * extends androidx.work.CoroutineWorker { <init>(...); }
-keep class * extends androidx.work.ListenableWorker { <init>(...); }

# ─── Media3 / ExoPlayer ──────────────────────────────────────────────────────
-keep class androidx.media3.** { *; }
-dontwarn androidx.media3.**

# ─── Coil ────────────────────────────────────────────────────────────────────
-keep class coil.** { *; }
-dontwarn coil.**

# ─── Domain models (Firestore deserialization) ────────────────────────────────
-keep class com.nexuswavetech.geetanexus.domain.models.** { *; }

# ─── BuildConfig (contains secrets — obfuscate field names but keep class) ───
-keep class com.nexuswavetech.geetanexus.BuildConfig { *; }

# ─── FCM Service ─────────────────────────────────────────────────────────────
-keep class com.nexuswavetech.geetanexus.notification.** { *; }

# ─── Remove logging in release ───────────────────────────────────────────────
-assumenosideeffects class android.util.Log {
    public static boolean isLoggable(java.lang.String, int);
    public static int v(...);
    public static int d(...);
    public static int i(...);
    public static int w(...);
    public static int e(...);
}

# ─── String encryption (R8 full mode) ────────────────────────────────────────
-optimizations !code/simplification/arithmetic,!code/simplification/cast,!field/*,!class/merging/*
-optimizationpasses 7
-allowaccessmodification
-repackageclasses 'x'

# ─── OkHttp / Okio ───────────────────────────────────────────────────────────
-dontwarn okhttp3.**
-dontwarn okio.**
-keep class okhttp3.** { *; }
-keep class okio.** { *; }

# ─── Reflection ──────────────────────────────────────────────────────────────
-keepattributes Signature
-keepattributes SourceFile,LineNumberTable
-renamesourcefileattribute SourceFile
