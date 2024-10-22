package com.example.data_collector_catalog

import android.bluetooth.BluetoothAdapter
import android.content.Context
import android.util.Log
import io.flutter.plugin.common.EventChannel
import java.lang.ref.WeakReference


class BluetoothEventHandler: EventChannel.StreamHandler {
    companion object {
        var eventSink: EventChannel.EventSink? = null
    }

    private var bluetoothReceiver: BluetoothBroadcastReceiver? = null;
    var contextRef: WeakReference<Context>? = null

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        Log.d("BluetoothEventHandler", "Start to listen bluetooth event")
        bluetoothReceiver = BluetoothBroadcastReceiver()
        eventSink = events
    }

    override fun onCancel(arguments: Any?) {
        Log.d("BluetoothEventHandler", "End to listen bluetooth event")
        bluetoothReceiver = null
        eventSink = null
    }
}