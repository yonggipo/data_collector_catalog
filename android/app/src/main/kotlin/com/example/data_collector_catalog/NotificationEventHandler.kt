package com.example.data_collector_catalog

import android.app.Activity
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.provider.Settings
import android.util.Log
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.Result
import java.lang.ref.WeakReference


class NotificationEventHandler(): EventChannel.StreamHandler, MethodChannel.MethodCallHandler {

    companion object {
        var eventSink: EventChannel.EventSink? = null
    }

    var contextRef: WeakReference<Context>? = null
    private var pendingResult: Result? = null

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        eventSink = events
    }

    override fun onCancel(arguments: Any?) {
        eventSink = null
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        contextRef?.get()?.let { context ->
            when (call.method) {
                "hasPermission" -> {
                    result.success(isPermissionGranted(context))
                }
                "requestPermission" -> {
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
    }

    internal fun onActivityResult(requestCode: Int, resultCode: Int) {
        if (requestCode == 1199) {
            when (resultCode) {
                Activity.RESULT_OK -> {
                    pendingResult?.success(true)
                }
                Activity.RESULT_CANCELED -> {
                    contextRef?.get()?.let {
                        pendingResult?.success(isPermissionGranted(it))
                    }
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