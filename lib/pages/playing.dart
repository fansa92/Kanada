import 'package:flutter/material.dart';
import 'package:kanada/pages/player.dart';
import 'package:kanada/pages/lyric.dart';

class PlayingPage extends StatefulWidget {
  const PlayingPage({super.key});
  @override
  State<PlayingPage> createState() => _PlayingPageState();
}
class _PlayingPageState extends State<PlayingPage> {
  static const List<Widget> pages=[
    PlayerPage(),
    LyricPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
      Stack(
        children:[
          PageView.builder(
            itemCount: pages.length,
            itemBuilder: (context, index) {
              return pages[index];
            },
          )
        ]
      ),
    );
  }
}