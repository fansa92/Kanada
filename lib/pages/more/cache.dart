import 'package:flutter/material.dart';
import 'package:kanada/metadata.dart';
import 'package:kanada/settings.dart';
import 'dart:io';
import 'package:path/path.dart' as p;

class CachePage extends StatefulWidget {
  const CachePage({super.key});
  @override
  State<CachePage> createState() => _CachePageState();
}

class _CachePageState extends State<CachePage> {
  List<String> files = [];
  Map<String, Metadata> metadataMap = {};
  int initiated = 0;
  String currentFile = '';

  @override
  void initState() {
    super.initState();
    _loadFiles();
  }

  Future<void> _loadFiles() async {
    final newFiles = <String>[];

    // 遍历所有设置的文件夹路径
    for (final folder in Settings.folders) {
      final dir = Directory(folder);
      if (await dir.exists()) {
        await for (final entity in dir.list()) {
          if (entity is File) {
            final ext = p.extension(entity.path).toLowerCase();
            if (ext == '.mp3' || ext == '.flac') {
              newFiles.add(entity.path);
            }
          }
        }
      }
    }

    newFiles.sort((a, b) {
      return a.split('/').last.compareTo(b.split('/').last);
    });

    if (mounted) {
      setState(() {
        files = newFiles;
      });
    }
    for (final file in files) {
      _loadMetadata(file);
    }
    // const batchSize = 4;
    // for (int i = 0; i < files.length; i += batchSize) {
    //   final batch = files.sublist(i, i + batchSize);
    //   await Future.wait(batch.map((file) => _loadMetadata(file)));
    // }
  }

  Future<void> _loadMetadata(String path) async {
    // await Future.delayed(Duration(milliseconds: 1));
    metadataMap[path] = Metadata(path);
    await metadataMap[path]?.getMetadata();
    await metadataMap[path]?.getPicture();
    await metadataMap[path]?.getLyric();
    currentFile = path;
    initiated++;
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    if(initiated==files.length&&initiated!=0){
      // Navigator.pop(context);
      return Scaffold(
        appBar: AppBar(title: const Text('Cache')),
        body: ListView.builder(
          itemCount: files.length,
          itemBuilder: (context, index) {
            final file = files[index];
            final metadata = metadataMap[file];
            return ListTile(
              title: Text(metadata?.title ?? 'Unknown Title'),
              subtitle: Text(metadata?.artist ?? 'Unknown Artist'),
              leading: metadata?.picture != null
                ? Image.memory(metadata!.picture!)
                : null,
            );
          },
        )
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Cache')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              value: initiated / (files.isEmpty?1:files.length),
            ),
            SizedBox(height: 10),
            Text('$initiated/${files.length} files'),
            SizedBox(height: 10),
            Text(currentFile),
            Text(currentFile!=''?'finished':''),
          ]
        )
      ),
    );
  }
}