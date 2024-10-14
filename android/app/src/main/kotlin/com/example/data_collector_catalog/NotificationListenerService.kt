package com.example.data_collector_catalog

import android.app.Notification
import android.service.notification.NotificationListenerService
import android.service.notification.StatusBarNotification

class NotificationListenerService: NotificationListenerService() {

    override fun onNotificationPosted(sbn: StatusBarNotification) {
        handleNotification(sbn, false)
    }

    override fun onNotificationRemoved(sbn: StatusBarNotification?) {
        sbn?.let { handleNotification(it, true) }
    }

    private fun handleNotification(sbn: StatusBarNotification, hasRemoved: Boolean) {
        val extras = sbn.notification.extras
        val packageName = sbn.packageName

        val data = hashMapOf<String, Any>(
            "id" to sbn.id,
            "packageName" to packageName,
            "title" to (extras.getCharSequence(Notification.EXTRA_TITLE)?.toString() ?: ""),
            "content" to (extras.getCharSequence(Notification.EXTRA_TEXT)?.toString() ?: ""),
        )

        NotificationEventHandler.eventSink?.success(data)
    }
}