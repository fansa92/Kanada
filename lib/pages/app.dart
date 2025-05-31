import 'package:flutter/material.dart';
import 'package:kanada/pages/folders.dart';
import 'package:kanada/pages/more.dart';
import '../global.dart';
import '../widgets/float_playing.dart';
import 'home.dart';

class AppPage extends StatefulWidget {
  const AppPage({super.key});

  @override
  State<AppPage> createState() => _AppPageState();
}

class _AppPageState extends State<AppPage> {
  static List<List<dynamic>> nav = [
    [
      NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
      const HomePage(),
    ],
    // [
    //   NavigationDestination(icon: Icon(Icons.search), label: 'Search'),
    //   const SearchPage(),
    // ],
    [
      NavigationDestination(icon: Icon(Icons.library_music), label: 'Music'),
      const FoldersPage(),
    ],
    [
      NavigationDestination(icon: Icon(Icons.settings), label: 'More'),
      const MorePage(),
    ],
  ];
  int index = 0;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    Global.playerTheme=Theme.of(context);
    // KanadaLyricServerPlugin.setMethodCallHandler(sendLyrics).then((value){
    //   KanadaLyricServerPlugin.startForegroundService();
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: nav[index][1],
      floatingActionButton: FloatPlaying(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      bottomNavigationBar: NavigationBar(
        backgroundColor: Theme.of(context).colorScheme.secondaryContainer.withValues(alpha: .3),
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        onDestinationSelected: (int index) {
          setState(() {
            this.index = index;
          });
        },
        selectedIndex: index,
        destinations:
            nav.map((e) => e[0]).toList().cast<NavigationDestination>(),
      ),
    );
  }
}
