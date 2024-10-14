package com.example.data_collector_catalog

import android.content.Context
import android.database.ContentObserver
import android.net.Uri
import android.os.Handler
import android.os.HandlerThread
import android.os.Looper
import android.util.Log
import io.flutter.plugin.common.EventChannel
import java.lang.ref.WeakReference

class CalendarObserver() : EventChannel.StreamHandler, AutoCloseable {

    companion object {
        val URI: Uri = Uri.parse("content://com.android.calendar/events")
    }

    var contextRef: WeakReference<Context>? = null
    private var eventSink: EventChannel.EventSink? = null
    private var backgroundHandler: Handler? = null
    private var handlerThread: HandlerThread? = null
    private var contentObserver: ContentObserver? = null

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        Log.d("CalendarObserver", "Start to observe the calendar")
        eventSink = events

        if (handlerThread == null) {
            handlerThread = HandlerThread("CalendarObserverThread").apply { start() }
            handlerThread?.looper?.let { looper ->
                backgroundHandler = Handler(looper)
            }
        }

        contentObserver = object : ContentObserver(backgroundHandler) {
            override fun onChange(selfChange: Boolean) {
                super.onChange(selfChange)
                Log.d("CalendarObserver", "Calendar has been changed")

                Handler(Looper.getMainLooper()).post {
                    eventSink?.success(null)
                }
            }
        }

        contentObserver?.let { contentObserver ->
            contextRef?.get()?.contentResolver?.registerContentObserver(URI, true, contentObserver)
        }
    }

    override fun onCancel(arguments: Any?) {
        eventSink = null
        handlerThread?.quitSafely()
        contextRef?.get()?.contentResolver?.run {
            contentObserver?.let { contentObserver ->
                unregisterContentObserver(contentObserver)
            }
        }
    }

    override fun close() {
        Log.d("CalendarObserver", "End to observe the calendar")
    }
}