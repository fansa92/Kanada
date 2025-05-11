import 'package:flutter/material.dart';
import 'package:kanada/metadata.dart';

class LyricView extends StatefulWidget {
  final String path;
  final EdgeInsets padding;

  const LyricView({
    super.key,
    required this.path,
    this.padding = const EdgeInsets.all(0),
  });

  @override
  State<LyricView> createState() => _LyricViewState();
}

class _LyricViewState extends State<LyricView> {
  String text = '';
  Metadata? metadata;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    metadata = Metadata(widget.path);
    metadata!.getLyric().then((value) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: widget.padding,
          child: Text(metadata?.lyric ?? widget.path),
        ),
      ),
    );
  }
}
