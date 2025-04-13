import 'package:flutter/material.dart';
import 'package:kanada/pages/more.dart';

class AppPage extends StatefulWidget{
  const AppPage({super.key});
  @override
  State<AppPage> createState() => _AppPageState();
}
class _AppPageState extends State<AppPage>{
  static List<List<dynamic>> nav = [
    [NavigationDestination(icon: Icon(Icons.home), label: 'Home'), const Text('Home')],
    [NavigationDestination(icon: Icon(Icons.search), label: 'Search'), const Text('Search')],
    [NavigationDestination(icon: Icon(Icons.settings), label: 'More'), const MorePage()],
  ];
  int index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: nav[index][1],
      bottomNavigationBar: NavigationBar(
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