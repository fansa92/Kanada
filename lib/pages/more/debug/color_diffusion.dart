import 'dart:io';

import 'package:flutter/material.dart';
import 'package:palette_generator/palette_generator.dart';

import '../../../widgets/color_diffusion.dart';

class ColorDiffusionDebug extends StatefulWidget {
  const ColorDiffusionDebug({super.key});

  @override
  State<ColorDiffusionDebug> createState() => _ColorDiffusionDebugState();
}

class _ColorDiffusionDebugState extends State<ColorDiffusionDebug> {
  List<Color> colors = [];
  List<Offset> offsets = [
    const Offset(.5, .5),
    const Offset(0, 0),
    const Offset(1, 0),
    const Offset(0, 1),
    const Offset(1, 1),
  ];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final PaletteGenerator paletteGenerator =
        await PaletteGenerator.fromImageProvider(
          FileImage(File('/storage/emulated/0/image.jpg')),
          maximumColorCount: 10,
        );
    colors = paletteGenerator.colors.take(5).toList();
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
          isLoading
              ? Text('Loading...')
              : ColorDiffusionWidget(
                colors: colors,
                offsets: offsets,
              ),
    );
  }
}
