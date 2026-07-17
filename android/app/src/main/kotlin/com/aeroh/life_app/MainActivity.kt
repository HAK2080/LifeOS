package com.aeroh.life_app

import android.content.Intent
import android.os.Build
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterFragmentActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "lifeos/health_connect",
        ).setMethodCallHandler { call, result ->
            if (call.method != "openSettings") {
                result.notImplemented()
                return@setMethodCallHandler
            }
            try {
                val action = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
                    "android.health.connect.action.MANAGE_HEALTH_PERMISSIONS"
                } else {
                    "androidx.health.ACTION_HEALTH_CONNECT_SETTINGS"
                }
                val intent = Intent(action)
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
                    intent.putExtra(Intent.EXTRA_PACKAGE_NAME, packageName)
                }
                startActivity(intent)
                result.success(true)
            } catch (_: Exception) {
                result.success(false)
            }
        }
    }
}
