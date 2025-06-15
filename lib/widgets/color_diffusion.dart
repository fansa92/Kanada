import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ColorDiffusionWidget extends StatelessWidget {
  final List<Color> colors;
  final List<Offset> offsets;
  final double width;
  final double height;

  const ColorDiffusionWidget({
    super.key,
    required this.colors,
    required this.offsets,
    this.width = double.infinity,
    this.height = double.infinity,
  }) : assert(
  colors.length == offsets.length,
  'Colors and offsets must have the same length',
  );

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(
        painter: _ColorDiffusionPainter(colors: colors, offsets: offsets),
      ),
    );
  }
}

class _ColorDiffusionPainter extends CustomPainter {
  final List<Color> colors;
  final List<Offset> offsets;

  _ColorDiffusionPainter({required this.colors, required this.offsets})
      : assert(
  colors.length == offsets.length,
  'Colors and offsets must have the same length',
  );

  @override
  bool shouldRepaint(covariant _ColorDiffusionPainter old) {
    // 添加深度比较
    return !listEquals(old.colors, colors) || // 改为深度比较
        !listEquals(old.offsets, offsets);
  }

  @override
  void paint(Canvas canvas, Size size) {
    // 预计算最大半径
    final maxSize = max(size.width, size.height);
    final gradients = List<RadialGradient>.generate(colors.length, (i) {
      final offset = offsets[i];
      final centerX = offset.dx * size.width;
      final centerY = offset.dy * size.height;

      final distances = [
        (Offset(centerX, centerY) - const Offset(0, 0)).distance,
        (Offset(centerX, centerY) - Offset(size.width, 0)).distance,
        (Offset(centerX, centerY) - Offset(size.width, size.height)).distance,
        (Offset(centerX, centerY) - Offset(0, size.height)).distance,
      ];
      final maxDistance = distances.reduce(max);
      return RadialGradient(
        center: Alignment((offset.dx * 2 - 1), (offset.dy * 2 - 1)),
        colors: [colors[i], Colors.transparent],
        stops: const [0.0, 1.0],
        radius: maxDistance / (maxSize / 2),
        tileMode: TileMode.clamp,
      );
    });

    // 缓存 Paint 对象
    final paintCache = Paint()..shader = gradients[0].createShader(
        Rect.fromLTWH(0, 0, size.width, size.height));

    for (int i = 0; i < colors.length; i++) {
      // 重用缓存的 Paint 对象
      if (i > 0) {
        paintCache.shader = gradients[i].createShader(
            Rect.fromLTWH(0, 0, size.width, size.height));
      }
      canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paintCache);
    }
  }
}
