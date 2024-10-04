package com.example.data_collector_catalog

import android.app.Activity
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.provider.Settings
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.Result


class NotiEventHandler(private val context: Context): EventChannel.StreamHandler, MethodChannel.MethodCallHandler {

    private var eventSink: EventChannel.EventSink? = null
    private var pendingResult: Result? = null

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        eventSink = NotiEventListenerService.eventSink
        eventSink = events
    }

    override fun onCancel(arguments: Any?) {
        eventSink = null
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "hasP" -> {
                result.success(isPermissionGranted(context))
            }
            "requestP" -> {
                pendingResult = result
                val intent = Intent(Settings.ACTION_NOTIFICATION_LISTENER_SETTINGS)
                val activityContext = context as? Activity
                activityContext?.startActivityForResult(intent, 1199)
            }
            else -> {
                result.notImplemented()
            }
        }
    }

    internal fun onActivityResult(requestCode: Int, resultCode: Int) {
        if (requestCode == 1199) {
            when (resultCode) {
                Activity.RESULT_OK -> {
                    pendingResult?.success(true)
                }
                Activity.RESULT_CANCELED -> {
                    pendingResult?.success(isPermissionGranted(context))
                }
                else -> {
                    pendingResult?.success(false)
                }
            }
        }
    }

    private fun isPermissionGranted(context: Context): Boolean {
        val packageName = context.packageName
        val flat = Settings.Secure.getString(context.contentResolver, "enabled_notification_listeners")

        if (!flat.isNullOrEmpty()) {
            val names = flat.split(":")
            for (name in names) {
                val componentName = ComponentName.unflattenFromString(name)
                val nameMatch = componentName?.packageName == packageName
                if (nameMatch) {
                    return true
                }
            }
        }
        return false
    }
}