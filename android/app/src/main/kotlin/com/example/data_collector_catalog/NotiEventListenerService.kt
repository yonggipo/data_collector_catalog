package com.example.data_collector_catalog

import android.app.Notification
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.drawable.BitmapDrawable
import android.graphics.drawable.Drawable
import android.os.Bundle
import android.service.notification.NotificationListenerService
import android.service.notification.StatusBarNotification
import android.util.Log
import io.flutter.plugin.common.EventChannel
import java.io.ByteArrayOutputStream

class NotiEventListenerService: NotificationListenerService() {

    companion object {
        var eventSink: EventChannel.EventSink? = null
    }

    override fun onNotificationPosted(sbn: StatusBarNotification) {
        val extras = sbn.notification.extras
        val packageName = sbn.packageName

        val data = hashMapOf<String, Any>(
            "id" to sbn.id,
            "packageName" to packageName,
            "notificationIcon" to (getAppIcon(packageName) ?: ByteArray(0)),
            "largeIcon" to (getLargeIcon(sbn) ?: ByteArray(0)),
            "title" to (extras.getCharSequence(Notification.EXTRA_TITLE)?.toString() ?: ""),
            "content" to (extras.getCharSequence(Notification.EXTRA_TEXT)?.toString() ?: ""),
            "haveExtraPicture" to extras.containsKey(Notification.EXTRA_PICTURE)
        )

        extras.getExtraPicture()?.let { bitmap ->
            data["notificationExtrasPicture"] = bitmap.toByteArray()
        }

        eventSink?.success(data)
    }

    private fun getLargeIcon(sbn: StatusBarNotification): ByteArray? {
        return try {
            val iconDrawable = sbn.notification.getLargeIcon()?.loadDrawable(applicationContext) ?: run {
                Log.d("kane", "[noti-getLargeIcon]: can not found context")
                return null
            }
            val iconBitmap = when (iconDrawable) {
                is BitmapDrawable -> iconDrawable.bitmap
                else -> getBitmapFromDrawable(iconDrawable)
            }
            iconBitmap.toByteArray()
        } catch (e: Exception) {
            Log.d("kane", "[noti-getLargeIcon]: ${e.message}")
            e.printStackTrace()
            null
        }
    }

    private fun getAppIcon(packageName: String): ByteArray? {
        return try {
            val manager = baseContext.packageManager
            val icon = manager.getApplicationIcon(packageName)
            val stream = ByteArrayOutputStream()
            getBitmapFromDrawable(icon).compress(Bitmap.CompressFormat.PNG, 100, stream)
            stream.toByteArray()
        } catch (e: PackageManager.NameNotFoundException) {
            e.printStackTrace()
            null
        }
    }

    private fun Bitmap.toByteArray(): ByteArray {
        return ByteArrayOutputStream().use { stream ->
            compress(Bitmap.CompressFormat.PNG, 100, stream)
            stream.toByteArray()
        }
    }

    private fun Bundle.getExtraPicture(): Bitmap? {
        return if (containsKey(Notification.EXTRA_PICTURE)) {
            get(Notification.EXTRA_PICTURE) as? Bitmap
        } else null
    }

    private fun getBitmapFromDrawable(drawable: Drawable): Bitmap {
        val bitmap = Bitmap.createBitmap(
            drawable.intrinsicWidth,
            drawable.intrinsicHeight,
            Bitmap.Config.ARGB_8888
        )
        val canvas = Canvas(bitmap)
        drawable.setBounds(0, 0, canvas.width, canvas.height)
        drawable.draw(canvas)
        return bitmap
    }
}