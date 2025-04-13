import 'package:flutter/material.dart';

import '../widgets/link_list.dart';

class MorePage extends StatefulWidget{
  const MorePage({super.key});
  @override
  State<MorePage> createState() => _MorePageState();
}
class _MorePageState extends State<MorePage>{
  static List<List<dynamic>> settings = [
    [Icons.bug_report, "Debug", '/more/debug']
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LinkList(links: settings),
    );
  }
}