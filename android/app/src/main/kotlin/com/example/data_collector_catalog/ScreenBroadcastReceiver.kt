package com.example.data_collector_catalog

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log
import org.json.JSONObject
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

class ScreenBroadcastReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        when (intent.action) {
            Intent.ACTION_SCREEN_ON -> {
                Log.d("ScreenBroadcastReceiver", "Screen ON")
                handleEvnet("on")
            }
            Intent.ACTION_SCREEN_OFF -> {
                Log.d("ScreenBroadcastReceiver", "Screen OFF")
                handleEvnet("off")
            }
            Intent.ACTION_USER_PRESENT -> {
                Log.d("ScreenBroadcastReceiver", "User Present")
                handleEvnet("unlocked")
            }
        }
    }

    private fun handleEvnet(state: String) {
        val formatter = SimpleDateFormat("yyyy-MM-dd HH:mm:ss", Locale.getDefault())
        val currentTime = formatter.format(Date())

        val data: Map<String, Any> = mapOf(
            "screenState" to state,
            "timeStamp" to currentTime
        )
        val jsonData = JSONObject(data).toString()
        ScreenEventHandler.eventSink?.success(jsonData)
    }
}
