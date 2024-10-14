package com.example.data_collector_catalog

import android.content.Context
import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import android.util.Log
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.Result

class LuxEventHandler(private val context: Context) : EventChannel.StreamHandler,
    MethodChannel.MethodCallHandler {
    private var sensorEventListener: SensorEventListener? = null
    private val sensorManager: SensorManager by lazy {
        context.getSystemService(Context.SENSOR_SERVICE) as SensorManager
    }
    private val sensor: Sensor? by lazy { sensorManager.getDefaultSensor(Sensor.TYPE_LIGHT) }
    private var eventSink: EventChannel.EventSink? = null

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        eventSink = events
        sensorEventListener = createSensorEventListener()
        sensorManager.registerListener(sensorEventListener, sensor, SensorManager.SENSOR_DELAY_NORMAL)
    }

    override fun onCancel(arguments: Any?) {
        sensorManager.unregisterListener(sensorEventListener)
        eventSink = null
    }

    private fun createSensorEventListener(): SensorEventListener {
        return object : SensorEventListener {
            override fun onAccuracyChanged(sensor: Sensor, accuracy: Int) {
                // Do nothing
            }

            override fun onSensorChanged(event: SensorEvent) {
                val lux = event.values[0].toInt()
                Log.d("LuxEventHandler", "Light has been changed: $lux")
                eventSink?.success(lux)
            }
        }
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        if (call.method == "sensor") {
            result.success(sensor != null)
        } else {
            result.notImplemented()
        }
    }
}