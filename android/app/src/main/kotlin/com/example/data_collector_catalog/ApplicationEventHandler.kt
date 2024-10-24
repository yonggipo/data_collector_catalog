package com.example.data_collector_catalog

import android.app.Activity
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.provider.Settings
import android.text.TextUtils
import android.util.Log
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.Result
import java.lang.ref.WeakReference

class ApplicationEventHandler: EventChannel.StreamHandler,
MethodChannel.MethodCallHandler {
    companion object {
        var eventSink: EventChannel.EventSink? = null
    }

    private var accessibilityService: ApplicationAccessibilityService? = null;
    var contextRef: WeakReference<Context>? = null
    private var pendingResult: Result? = null

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        Log.d("ApplicationEventHandler", "Start to listen application event")
        accessibilityService = ApplicationAccessibilityService()
        eventSink = events
    }

    override fun onCancel(arguments: Any?) {
        Log.d("ApplicationEventHandler", "End to listen application event")
        accessibilityService = null
        eventSink = null
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        contextRef?.get()?.let { context ->
            when (call.method) {
                "hasPermission" -> {
                    val isGranted = isPermissionGranted(context)
                    Log.d("ApplicationEventHandler", "isGranted: $isGranted")
                    result.success(isGranted)
                }
                "requestPermission" -> {
                    pendingResult = result
                    val intent = Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS)
                    val activity = context as? Activity
                    activity?.startActivityForResult(intent, 1200)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    internal fun onActivityResult(requestCode: Int, resultCode: Int) {
        if (requestCode == 1200) {
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
        val enabledServices = Settings.Secure.getString(context.contentResolver, Settings.Secure.ENABLED_ACCESSIBILITY_SERVICES)
        if (enabledServices.isNullOrEmpty()) { return false }
        Log.d("ApplicationEventHandler","enabledServices: $enabledServices")
        val colonSplitter = TextUtils.SimpleStringSplitter(':')
        colonSplitter.setString(enabledServices)
        while (colonSplitter.hasNext()) {
            val componentName = ComponentName.unflattenFromString(colonSplitter.next())
            Log.d("ApplicationEventHandler","componentName.packageName: ${componentName?.packageName}")
            Log.d("ApplicationEventHandler","packageName: $packageName")
            if (componentName?.packageName.equals(packageName, ignoreCase = true)) {
                return true
            }
        }
        return false
    }
}