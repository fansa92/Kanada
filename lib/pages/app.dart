import 'package:flutter/material.dart';
import 'package:kanada/pages/folders.dart';
import 'package:kanada/pages/more.dart';

import 'home.dart';

class AppPage extends StatefulWidget{
  const AppPage({super.key});
  @override
  State<AppPage> createState() => _AppPageState();
}
class _AppPageState extends State<AppPage>{
  static List<List<dynamic>> nav = [
    [NavigationDestination(icon: Icon(Icons.home), label: 'Home'), const HomePage()],
    [NavigationDestination(icon: Icon(Icons.search), label: 'Search'), const Text('Search')],
    [NavigationDestination(icon: Icon(Icons.library_music), label: 'Music'), FoldersPage()],
    [NavigationDestination(icon: Icon(Icons.settings), label: 'More'), const MorePage()],
  ];
  int index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: nav[index][1],
      bottomNavigationBar: NavigationBar(
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        onDestinationSelected: (int index) {
          setState(() {
            this.index = index;
          });
        },
        selectedIndex: index,
        destinations: nav.map((e) => e[0]).toList().cast<NavigationDestination>(),
      )
    );
    }
}