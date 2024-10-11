package com.example.data_collector_catalog

import android.content.Intent
import android.os.Bundle
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val luxEventHandler by lazy { LuxEventHandler(this) }
    private val notiEventHandler by lazy { NotiEventHandler(this) }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        Log.d("kane", "onCreate")
    }

    override fun onDestroy() {
        super.onDestroy()
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        notiEventHandler.onActivityResult(requestCode, resultCode)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        Log.d("kane", "configureFlutterEngine")

        EventChannel(flutterEngine.dartExecutor.binaryMessenger, "com.kane.light_sensor_plugin.event")
            .setStreamHandler(luxEventHandler)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.kane.light_sensor_plugin.method")
            .setMethodCallHandler(luxEventHandler)
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, "com.kane.noti_detector_plugin.event")
            .setStreamHandler(notiEventHandler)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.kane.noti_detector_plugin.method")
            .setMethodCallHandler(notiEventHandler)
    }
}