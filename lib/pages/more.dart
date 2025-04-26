import 'package:flutter/material.dart';
import '../settings.dart';
import '../widgets/link_list.dart';

class MorePage extends StatefulWidget {
  const MorePage({super.key});

  @override
  State<MorePage> createState() => _MorePageState();
}

class _MorePageState extends State<MorePage> {
  @override
  Widget build(BuildContext context) {
    List<List<dynamic>> settings = <List<dynamic>>[
      [Icons.settings, 'Settings', '/more/settings'],
      if (Settings.debug) [Icons.bug_report, 'Debug', '/more/debug'],
    ];
    return Scaffold(
      body: LinkList(links: settings, onTapAfter: () => setState(() {})),
    );
  }
}
