import 'dart:io';

import 'package:flutter/material.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:kanada/global.dart';
import 'package:permission_handler/permission_handler.dart';

Future<void> main() async {
  // Global.audioHandler = await AudioService.init(
  //   builder: () => MyAudioHandler(),
  //   config: AudioServiceConfig(
  //     androidNotificationChannelId: 'com.hontouniyuki.kanada.channel.audio',
  //     androidNotificationChannelName: 'Music playback',
  //   ),
  // );
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.hontouniyuki.kanada.channel.audio',
    androidNotificationChannelName: 'Audio playback',
    androidNotificationOngoing: true,
  );
  Global.player = AudioPlayer();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    // 设置状态栏和导航栏背景为透明
    // statusBarColor: Colors.transparent,
    systemNavigationBarColor: Colors.transparent,
    // 设置状态栏和导航栏图标颜色为白色
    // statusBarIconBrightness: Brightness.dark,
    // systemNavigationBarIconBrightness: Brightness.dark,
  ));
  checkAndRequestAudioPermission();
  runApp(const MyApp());
}

// 检查并请求 READ_MEDIA_AUDIO 权限的函数
Future<void> checkAndRequestAudioPermission() async {
  PermissionStatus status = await Permission.audio.request();
  if (status.isDenied) {
    // 如果权限被拒绝，显示一个提示框
    checkAndRequestAudioPermission();
    // print('音频权限被拒绝');
  } else if (status.isPermanentlyDenied) {
    // 如果权限被永久拒绝，引导用户去设置中开启权限
    openAppSettings();
    // print('音频权限被永久拒绝，请在设置中开启权限');
  } else if (status.isGranted) {
    // 权限已授予
    // print('音频权限已授予');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        // 创建默认颜色方案（当动态颜色不可用时使用）
        final ColorScheme lightColorScheme;
        final ColorScheme darkColorScheme;

        if (lightDynamic != null && darkDynamic != null) {
          // 使用动态颜色方案
          lightColorScheme = lightDynamic.harmonized();
          darkColorScheme = darkDynamic.harmonized();
        } else {
          // 回退到自定义颜色方案（这里使用蓝色主题）
          lightColorScheme = ColorScheme.fromSeed(
            seedColor: Color(0xFF39C5BB),
            brightness: Brightness.light,
          );
          darkColorScheme = ColorScheme.fromSeed(
            seedColor: Color(0xFF39C5BB),
            brightness: Brightness.dark,
          );
        }

        return MaterialApp(
          theme: ThemeData(
            colorScheme: lightColorScheme,
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            colorScheme: darkColorScheme,
            useMaterial3: true,
          ),
          themeMode: ThemeMode.system, // 跟随系统主题设置
          initialRoute: '/',
          routes: Global.routes,
        );
      },
    );
  }
}