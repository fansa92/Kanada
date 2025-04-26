import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:kanada/pages/app.dart';
import 'package:kanada/pages/folders.dart';
import 'package:kanada/pages/home.dart';
import 'package:kanada/pages/more.dart';
import 'package:kanada/pages/more/debug.dart';
import 'package:kanada/pages/more/debug/file_choose.dart';
import 'package:kanada/pages/more/debug/link.dart';
import 'package:kanada/pages/more/debug/player.dart';
import 'package:kanada/pages/more/debug/toast.dart';
import 'package:kanada/pages/more/settings.dart';
import 'package:kanada/pages/more/settings/folders.dart';

class Global{
  static Map<String, WidgetBuilder> routes = {
    '/': (context) => const AppPage(),
    '/home': (context) => const HomePage(),
    '/folders': (context) => const FoldersPage(),
    '/more': (context) => const MorePage(),
    '/more/debug': (context) => const DebugPage(),
    '/more/debug/link': (context) => const LinkDebug(),
    '/more/debug/player': (context) => const PlayerDebug(),
    '/more/debug/toast': (context) => const ToastDebug(),
    '/more/debug/file_choose': (context) => const FileChooseDebug(),
    '/more/settings': (context) => const SettingsPage(),
    '/more/settings/folders': (context) => const FoldersSettings(),
  };
  static late AudioPlayer player;
}