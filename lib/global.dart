import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:kanada/pages/app.dart';
import 'package:kanada/pages/more.dart';
import 'package:kanada/pages/more/debug.dart';
import 'package:kanada/pages/more/debug/link.dart';
import 'package:kanada/pages/more/debug/player.dart';
import 'package:kanada/pages/more/debug/toast.dart';

class Global{
  static Map<String, WidgetBuilder> routes = {
    '/': (context) => const AppPage(),
    '/more': (context) => const MorePage(),
    '/more/debug': (context) => const DebugPage(),
    '/more/debug/link': (context) => const LinkDebug(),
    '/more/debug/player': (context) => const PlayerDebug(),
    '/more/debug/toast': (context) => const ToastDebug(),
  };
  static late AudioPlayer player;
}