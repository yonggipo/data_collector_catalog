package com.example.data_collector_catalog

import android.content.ContentValues.TAG
import android.content.Context
import android.content.Intent
import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import android.os.Build
import android.util.Log
import android.view.KeyEvent
import androidx.annotation.RequiresApi
import androidx.core.app.ServiceCompat.startForeground
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.EventChannel.EventSink
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import java.lang.reflect.Method

class MainActivity: FlutterActivity() {
    private var KEYSTOKE_EVENT_CHANNEL = "keystroke_event_channel"
    private var keyEventSink: EventChannel.EventSink? = null

    @RequiresApi(Build.VERSION_CODES.O)
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        startForegroundService(Intent(this@MainActivity, LightSensorService::class.java))

        val util = LightSensorUtil()
        util.init(flutterEngine)

        EventChannel(flutterEngine.dartExecutor.binaryMessenger, KEYSTOKE_EVENT_CHANNEL).setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    keyEventSink = events
                }

                override fun onCancel(arguments: Any?) {
                    keyEventSink = null
                }
            }
        )
    }

    override fun onKeyDown(keyCode: Int, event: KeyEvent?): Boolean {
        val keyEvent = keyCode // event?.keyCharacterMap?.getNumber(keyCode)
        keyEventSink?.success(keyEvent)
        return super.onKeyDown(keyCode, event)
    }
}

class LightSensorUtil : EventChannel.StreamHandler, MethodCallHandler {
    private var EVENT_CHANNEL: String = "com.kane.light_sensor.stream"
    private var METHOD_CHANNEL: String = "com.kane.light_sensor"

    private var sensorEventListener: SensorEventListener? = null
    private var eventChannel: EventChannel? = null
    private var sensorChannel: MethodChannel? = null

    fun init(flutterEngine: FlutterEngine) {
        /// Init event channel
        val binaryMessenger: BinaryMessenger = flutterEngine.dartExecutor.binaryMessenger
        eventChannel = EventChannel(binaryMessenger, EVENT_CHANNEL)
        eventChannel?.setStreamHandler(this)
        sensorChannel = MethodChannel(binaryMessenger, METHOD_CHANNEL)
        sensorChannel?.setMethodCallHandler(this)
    }

    fun deinit() {
        eventChannel?.setStreamHandler(null)
    }

    private fun createSensorEventListener(events: EventSink): SensorEventListener {
        return object : SensorEventListener {
            override fun onAccuracyChanged(sensor: Sensor, accuracy: Int) {
                /// Do nothing
            }

            override fun onSensorChanged(event: SensorEvent) {
                /// Extract lux value and send it to Flutter via the event sink
                val lux = event.values[0].toInt()
                events.success(lux)
            }
        }
    }

    override fun onListen(arguments: Any?, events: EventSink) {
        /// Set up the event sensor for the light sensor
        Log.d(TAG, "onListen called with arguments: $arguments")
        sensorEventListener = createSensorEventListener(events)
        LightSensorService.sensorManager?.registerListener(
            sensorEventListener,
            LightSensorService.sensor,
            SensorManager.SENSOR_DELAY_NORMAL
        )
    }

    override fun onCancel(arguments: Any?) { // null을 보낼 경우 옵셔널로 바꿔줘야 함
        /// Finish listening to events
        LightSensorService.sensorManager?.unregisterListener(sensorEventListener)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        if (call.method == "sensor") {
            Log.d(TAG, "onMethodCall")
            result.success(LightSensorService.sensor != null)
        } else {
            result.notImplemented()
        }
    }
}