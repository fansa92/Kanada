import 'package:flutter/material.dart';
import 'package:kanada/Netease.dart';
import 'package:kanada/widgets/music_info.dart';

import '../global.dart';

class SearchPage extends StatefulWidget {

  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  static TextEditingController controller = TextEditingController();

  List<int> ids = [];

  @override
  void initState() {
    super.initState();
    if (controller.text.isNotEmpty) {
      search();
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> search() async {
    ids = await NetEase.searchIds(controller.text);
    setState(() {});
    final List<String> playlist =
    ids.map((id) => 'netease://$id').toList();
    Global.playlist = playlist;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search')),
      body: Stack(
        children: [
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: ids.length+1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return SizedBox(height: 100);
                }
                return ListTile(
                  key: Key(ids[index-1].toString()),
                  title: MusicInfo(path: 'netease://${ids[index-1]}'),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SearchBar(
              controller: controller,
              hintText: 'Enter search query',
              leading: const Icon(Icons.search),
              onChanged: (value) => search(),
            ),
          ),
        ],
      ),
    );
  }
}
