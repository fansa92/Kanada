import 'package:flutter/material.dart';

import '../../../cache.dart';
import '../../../metadata.dart';
import '../../../widgets/pie_chart.dart';

class CacheSettings extends StatefulWidget {
  const CacheSettings({super.key});

  @override
  State<CacheSettings> createState() => _CacheSettingsState();
}

class _CacheSettingsState extends State<CacheSettings> {
  List<KanadaCacheManager> managers = [
    Metadata.metadataCacheManager,
    Metadata.coverCacheManager,
    Metadata.lyricCacheManager,
    Metadata.musicCacheManager,
  ];
  List<FileSize> sizes = [
    FileSize(B: 1),
    FileSize(B: 1),
    FileSize(B: 1),
    FileSize(B: 1),
  ];
  List<Color> colors = [Colors.red, Colors.blue, Colors.green, Colors.orange];
  List<String> names = ['元数据', '封面', '歌词', '音乐'];
  bool init = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    sizes = await Future.wait(
      managers.map((manager) async {
        return await manager.getSizeTotal();
      }),
    );
    // print(files);
    init = true;
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    colors = [
      Theme.of(context).colorScheme.primary.withValues(alpha: .1),
      Theme.of(context).colorScheme.primary.withValues(alpha: .4),
      Theme.of(context).colorScheme.primary.withValues(alpha: .7),
      Theme.of(context).colorScheme.primary.withValues(alpha: 1),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('缓存管理')),
      body: ListView(
        children: [
          SizedBox(height: 48),
          init
              ? PieChart(
                values: sizes.map((size) => size.size.toDouble()).toList(),
                colors: colors,
                width: 200,
                height: 200,
                strokeWidth: 40,
                startAngle: -90,
              )
              : SizedBox(width: 200, height: 200),
          SizedBox(height: 24),
          Divider(),
          SizedBox(height: 24),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: managers.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text('${names[index]}缓存'),
                subtitle: Text(
                  '${sizes[index]}/${managers[index].maxSize}',
                ),
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Container(width: 48, height: 48, color: colors[index]),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
