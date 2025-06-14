import 'package:flutter/material.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/services.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:kanada/global.dart';
import 'package:kanada/player.dart';
import 'package:kanada/settings.dart';
import 'package:permission_handler/permission_handler.dart';

/// 应用入口点
Future<void> main() async {
  // 初始化Flutter引擎绑定
  WidgetsFlutterBinding.ensureInitialized();

  // 加载应用设置
  await Settings.fresh();

  // 初始化音频后台服务
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.hontouniyuki.kanada.channel.audio',
    androidNotificationChannelName: 'Audio playback',
    androidNotificationOngoing: true, // 保持持续通知
  );

  // 初始化播放器实例
  Global.player = Player();

  // 配置系统UI
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.transparent, // 透明导航栏
    ),
  );

  // 请求必要权限
  await requestPermission();

  // 启动应用
  runApp(const MyApp());
}

/// 请求运行时权限
Future<void> requestPermission() async {
  final permissions = [
    Permission.audio,               // 音频播放权限
    Permission.manageExternalStorage, // 文件管理权限
    Permission.notification,        // 通知权限
  ];

  bool hasDenied = false;          // 存在暂时拒绝的权限
  bool hasPermanentDenied = false; // 存在永久拒绝的权限

  for (final permission in permissions) {
    final status = await permission.request();
    if (status.isPermanentlyDenied) {
      hasPermanentDenied = true;
    } else if (status.isDenied) {
      hasDenied = true;
    }
  }

  if (hasDenied) requestPermission();   // 重新请求暂时拒绝的权限
  if (hasPermanentDenied) openAppSettings(); // 引导到设置页面
}

/// 主应用组件
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        // 动态颜色处理（支持Android 12+的主题取色）
        final ColorScheme lightColorScheme;
        final ColorScheme darkColorScheme;

        if (lightDynamic != null && darkDynamic != null) {
          // 使用系统动态颜色
          lightColorScheme = lightDynamic.harmonized();
          darkColorScheme = darkDynamic.harmonized();
        } else {
          // 回退到默认蓝色主题
          const seedColor = Color(0xFF39C5BB); // 主色调
          lightColorScheme = ColorScheme.fromSeed(
            seedColor: seedColor,
            brightness: Brightness.light,
          );
          darkColorScheme = ColorScheme.fromSeed(
            seedColor: seedColor,
            brightness: Brightness.dark,
          );
        }

        return MaterialApp(
          theme: ThemeData(
            colorScheme: lightColorScheme,
            useMaterial3: true, // 启用Material 3设计
          ),
          darkTheme: ThemeData(
            colorScheme: darkColorScheme,
            useMaterial3: true,
          ),
          themeMode: ThemeMode.system, // 跟随系统主题
          initialRoute: '/',
          routes: Global.routes, // 应用路由配置
        );
      },
    );
  }
}
