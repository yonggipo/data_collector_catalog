package com.example.data_collector_catalog

import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import androidx.core.content.ContextCompat
import io.flutter.plugin.common.EventChannel
import java.lang.ref.WeakReference


class ScreenEventHandler(): EventChannel.StreamHandler {

    companion object {
        var eventSink: EventChannel.EventSink? = null
    }

    private var screenReceiver: ScreenBroadcastReceiver? = null;
    var contextRef: WeakReference<Context>? = null

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        contextRef?.get()?.let {
            eventSink = events
            val screenReceiver = ScreenBroadcastReceiver()
            val intentFilter = IntentFilter().apply {
                addAction(Intent.ACTION_SCREEN_ON)
                addAction(Intent.ACTION_SCREEN_OFF)
                addAction(Intent.ACTION_USER_PRESENT)
            }
            ContextCompat.registerReceiver(
                it,
                screenReceiver,
                intentFilter,
                ContextCompat.RECEIVER_EXPORTED
            )
        }
    }

    override fun onCancel(arguments: Any?) {
        eventSink = null
        screenReceiver = null
    }
}
