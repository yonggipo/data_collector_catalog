package com.example.data_collector_catalog

import android.accessibilityservice.AccessibilityService
import android.content.pm.ApplicationInfo
import android.content.pm.PackageManager
import android.os.Build
import android.util.Log
import android.view.accessibility.AccessibilityEvent
import org.json.JSONObject


class ApplicationAccessibilityService : AccessibilityService() {
    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        val regex = Regex("""EventType:\s*([A-Z_]+)""")
        val matchResult = regex.find(event.toString())
        val type = matchResult?.groups?.get(1)?.value ?: "TYPE_UNDEFINED"

        val packageName = event?.packageName?.toString()
        val packageManager = this.packageManager
        packageName?.let {
            try {
                val appInfo =
                    packageManager.getApplicationInfo(packageName, PackageManager.GET_META_DATA)
                val appName = packageManager.getApplicationLabel(appInfo).toString()
                val isSystemApp = (appInfo.flags and ApplicationInfo.FLAG_SYSTEM) != 0
                val isUpdatedSystemApp =
                    (appInfo.flags and ApplicationInfo.FLAG_UPDATED_SYSTEM_APP) != 0
                val category = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                    when (appInfo.category) {
                        ApplicationInfo.CATEGORY_AUDIO -> "CATEGORY_AUDIO"
                        ApplicationInfo.CATEGORY_GAME -> "CATEGORY_GAME"
                        ApplicationInfo.CATEGORY_IMAGE -> "CATEGORY_IMAGE"
                        ApplicationInfo.CATEGORY_MAPS -> "CATEGORY_MAPS"
                        ApplicationInfo.CATEGORY_NEWS -> "CATEGORY_NEWS"
                        ApplicationInfo.CATEGORY_PRODUCTIVITY -> "CATEGORY_PRODUCTIVITY"
                        ApplicationInfo.CATEGORY_SOCIAL -> "CATEGORY_SOCIAL"
                        ApplicationInfo.CATEGORY_VIDEO -> "CATEGORY_VIDEO"
                        ApplicationInfo.CATEGORY_UNDEFINED -> "CATEGORY_UNDEFINED"
                        else -> "CATEGORY_UNDEFINED"
                    }
                } else {
                    appInfo.metaData?.getString("app_category") ?: "CATEGORY_UNDEFINED"
                }


                val data: Map<String, Any> = mapOf(
                    "packageName" to packageName,
                    "type" to type,
                    "appName" to appName,
                    "isSystemApp" to isSystemApp,
                    "isUpdatedSystemApp" to isUpdatedSystemApp,
                    "category" to category
                )
                val jsonData = JSONObject(data).toString()
                ApplicationEventHandler.eventSink?.success(jsonData)
            } catch (e: Exception) {
                Log.e("ApplicationAccessibilityService", "Error occurred: ${e.message}")
            }
        }
    }

    override fun onInterrupt() {
        // Handle interruption if necessary
    }
}