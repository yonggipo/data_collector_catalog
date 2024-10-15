package com.example.data_collector_catalog

import android.content.Intent
import android.os.Bundle
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import java.lang.ref.WeakReference

class MainActivity : FlutterActivity() {
    private val luxEventHandler by lazy { LuxEventHandler(this) }
    private var notificationEventHandler: NotificationEventHandler? = null
    private var calendarObserver: CalendarObserver? = null
    private var screenEventHandler: ScreenEventHandler? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        Log.d("kane", "onCreate")
    }

    override fun onDestroy() {
        super.onDestroy()
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        notificationEventHandler?.onActivityResult(requestCode, resultCode)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        Log.d("kane", "configureFlutterEngine")
        calendarObserver = CalendarObserver()
        calendarObserver?.contextRef = WeakReference(this)
        notificationEventHandler = NotificationEventHandler()
        notificationEventHandler?.contextRef = WeakReference(this)
        screenEventHandler = ScreenEventHandler()
        screenEventHandler?.contextRef = WeakReference(this)

        EventChannel(flutterEngine.dartExecutor.binaryMessenger, "com.kane.calendar.event")
            .setStreamHandler(calendarObserver)

        EventChannel(flutterEngine.dartExecutor.binaryMessenger, "com.kane.light.event")
            .setStreamHandler(luxEventHandler)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.kane.light.method")
            .setMethodCallHandler(luxEventHandler)

        EventChannel(flutterEngine.dartExecutor.binaryMessenger, "com.kane.notification.event")
            .setStreamHandler(notificationEventHandler)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.kane.notification.method")
            .setMethodCallHandler(notificationEventHandler)

        EventChannel(flutterEngine.dartExecutor.binaryMessenger, "com.kane.screen.event")
            .setStreamHandler(screenEventHandler)
    }
}