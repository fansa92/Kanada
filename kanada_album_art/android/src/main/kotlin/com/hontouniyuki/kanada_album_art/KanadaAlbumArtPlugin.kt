package com.hontouniyuki.kanada_album_art

import android.media.MediaMetadataRetriever
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

class KanadaAlbumArtPlugin : FlutterPlugin, MethodCallHandler {
  private lateinit var channel: MethodChannel

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "kanada")
    channel.setMethodCallHandler(this)
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    when (call.method) {
      "getAlbumArt" -> {
        val filePath = call.argument<String>("filePath")
        val albumArt = getAlbumArt(filePath)
        albumArt?.let {
          result.success(it)
        } ?: result.error("404", "Album art not found", null)
      }
      else -> result.notImplemented()
    }
  }

  private fun getAlbumArt(filePath: String?): ByteArray? {
    if (filePath.isNullOrEmpty()) return null
    return MediaMetadataRetriever().run {
      try {
        setDataSource(filePath)
        embeddedPicture
      } catch (e: Exception) {
        null
      } finally {
        release()
      }
    }
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }
}