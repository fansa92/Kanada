package com.hontouniyuki.kanada_lyric_server

import android.content.Context
import android.content.Intent
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.FlutterEngineCache
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import kotlinx.coroutines.*
import android.util.Log
import android.os.Build  // 修复 Build 引用问题

class KanadaLyricServerPlugin : FlutterPlugin, MethodCallHandler {
  private var flutterEngine: FlutterEngine? = null
  private lateinit var channel: MethodChannel
  private var applicationContext: Context? = null

  // 添加前台服务的控制逻辑
  private var foregroundServiceIntent: Intent? = null
  private var periodicJob: Job? = null
  private val engineId = "lyric_service_engine" // 唯一引擎标识

  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    applicationContext = flutterPluginBinding.applicationContext
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "kanada_lyric_server")
    channel.setMethodCallHandler(this)

    // 初始化独立引擎（添加完整实现）
    flutterEngine = FlutterEngine(applicationContext!!).apply {
      // 添加默认入口点
      dartExecutor.executeDartEntrypoint(DartExecutor.DartEntrypoint.createDefault())

      // 缓存引擎
      FlutterEngineCache.getInstance().put("lyric_service_engine", this)
      Log.d("EngineInit", "✅ FlutterEngine initialized")
    }
  }

  override fun onMethodCall(call: MethodCall, result: Result) {
    when (call.method) {
      "getPlatformVersion" -> {
        result.success("Android ${android.os.Build.VERSION.RELEASE}")
      }
      "startForegroundService" -> {
        Log.i("LyricForegroundService", "Starting foreground service...")

        // 确保引擎已初始化
        if (FlutterEngineCache.getInstance().get(engineId) == null) {
          result.error(
            "ENGINE_NOT_READY",
            "FlutterEngine initialization in progress. Retry in 2 seconds.",
            null
          )
          return@onMethodCall
        }

        // 启动服务
        applicationContext?.let { ctx ->
          val intent = Intent(ctx, LyricForegroundService::class.java)
          if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            ctx.startForegroundService(intent)
          } else {
            ctx.startService(intent)
          }
          result.success(true)
        } ?: run {
          result.error("CONTEXT_LOST", "Application context unavailable", null)
        }
      }
      "stopForegroundService" -> {
        // 停止前台服务
        foregroundServiceIntent?.let {
          applicationContext?.stopService(it)
          periodicJob?.cancel() // 停止定时任务
        }
        result.success(true)
      }
      else -> result.notImplemented()
    }
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
    applicationContext = null

    // 销毁独立引擎
    FlutterEngineCache.getInstance().get(engineId)?.destroy()
    FlutterEngineCache.getInstance().remove(engineId)
    Log.d("EngineCleanup", "♻️ FlutterEngine destroyed")
  }
}