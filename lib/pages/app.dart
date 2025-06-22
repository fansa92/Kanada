import 'package:flutter/material.dart';
import 'package:kanada/pages/folders.dart';
import 'package:kanada/pages/more.dart';
import 'package:kanada/pages/search.dart';
import 'package:kanada/settings.dart';
import '../global.dart';
import '../widgets/float_playing.dart';
import 'home.dart';

class AppPage extends StatefulWidget {
  static const List<String> homePageNames = ['首页', '搜索', '音乐', '更多'];

  const AppPage({super.key});

  @override
  State<AppPage> createState() => _AppPageState();
}

class _AppPageState extends State<AppPage> {
  int index = 0;
  late PageController _pageController;

  int get idx => Settings.searchPage ? index : (index > 0 ? index - 1 : index);

  set idx(int value) {
    setState(() {
      index = Settings.searchPage ? value : (value > 0 ? value + 1 : value);
    });
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: idx);
    _init();
  }

  Future<void> _init() async {
    idx = Settings.homePage;
    // KanadaLyricServerPlugin.setMethodCallHandler(sendLyrics).then((value){
    //   KanadaLyricServerPlugin.startForegroundService();
    // });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    Global.playerTheme = Theme.of(context);
  }

  @override
  Widget build(BuildContext context) {
    List<List<dynamic>> nav = [
      [
        NavigationDestination(
          icon: Icon(Icons.home),
          label: AppPage.homePageNames[0],
        ),
        const HomePage(),
      ],
      if (Settings.searchPage)
        [
          NavigationDestination(
            icon: Icon(Icons.search),
            label: AppPage.homePageNames[1],
          ),
          const SearchPage(),
        ],
      [
        NavigationDestination(
          icon: Icon(Icons.library_music),
          label: AppPage.homePageNames[2],
        ),
        const FoldersPage(),
      ],
      [
        NavigationDestination(
          icon: Icon(Icons.settings),
          label: AppPage.homePageNames[3],
        ),
        const MorePage(),
      ],
    ];
    return Scaffold(
      body: PageView.builder(
        controller: _pageController,
        itemCount: nav.length,
        onPageChanged: (index) {
          setState(() => idx = index);
        },
        itemBuilder: (context, index) => nav[index][1],
      ),
      floatingActionButton: FloatPlaying(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      bottomNavigationBar: NavigationBar(
        backgroundColor: Theme.of(
          context,
        ).colorScheme.secondaryContainer.withValues(alpha: .3),
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        onDestinationSelected: (int index) {
          setState(() => idx = index);
          _pageController.animateToPage(
            idx,
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        },
        selectedIndex: idx,
        destinations:
            nav.map((e) => e[0]).toList().cast<NavigationDestination>(),
      ),
    );
  }
}
