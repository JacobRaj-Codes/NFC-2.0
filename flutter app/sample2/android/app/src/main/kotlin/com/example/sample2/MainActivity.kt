package com.example.sample2

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine // Add this import
import io.flutter.plugin.common.MethodChannel
import android.content.Intent

class MainActivity : FlutterActivity() {
    private val CHANNEL = "nfc_launch_channel"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "getLaunchIntentAction") {
                val action = intent.action // Get the action that launched the app
                result.success(action)
            } else {
                result.notImplemented()
            }
        }
    }
}