import 'package:flutter/material.dart';

class FractionClip extends StatelessWidget {
  final double top;
  final double left;
  final double bottom;
  final double right;
  final Widget child;

  const FractionClip({
    super.key,
    this.top = 0.0,
    this.left = 0.0,
    this.bottom = 0.0,
    this.right = 0.0,
    required this.child,
  })  : assert(top >= 0 && top <= 1),
        assert(left >= 0 && left <= 1),
        assert(bottom >= 0 && bottom <= 1),
        assert(right >= 0 && right <= 1),
        assert(left + right <= 1, 'left + right 不能超过1.0'),
        assert(top + bottom <= 1, 'top + bottom 不能超过1.0');

  @override
  Widget build(BuildContext context) {
    final widthFactor = 1 - left - right;
    final heightFactor = 1 - top - bottom;

    return ClipRect(
      child: Align(
        alignment: Alignment(
          _getAlignmentX(left, widthFactor),
          _getAlignmentY(top, heightFactor),
        ),
        widthFactor: widthFactor,
        heightFactor: heightFactor,
        child: child,
      ),
    );
  }

  double _getAlignmentX(double left, double widthFactor) {
    return widthFactor == 0 ? 0 : -left / widthFactor;
  }

  double _getAlignmentY(double top, double heightFactor) {
    return heightFactor == 0 ? 0 : -top / heightFactor;
  }
}