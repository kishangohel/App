package world.verifi.app

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Context
import android.os.Build
import androidx.core.app.NotificationCompat

object Notifications {
    const val CHANNEL_ID_VERIFI_FOREGROUND_SERVICE = "verifi_foreground_service"

    fun createNotificationChannel(ctx: Context) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID_VERIFI_FOREGROUND_SERVICE,
                "VeriFi Auto Connect Service",
                NotificationManager.IMPORTANCE_LOW
            )
            val manager = ctx.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            manager.createNotificationChannel(channel)
        }
    }

    fun buildForegroundNotification(ctx: Context): Notification {
        return NotificationCompat.Builder(ctx, CHANNEL_ID_VERIFI_FOREGROUND_SERVICE)
            .setSmallIcon(R.mipmap.ic_launcher)
            .setContentTitle("VeriFi Auto-Connect")
            .setContentText("Looking for WiFi connections near you")
            .build()
    }
}
