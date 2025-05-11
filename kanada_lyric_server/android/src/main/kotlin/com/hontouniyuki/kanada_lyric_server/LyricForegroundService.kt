package com.hontouniyuki.kanada_lyric_server

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.IBinder
import androidx.core.app.NotificationCompat
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.FlutterEngineCache
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.*
import android.util.Log

class LyricForegroundService : Service() {
  private val channelId = "com.hontouniyuki.kanada.channel.lyric"
  private val notificationId = 83139
  private var periodicJob: Job? = null

  override fun onBind(intent: Intent?): IBinder? = null

  private val methodChannel by lazy {
    val engine = FlutterEngineCache.getInstance().get("lyric_service_engine")
      ?: throw IllegalStateException("FlutterEngine not found in cache")

    MethodChannel(engine.dartExecutor.binaryMessenger, "kanada_lyric_server/background")
  }

  override fun onCreate() {
    super.onCreate()
    Log.i("LyricForegroundService", "Miraiku Service started without FlutterEngine")
    createNotificationChannel()
    startForeground(notificationId, createNotification())
    startPeriodicTask()
  }

  private fun createNotificationChannel() {
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
      val channel = NotificationChannel(
        channelId,
        "歌词服务通道",
        NotificationManager.IMPORTANCE_LOW
      )
      val manager = getSystemService(NotificationManager::class.java)
      manager.createNotificationChannel(channel)
    }
  }

  private fun createNotification(): Notification {
    return NotificationCompat.Builder(this, channelId)
      .setContentTitle("歌词服务运行中")
      .setContentText("正在同步歌词...")
      .setSmallIcon(android.R.drawable.ic_media_play) // 替换为你的通知图标
      .setPriority(NotificationCompat.PRIORITY_LOW)
      .build()
  }

  private fun startPeriodicTask() {
    val scope = CoroutineScope(Dispatchers.Default)
    periodicJob = scope.launch {
      var engineAvailable = false

      // 等待引擎就绪
      repeat(5) { attempt ->
        engineAvailable = FlutterEngineCache.getInstance().get("lyric_service_engine") != null
        if (engineAvailable) return@repeat
        delay(500 * (attempt + 1).toLong())
      }

      if (!engineAvailable) {
        Log.e("EngineCheck", "❌ Failed to acquire FlutterEngine after retries")
        stopSelf()
        return@launch
      }

      // 正常执行任务
      while (isActive) {
        try {
          withContext(Dispatchers.Main) {
            methodChannel.invokeMethod("onLyricUpdate", null)
          }
        } catch (e: Exception) {
          Log.e("ChannelError", "Method call failed: ${e.message}")
        }
        delay(1000)
      }
    }
  }

  override fun onDestroy() {
    periodicJob?.cancel()
//    flutterEngine.destroy()
    super.onDestroy()
  }
}