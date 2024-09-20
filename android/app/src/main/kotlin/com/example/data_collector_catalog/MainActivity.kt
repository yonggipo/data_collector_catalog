package com.example.data_collector_catalog

import android.view.KeyEvent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel

class MainActivity: FlutterActivity() {
    private var KEYSTOKE_EVENT_CHANNEL = "keystroke_event_channel"
    private var keyEventSink: EventChannel.EventSink? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
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



