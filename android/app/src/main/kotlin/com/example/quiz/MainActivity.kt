package com.example.quiz

import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.view.WindowManager

class MainActivity : FlutterActivity() {
    private val shareChannel = "quiz/share"
    private val securityChannel = "quiz/security"
    private var securityMethodChannel: MethodChannel? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, shareChannel).setMethodCallHandler { call, result ->
            if (call.method != "shareText") {
                result.notImplemented()
                return@setMethodCallHandler
            }

            val text = call.argument<String>("text").orEmpty()
            val subject = call.argument<String>("subject").orEmpty()
            if (text.isBlank()) {
                result.error("empty_text", "Nothing to share", null)
                return@setMethodCallHandler
            }

            val sendIntent = Intent(Intent.ACTION_SEND).apply {
                type = "text/plain"
                putExtra(Intent.EXTRA_TEXT, text)
                if (subject.isNotBlank()) {
                    putExtra(Intent.EXTRA_SUBJECT, subject)
                }
            }
            startActivity(Intent.createChooser(sendIntent, subject.ifBlank { "Share" }))
            result.success(null)
        }
        securityMethodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, securityChannel)
        securityMethodChannel?.setMethodCallHandler { call, result ->
            when (call.method) {
                "setScreenshotBlocked" -> {
                    val blocked = call.argument<Boolean>("blocked") ?: false
                    runOnUiThread {
                        if (blocked) {
                            window.setFlags(
                                WindowManager.LayoutParams.FLAG_SECURE,
                                WindowManager.LayoutParams.FLAG_SECURE
                            )
                        } else {
                            window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
                        }
                    }
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }

    override fun onWindowFocusChanged(hasFocus: Boolean) {
        super.onWindowFocusChanged(hasFocus)
        securityMethodChannel?.invokeMethod(
            "windowFocusChanged",
            mapOf("hasFocus" to hasFocus)
        )
    }
}
