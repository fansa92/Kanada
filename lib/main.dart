import 'package:flutter/material.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:kanada/global.dart';
import 'package:kanada/settings.dart';
import 'package:permission_handler/permission_handler.dart';

import 'lyric_sender.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
  Global.player.setAudioSource(
    ConcatenatingAudioSource(
      children: [
        AudioSource.uri(Uri.parse("/storage/emulated/0/Music/Yuki/miku/102220648.mp3"), tag: MediaItem(id: "/storage/emulated/0/Music/Yuki/miku/102220648.mp3", title: "Kanada")),
      ],
    ),
    initialIndex: 0,
  );
  Global.player.play();
  Global.player.pause();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      // 设置状态栏和导航栏背景为透明
      // statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
      // 设置状态栏和导航栏图标颜色为白色
      // statusBarIconBrightness: Brightness.dark,
      // systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  requestPermission();
  Settings.fresh();
  runApp(const MyApp());
}

Future<void> requestPermission() async {
  // Toast.showToast('请求权限中...');
  // PermissionStatus audio = await Permission.audio.request();
  // PermissionStatus manageExternalStorage = await Permission.manageExternalStorage.request();
  // PermissionStatus notification = await Permission.notification.request();
  // if (audio.isDenied || manageExternalStorage.isDenied || notification.isDenied) {
  //   requestPermission();
  // }
  // else if (audio.isPermanentlyDenied || manageExternalStorage.isPermanentlyDenied || notification.isPermanentlyDenied) {
  //   openAppSettings();
  // }
  final permissions = [
    Permission.audio,
    Permission.manageExternalStorage,
    Permission.notification,
  ];
  bool flag1 = false;
  bool flag2 = false;
  for (final permission in permissions) {
    final status = await permission.request();
    if (status.isPermanentlyDenied) {
      flag2 = true;
    } else if (status.isDenied) {
      flag1 = true;
    }
  }
  if (flag1) requestPermission();
  if (flag2) openAppSettings();
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
          theme: ThemeData(colorScheme: lightColorScheme, useMaterial3: true),
          darkTheme: ThemeData(
            colorScheme: darkColorScheme,
            useMaterial3: true,
          ),
          themeMode: ThemeMode.system,
          // 跟随系统主题设置
          initialRoute: '/',
          routes: Global.routes,
        );
      },
    );
  }
}
