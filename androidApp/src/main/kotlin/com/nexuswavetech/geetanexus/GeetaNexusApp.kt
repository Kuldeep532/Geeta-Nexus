package com.nexuswavetech.geetanexus

import android.app.Application
import android.app.NotificationChannel
import android.app.NotificationManager
import android.os.Build
import android.util.Log
import androidx.work.*
import com.nexuswavetech.geetanexus.data.FirebaseManager
import com.nexuswavetech.geetanexus.di.androidModule
import com.nexuswavetech.geetanexus.di.sharedModule
import com.nexuswavetech.geetanexus.notification.DailyVerseWorker
import org.koin.android.ext.koin.androidContext
import org.koin.core.context.startKoin
import java.util.concurrent.TimeUnit

class GeetaNexusApp : Application() {

    override fun onCreate() {
        super.onCreate()

        // ── 1. Inject signing key from BuildConfig (CI/CD secret) ─────────────
        AppConfig.ED25519_PRIVATE_KEY_BASE64 = BuildConfig.ED25519_PRIVATE_KEY
        AppConfig.GOOGLE_WEB_CLIENT_ID       = BuildConfig.GOOGLE_WEB_CLIENT_ID

        // ── 2. Initialize Firebase (programmatic — no google-services.json) ────
        FirebaseManager.initialize(this)

        // ── 3. Dependency Injection ───────────────────────────────────────────
        startKoin {
            androidContext(this@GeetaNexusApp)
            modules(sharedModule, androidModule)
        }

        // ── 4. Notification channel ───────────────────────────────────────────
        createNotificationChannel()

        // ── 5. Schedule daily verse notification ──────────────────────────────
        scheduleDailyVerseWorker()

        Log.i("GeetaNexusApp", "App initialized. Firebase: ${FirebaseManager.isInitialized}")
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                AppConfig.Notification.CHANNEL_ID,
                AppConfig.Notification.CHANNEL_NAME,
                NotificationManager.IMPORTANCE_DEFAULT
            ).apply {
                description = AppConfig.Notification.CHANNEL_DESC
            }
            getSystemService(NotificationManager::class.java)
                .createNotificationChannel(channel)
        }
    }

    private fun scheduleDailyVerseWorker() {
        val workManager = WorkManager.getInstance(this)

        // Calculate initial delay to next 7:00 AM
        val constraints = Constraints.Builder()
            .setRequiredNetworkType(NetworkType.CONNECTED)
            .build()

        val periodicRequest = PeriodicWorkRequestBuilder<DailyVerseWorker>(1, TimeUnit.DAYS)
            .setConstraints(constraints)
            .addTag(AppConfig.Notification.WORK_TAG)
            .build()

        workManager.enqueueUniquePeriodicWork(
            AppConfig.Notification.WORK_TAG,
            ExistingPeriodicWorkPolicy.KEEP,
            periodicRequest
        )
    }
}
