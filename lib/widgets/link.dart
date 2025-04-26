import 'dart:math';

import 'package:flutter/material.dart';
import 'package:kanada/global.dart';

class CustomRoute<T> extends PageRoute<T> {
  final WidgetBuilder builder;
  final List<double> position;
  final List<double> size;
  final Duration duration;
  final Curve curve;
  final double elevation;
  final Color shadowColor;
  final BorderRadius borderRadius; // 新增圆角参数
  final Clip clipBehavior; // 新增裁剪行为参数

  CustomRoute({
    required this.builder,
    required this.position,
    required this.size,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeInOut,
    this.elevation = 8.0,
    this.shadowColor = Colors.black,
    this.borderRadius = BorderRadius.zero, // 默认无圆角
    this.clipBehavior = Clip.antiAlias, // 默认抗锯齿裁剪
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
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return builder(context);
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final screenSize = MediaQuery.of(context).size;

    final beginRect = Rect.fromLTWH(
      position[0].toDouble(),
      position[1].toDouble(),
      size[0].toDouble(),
      size[1].toDouble(),
    );

    final endRect = Rect.fromLTWH(0, 0, screenSize.width, screenSize.height);

    final rectTween = RectTween(begin: beginRect, end: endRect);
    final curvedAnimation = CurvedAnimation(parent: animation, curve: curve);

    // 添加圆角动画
    final borderRadiusTween = BorderRadiusTween(
      begin: borderRadius, // 使用传入的初始圆角
      end: BorderRadius.zero, // 动画结束时变为0
    );

    final rectAnimation = curvedAnimation.drive(rectTween);
    final borderRadiusAnimation = curvedAnimation.drive(borderRadiusTween);
    final opacityTween = Tween<double>(begin: 0.0, end: 5.0);
    final opacityAnimation = curvedAnimation.drive(opacityTween);

    return AnimatedBuilder(
      animation: Listenable.merge([
        rectAnimation,
        opacityAnimation,
        borderRadiusAnimation, // 添加圆角动画监听
      ]),
      builder: (context, child) {
        return Opacity(
          opacity: min(opacityAnimation.value, 1.0),
          child: CustomSingleChildLayout(
            delegate: _LayoutDelegate(rectAnimation.value!),
            child: PhysicalModel(
              color: Colors.transparent,
              elevation: elevation,
              shadowColor: shadowColor,
              borderRadius: borderRadiusAnimation.value!,
              // 使用动画值
              clipBehavior: clipBehavior,
              child: ClipRRect(
                borderRadius: borderRadiusAnimation.value!, // 使用动画值
                clipBehavior: clipBehavior,
                child: child,
              ),
            ),
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
    return BoxConstraints.tight(rect.size);
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    return rect.topLeft;
  }

  @override
  bool shouldRelayout(_LayoutDelegate oldDelegate) {
    return rect != oldDelegate.rect;
  }
}

class Link extends StatefulWidget {
  final Widget child;
  final String route;
  final Duration? duration;
  final Curve? curve;
  final double? elevation;
  final Color? shadowColor;
  final BorderRadius? borderRadius; // 新增圆角参数
  final Clip? clipBehavior; // 新增裁剪行为参数

  const Link({
    super.key,
    required this.child,
    required this.route,
    this.duration,
    this.curve,
    this.elevation,
    this.shadowColor,
    this.borderRadius,
    this.clipBehavior,
  });

  @override
  State<Link> createState() => _LinkState();
}

class _LinkState extends State<Link> {
  final GlobalKey widgetKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return InkWell(
      key: widgetKey,
      onTap: () {
        final RenderBox renderBox = context.findRenderObject() as RenderBox;
        final Offset offset = renderBox.localToGlobal(Offset.zero);
        final Size size = renderBox.size;
        Navigator.push(
          context,
          CustomRoute(
            position: [offset.dx, offset.dy],
            // 起始位置 (left, top)
            size: [size.width, size.height],
            // 起始尺寸 (width, height)
            builder: (context) => Global.routes[widget.route]!(context),
            duration: widget.duration ?? const Duration(milliseconds: 300),
            curve: widget.curve ?? Curves.easeInOut,
            elevation: widget.elevation ?? 8.0,
            shadowColor: widget.shadowColor ?? Colors.black,
            borderRadius: widget.borderRadius ?? BorderRadius.zero,
            // 使用传入的圆角
            clipBehavior: widget.clipBehavior ?? Clip.antiAlias, // 使用传入的裁剪行为
          ),
        );
      },
      child: widget.child,
    );
  }
}

class LinkBuilder extends StatefulWidget {
  final Widget child;
  final WidgetBuilder builder;
  final Duration? duration;
  final Curve? curve;
  final double? elevation;
  final Color? shadowColor;
  final BorderRadius? borderRadius; // 新增圆角参数
  final Clip? clipBehavior; // 新增裁剪行为参数

  const LinkBuilder({
    super.key,
    required this.child,
    required this.builder,
    this.duration,
    this.curve,
    this.elevation,
    this.shadowColor,
    this.borderRadius,
    this.clipBehavior,
  });
  @override
  State<LinkBuilder> createState() => _LinkBuilderState();
}

class _LinkBuilderState extends State<LinkBuilder> {
  final GlobalKey widgetKey = GlobalKey();
  @override
  Widget build(BuildContext context) {
    return InkWell(
      key: widgetKey,
      onTap: () {
        final RenderBox renderBox = context.findRenderObject() as RenderBox;
        final Offset offset = renderBox.localToGlobal(Offset.zero);
        final Size size = renderBox.size;
        Navigator.push(
          context,
          CustomRoute(
            position: [offset.dx, offset.dy],
            // 起始位置 (left, top)
            size: [size.width, size.height],
            // 起始尺寸 (width, height)
            builder: widget.builder,
            duration: widget.duration?? const Duration(milliseconds: 300),
            curve: widget.curve?? Curves.easeInOut,
            elevation: widget.elevation?? 8.0,
            shadowColor: widget.shadowColor?? Colors.black,
            borderRadius: widget.borderRadius?? BorderRadius.zero,
            // 使用传入的圆角
            clipBehavior: widget.clipBehavior?? Clip.antiAlias, // 使用传入的裁剪行为
          )
        );
      },
      child: widget.child,
    );
  }
}