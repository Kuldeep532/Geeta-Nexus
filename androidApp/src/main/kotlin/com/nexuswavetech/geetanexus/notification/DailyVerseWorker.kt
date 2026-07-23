package com.nexuswavetech.geetanexus.notification

import android.Manifest
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import androidx.core.app.ActivityCompat
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import androidx.work.CoroutineWorker
import androidx.work.WorkerParameters
import com.nexuswavetech.geetanexus.AppConfig
import com.nexuswavetech.geetanexus.MainActivity
import com.nexuswavetech.geetanexus.data.remote.GitaRemoteDataSource
import com.nexuswavetech.geetanexus.network.CloudflareGatewayClient
import com.nexuswavetech.geetanexus.network.SignatureProvider
import java.time.LocalDate

/**
 * WorkManager worker that fetches the daily verse and shows a notification.
 * Runs once per day (scheduled in GeetaNexusApp).
 */
class DailyVerseWorker(
    private val context: Context,
    params: WorkerParameters
) : CoroutineWorker(context, params) {

    override suspend fun doWork(): Result {
        return try {
            // Fetch today's verse
            val signer = SignatureProvider()
            val gateway = CloudflareGatewayClient(signer)
            val remote = GitaRemoteDataSource(gateway)

            val dayOfYear = LocalDate.now().dayOfYear
            val chapterNum = (dayOfYear % 18) + 1
            val verses = remote.fetchVerses(chapterNum)

            if (verses.isEmpty()) return Result.success()

            val verse = verses[dayOfYear % verses.size]
            val preview = verse.translation
                ?.take(100)
                ?.let { if (it.length == 100) "$it…" else it }
                ?: verse.text.take(80)

            showNotification(
                title   = "🪷 Daily Verse — BG ${verse.chapter_number}.${verse.verse_number}",
                message = preview
            )

            gateway.close()
            Result.success()
        } catch (e: Exception) {
            showNotification(
                title   = "🪷 Daily Verse",
                message = "\"You have a right to perform your duties, but not to the fruits of your actions.\" — BG 2.47"
            )
            Result.success()
        }
    }

    private fun showNotification(title: String, message: String) {
        if (ActivityCompat.checkSelfPermission(
                context, Manifest.permission.POST_NOTIFICATIONS
            ) != PackageManager.PERMISSION_GRANTED
        ) return

        val intent = Intent(context, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK
        }
        val pendingIntent = PendingIntent.getActivity(
            context, 0, intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val notification = NotificationCompat.Builder(context, AppConfig.Notification.CHANNEL_ID)
            .setSmallIcon(android.R.drawable.ic_dialog_info)
            .setContentTitle(title)
            .setContentText(message)
            .setStyle(NotificationCompat.BigTextStyle().bigText(message))
            .setPriority(NotificationCompat.PRIORITY_DEFAULT)
            .setContentIntent(pendingIntent)
            .setAutoCancel(true)
            .build()

        NotificationManagerCompat.from(context)
            .notify(AppConfig.Notification.CHANNEL_ID.hashCode(), notification)
    }
}
