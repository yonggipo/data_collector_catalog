package com.example.data_collector_catalog

import android.app.Notification
import android.service.notification.NotificationListenerService
import android.service.notification.StatusBarNotification
import android.util.Log
import org.json.JSONObject

class NotificationListenerService: NotificationListenerService() {

    override fun onNotificationPosted(sbn: StatusBarNotification) {
        Log.d("NotificationListenerService", "Notification has been posted")
        handleNotification(sbn, false)
    }

    override fun onNotificationRemoved(sbn: StatusBarNotification?) {
        Log.d("NotificationListenerService", "Notification has been removed")
        sbn?.let { handleNotification(it, true) }
    }

    private fun handleNotification(sbn: StatusBarNotification, hasRemoved: Boolean) {
        val extras = sbn.notification.extras
        val packageName = sbn.packageName

        val data: Map<String, Any> = mapOf(
            "id" to sbn.id,
            "packageName" to packageName,
            "title" to (extras.getCharSequence(Notification.EXTRA_TITLE)?.toString() ?: ""),
            "content" to (extras.getCharSequence(Notification.EXTRA_TEXT)?.toString() ?: ""),
            "hasRemoved" to hasRemoved
        )
        val jsonData = JSONObject(data).toString()
        NotificationEventHandler.eventSink?.success(jsonData)
    }
}