import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

import '../metadata.dart';
import '../settings.dart';

import 'package:waterfall_flow/waterfall_flow.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: WaterFall(),
    );
  }
}

class WaterFall extends StatefulWidget {
  const WaterFall({super.key});

  @override
  State<WaterFall> createState() => _WaterFallState();
}

class _WaterFallState extends State<WaterFall> {
  final padding = EdgeInsets.all(12);
  final _scrollController = ScrollController();
  final List<String> data = [];
  final List<String> allPaths = [];
  final Random random = Random();
  bool init = false;

  @override
  void initState() {
    super.initState();
    _init();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 100) {
        if (!init) {
          return;
        }
        _fresh();
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    allPaths.clear();
    final dirs = Settings.folders.map((e) => Directory(e)).toList();
    for (var dir in dirs) {
      List<FileSystemEntity> entities = await dir.list().toList();
      allPaths.addAll(
        entities
            .where((entity) {
              String extension = p.extension(entity.path).toLowerCase();
              return extension == '.mp3' || extension == '.flac';
            })
            .map((e) => e.path),
      );
    }
    _fresh(n: 20);
    init = true;
  }

  Future<void> _fresh({int n = 20}) async {
    for (var i = 0; i < n; i++) {
      data.add(allPaths[random.nextInt(allPaths.length)]);
    }
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return WaterfallFlow.builder(
      padding: padding,
      controller: _scrollController,
      gridDelegate: SliverWaterfallFlowDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: padding.horizontal / 2,
        mainAxisSpacing: padding.vertical / 2,
      ),
      itemCount: data.length,
      itemBuilder: (context, index) => WaterFallItem(path: data[index]),
    );
  }
}

class WaterFallItem extends StatefulWidget {
  final String path;

  const WaterFallItem({super.key, required this.path});

  @override
  State<WaterFallItem> createState() => _WaterFallItemState();
}

class _WaterFallItemState extends State<WaterFallItem> {
  final Metadata metadata = Metadata('');

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    metadata.path = widget.path;
    await metadata.getMetadata();
    if (mounted) {
      setState(() {});
    }
    await metadata.getCover();
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Container(
          color: Theme.of(context).colorScheme.secondaryContainer,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: 1,
                child:
                    (metadata.cover != null)
                        ? Image.memory(metadata.cover!)
                        : ((metadata.cover == null &&
                                metadata.coverCache != null)
                            ? Image.file(File(metadata.coverCache!))
                            : const Icon(Icons.music_note)),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (metadata.title != null)
                      Text(
                        metadata.title!,
                        style: Theme.of(context).textTheme.titleMedium,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    if (metadata.artist != null)
                      Text(
                        metadata.artist!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.8),
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    if (metadata.album != null && metadata.album!.isNotEmpty)
                      Text(
                        metadata.album!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
