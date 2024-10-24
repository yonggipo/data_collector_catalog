package com.example.data_collector_catalog

import android.Manifest
import android.bluetooth.BluetoothDevice
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import android.util.Log
import androidx.core.app.ActivityCompat
import org.json.JSONObject
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale


class BluetoothBroadcastReceiver: BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val permissionCheck = ActivityCompat.checkSelfPermission(context, Manifest.permission.BLUETOOTH_CONNECT)
        val isGranted = permissionCheck == PackageManager.PERMISSION_GRANTED
        if (!isGranted) { return }

//        if (BluetoothDevice.ACTION_FOUND == intent.action) {
//            val rssi = intent.getShortExtra(BluetoothDevice.EXTRA_RSSI, Short.MIN_VALUE).toInt()
//            Log.d("BluetoothBroadcastReceiver", "ACTION_FOUND RSSI: $rssi dBm")
//        }

        if (BluetoothDevice.ACTION_ACL_CONNECTED == intent.action) {
            var device :BluetoothDevice? = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                intent.getParcelableExtra(BluetoothDevice.EXTRA_DEVICE, BluetoothDevice::class.java)
            } else {
                intent.getParcelableExtra(BluetoothDevice.EXTRA_DEVICE) as? BluetoothDevice
            }
            val rssi = intent.getShortExtra(BluetoothDevice.EXTRA_RSSI, Short.MIN_VALUE).toInt()
            Log.d("BluetoothBroadcastReceiver", "ACTION_ACL_CONNECTED RSSI: $rssi dBm")
            Log.d("BluetoothBroadcastReceiver", "ACTION_ACL_CONNECTED ${device?.name}")
            device?.let {
                handleEvnet(context,"CONNECTED", it, rssi)
            }
        }

        if (BluetoothDevice.ACTION_ACL_DISCONNECTED == intent.action) {
            var device :BluetoothDevice? = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                intent.getParcelableExtra(BluetoothDevice.EXTRA_DEVICE, BluetoothDevice::class.java)
            } else {
                intent.getParcelableExtra(BluetoothDevice.EXTRA_DEVICE) as? BluetoothDevice
            }
            val rssi = intent.getShortExtra(BluetoothDevice.EXTRA_RSSI, Short.MIN_VALUE).toInt()
            Log.d("BluetoothBroadcastReceiver", "ACTION_ACL_DISCONNECTED RSSI: $rssi dBm")
            Log.d("BluetoothBroadcastReceiver", "ACTION_ACL_DISCONNECTED ${device?.name}")
            device?.let {
                handleEvnet(context,"DISCONNECTED", it, rssi)
            }
        }

//        if (BluetoothAdapter.ACTION_CONNECTION_STATE_CHANGED == intent.action) {
//            var state = intent.getIntExtra(BluetoothAdapter.EXTRA_CONNECTION_STATE, BluetoothAdapter.STATE_DISCONNECTED)
//            val rssi = intent.getShortExtra(BluetoothDevice.EXTRA_RSSI, Short.MIN_VALUE).toInt()
//            Log.d("BluetoothBroadcastReceiver", "ACTION_CONNECTION_STATE_CHANGED RSSI: $rssi dBm")
//            Log.d("BluetoothBroadcastReceiver", "ACTION_CONNECTION_STATE_CHANGED ${state}")
//        }
    }

    private fun handleEvnet(context: Context, state: String, device: BluetoothDevice, rssi: Int) {
        val permissionCheck = ActivityCompat.checkSelfPermission(context, Manifest.permission.BLUETOOTH_CONNECT)
        val isGranted = permissionCheck == PackageManager.PERMISSION_GRANTED
        if (!isGranted) { return }

        val formatter = SimpleDateFormat("yyyy-MM-dd HH:mm:ss", Locale.getDefault())
        val currentTime = formatter.format(Date())

        val data: Map<String, Any> = mapOf(
            "state" to state,
            "name" to device.name,
            "address" to device.address,
            "cod" to device.bluetoothClass.deviceClass,
            "majorClass" to device.bluetoothClass.majorDeviceClass,
            "rssi" to rssi,
            "timestamp" to currentTime
        )

        val jsonData = JSONObject(data).toString()
        BluetoothEventHandler.eventSink?.success(jsonData)
    }
}
