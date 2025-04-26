package com.hontouniyuki.kanada

import android.media.MediaMetadataRetriever
import android.util.Log
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.hontouniyuki.kanada/method"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        Log.d("MainActivity", "MethodChannel registered")
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getAlbumArt" -> {
                    val filePath = call.argument<String>("filePath")
                    val albumArt = getAlbumArt(filePath)
                    if (albumArt != null) {
                        result.success(albumArt)
                    } else {
                        result.error("404", "封面不存在", null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun getAlbumArt(filePath: String?): ByteArray? {
        if (filePath.isNullOrEmpty()) return null
        val retriever = MediaMetadataRetriever()
        return try {
            retriever.setDataSource(filePath)
            retriever.embeddedPicture // 直接返回 ByteArray
        } catch (e: Exception) {
            null
        } finally {
            retriever.release()
        }
    }
}