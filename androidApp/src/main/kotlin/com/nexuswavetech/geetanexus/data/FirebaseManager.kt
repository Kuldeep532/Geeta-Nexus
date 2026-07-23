package com.nexuswavetech.geetanexus.data

import android.content.Context
import android.util.Log
import com.google.firebase.FirebaseApp
import com.google.firebase.FirebaseOptions
import com.nexuswavetech.geetanexus.BuildConfig

/**
 * Initializes Firebase programmatically — no google-services.json committed to repo.
 *
 * Firebase config values are injected at build time via CI/CD secrets (GitHub Actions)
 * as BuildConfig fields. They are NEVER hardcoded or stored in source control.
 *
 * Required CI/CD secrets:
 *   FIREBASE_API_KEY       → Firebase web API key
 *   FIREBASE_APP_ID        → Firebase Android App ID (1:xxx:android:xxx)
 *   FIREBASE_GCM_SENDER_ID → GCM / FCM Sender ID (numeric)
 */
object FirebaseManager {

    private const val TAG = "FirebaseManager"
    private var initialized = false

    /**
     * Initialize Firebase with config from BuildConfig.
     * Call this once in Application.onCreate() before any Firebase usage.
     *
     * @return true if initialized successfully, false if config is missing.
     */
    fun initialize(context: Context): Boolean {
        if (initialized) return true
        if (FirebaseApp.getApps(context).isNotEmpty()) {
            initialized = true
            return true
        }

        val apiKey    = BuildConfig.FIREBASE_API_KEY
        val appId     = BuildConfig.FIREBASE_APP_ID
        val senderId  = BuildConfig.FIREBASE_GCM_SENDER_ID
        val projectId = BuildConfig.FIREBASE_PROJECT_ID
        val bucket    = BuildConfig.FIREBASE_STORAGE_BUCKET

        if (apiKey.isBlank() || appId.isBlank()) {
            Log.w(TAG, "Firebase config missing. Skipping init. " +
                "Set FIREBASE_API_KEY and FIREBASE_APP_ID in CI/CD secrets.")
            return false
        }

        return try {
            val options = FirebaseOptions.Builder()
                .setApiKey(apiKey)
                .setApplicationId(appId)
                .setGcmSenderId(senderId.takeIf { it.isNotBlank() })
                .setProjectId(projectId)
                .setStorageBucket(bucket)
                .build()

            FirebaseApp.initializeApp(context, options)
            initialized = true
            Log.i(TAG, "Firebase initialized for project: $projectId")
            true
        } catch (e: Exception) {
            Log.e(TAG, "Firebase initialization failed", e)
            false
        }
    }

    val isInitialized: Boolean get() = initialized
}
