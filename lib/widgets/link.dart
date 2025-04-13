import 'dart:math';

import 'package:flutter/material.dart';
import 'package:kanada/global.dart';

class CustomRoute<T> extends PageRoute<T> {
  final WidgetBuilder builder;
  final List<double> position;
  final List<double> size;
  final Duration duration;
  final Curve curve;

  CustomRoute({
    required this.builder,
    required this.position,
    required this.size,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeInOut,
  });

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

  @override
  Duration get transitionDuration => duration;

  @override
  bool get maintainState => true;

  @override
  bool get opaque => false;

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    return builder(context);
  }

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    final screenSize = MediaQuery.of(context).size;

    final beginRect = Rect.fromLTWH(
      position[0].toDouble(),
      position[1].toDouble(),
      size[0].toDouble(),
      size[1].toDouble(),
    );

    final endRect = Rect.fromLTWH(0, 0, screenSize.width, screenSize.height);

    final rectTween = RectTween(begin: beginRect, end: endRect);
    final curvedAnimation = CurvedAnimation(
      parent: animation,
      curve: curve,
    );
    final rectAnimation = curvedAnimation.drive(rectTween);
    final opacityTween = Tween<double>(begin: 0.0, end: 5.0);
    final opacityAnimation = curvedAnimation.drive(opacityTween);

    return AnimatedBuilder(
      animation: Listenable.merge([rectAnimation, opacityAnimation]),
      builder: (context, child) {
        return Opacity(
          opacity: min(opacityAnimation.value, 1.0),
          child: CustomSingleChildLayout(
            delegate: _LayoutDelegate(rectAnimation.value!),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

class _LayoutDelegate extends SingleChildLayoutDelegate {
  final Rect rect;

  _LayoutDelegate(this.rect);

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    return BoxConstraints.tight(Size(rect.width, rect.height));
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    return Offset(rect.left, rect.top);
  }

  @override
  bool shouldRelayout(_LayoutDelegate oldDelegate) {
    return rect != oldDelegate.rect;
  }
}

class Link extends StatefulWidget{
  final Widget child;
  final String route;
  const Link({super.key, required this.child, required this.route});
  @override
  State<Link> createState() => _LinkState();
}
class _LinkState extends State<Link>{
  final GlobalKey widgetKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: widgetKey,
      onTap: (){
        final RenderBox renderBox =
        context.findRenderObject() as RenderBox;
        final Offset offset = renderBox.localToGlobal(Offset.zero);
        final Size size = renderBox.size;
        Navigator.push(
          context,
          CustomRoute(
            position: [offset.dx, offset.dy],  // 起始位置 (left, top)
            size: [size.width, size.height],       // 起始尺寸 (width, height)
            builder: (context) => Global.routes[widget.route]!(context),
          ),
        );
      },
      child: widget.child,
    );
  }
}