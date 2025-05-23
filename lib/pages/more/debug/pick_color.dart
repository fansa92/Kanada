import 'dart:io';

import 'package:flutter/material.dart';
import 'package:palette_generator/palette_generator.dart';

class PickColorDebug extends StatefulWidget {
  const PickColorDebug({super.key});

  @override
  State<PickColorDebug> createState() => _PickColorDebugState();
}

class _PickColorDebugState extends State<PickColorDebug> {
  Color dominantColor = Colors.black;
  Color vibrantColor = Colors.black;
  Color darkVibrantColor = Colors.black;
  Color lightVibrantColor = Colors.black;
  Color darkMutedColor = Colors.black;
  Color lightMutedColor = Colors.black;
  List<Color> colors = [Color(0xFF39C5BB)];
  int time = 0;

  @override
  void initState() {
    super.initState();
    // _init();
  }

  Future<void> _init() async {
    final t = DateTime.now().millisecondsSinceEpoch;
    final PaletteGenerator paletteGenerator =
        await PaletteGenerator.fromImageProvider(
          FileImage(File('/storage/emulated/0/image.jpg')),
          maximumColorCount: 10,
        );
    setState(() {});
    dominantColor = paletteGenerator.dominantColor!.color;
    vibrantColor = paletteGenerator.vibrantColor!.color;
    // darkVibrantColor = paletteGenerator.darkVibrantColor!.color;
    // lightVibrantColor = paletteGenerator.lightVibrantColor!.color;
    // darkMutedColor = paletteGenerator.darkMutedColor!.color;
    // lightMutedColor = paletteGenerator.lightMutedColor!.color;
    setState(() {});
    colors = paletteGenerator.colors.toList();
    time = DateTime.now().millisecondsSinceEpoch - t;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pick Color')),
      body: Center(
        child: Column(
          children: [
            const Text('Pick Color'),
            ElevatedButton(
              onPressed: () {
                _init();
              },
              child: const Text('Pick Color'),
            ),
            Text('Time: ${time}ms'),
            ColorWidget(color: dominantColor, text: 'Dominant Color: '),
            ColorWidget(color: vibrantColor, text: 'Vibrant Color: '),
            ColorWidget(color: darkVibrantColor, text: 'Dark Vibrant Color: '),
            ColorWidget(
              color: lightVibrantColor,
              text: 'Light Vibrant Color: ',
            ),
            ColorWidget(color: darkMutedColor, text: 'Dark Muted Color: '),
            ColorWidget(color: lightMutedColor, text: 'Light Muted Color: '),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                ),
                itemCount: colors.length,
                itemBuilder: (context, index) {
                  return Container(
                    color: colors[index],
                    child: Text('#${colors[index].value.toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}'),
                  );
                },
              ),
            ),
            // Image.file(File('/storage/emulated/0/image.jpg')),
          ],
        ),
      ),
    );
  }
}

class ColorWidget extends StatelessWidget {
  final Color color;
  final String text;

  const ColorWidget({super.key, required this.color, this.text = ""});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(text),
        Container(
          color: color,
          child: Text(
            '#${color.value.toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}', // 转换为 #RRGGBB 格式
          ),
        ),
      ],
    );
  }
}
