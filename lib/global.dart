import 'package:flutter/material.dart';
import 'package:kanada/pages/app.dart';
import 'package:kanada/pages/more.dart';
import 'package:kanada/pages/more/debug.dart';
import 'package:kanada/pages/more/debug/link.dart';

class Global{
  static Map<String, WidgetBuilder> routes = {
    '/': (context) => const AppPage(),
    '/more': (context) => const MorePage(),
    '/more/debug': (context) => const DebugPage(),
    '/more/debug/link': (context) => const LinkDebug(),
  };
}