package com.nexuswavetech.geetanexus.notification

import android.Manifest
import android.app.PendingIntent
import android.content.Intent
import android.content.pm.PackageManager
import android.util.Log
import androidx.core.app.ActivityCompat
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import com.google.firebase.messaging.FirebaseMessagingService
import com.google.firebase.messaging.RemoteMessage
import com.nexuswavetech.geetanexus.AppConfig
import com.nexuswavetech.geetanexus.MainActivity

/**
 * Firebase Cloud Messaging service.
 * Handles push notifications from Firebase — e.g. daily verse, spiritual reminders.
 */
class GeetaNexusFcmService : FirebaseMessagingService() {

    private val tag = "GeetaNexusFCM"

    override fun onNewToken(token: String) {
        super.onNewToken(token)
        Log.d(tag, "FCM token refreshed: ${token.take(20)}…")
        // In production: send token to Firestore for server-side push
        // Firebase.firestore.collection("fcm_tokens").document(uid).set(...)
    }

    override fun onMessageReceived(message: RemoteMessage) {
        super.onMessageReceived(message)

        val title   = message.notification?.title ?: message.data["title"] ?: "🪷 Gita Nexus"
        val body    = message.notification?.body  ?: message.data["body"]  ?: ""
        val verseId = message.data["verseId"]

        Log.d(tag, "FCM received: $title")
        showNotification(title, body)
    }

    private fun showNotification(title: String, body: String) {
        if (ActivityCompat.checkSelfPermission(
                this, Manifest.permission.POST_NOTIFICATIONS
            ) != PackageManager.PERMISSION_GRANTED
        ) return

        val intent = Intent(this, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK
        }
        val pendingIntent = PendingIntent.getActivity(
            this, 0, intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val notification = NotificationCompat.Builder(this, AppConfig.Notification.CHANNEL_ID)
            .setSmallIcon(android.R.drawable.ic_dialog_info)
            .setContentTitle(title)
            .setContentText(body)
            .setStyle(NotificationCompat.BigTextStyle().bigText(body))
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setContentIntent(pendingIntent)
            .setAutoCancel(true)
            .build()

        NotificationManagerCompat.from(this)
            .notify(System.currentTimeMillis().toInt(), notification)
    }
}
