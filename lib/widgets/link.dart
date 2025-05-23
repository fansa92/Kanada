import 'package:flutter/material.dart';
import 'package:kanada/global.dart';

class Link extends StatefulWidget {
  final Widget child;
  final String route;
  final Duration? duration;
  final Curve? curve;
  final double? elevation;
  final Color? shadowColor;
  final BorderRadius? borderRadius;
  final Clip? clipBehavior;
  final Function? onTapBefore; // 新增 onTap 回调
  final Function? onTapAfter; // 新增 onTap 回调
  final GlobalKey? sourceKey; // 源页面元素的Key
  final GlobalKey? targetKey; // 目标页面元素的Key

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
    this.onTapBefore, // 接收外部点击回调
    this.onTapAfter, // 接收外部点击回调
    this.sourceKey,
    this.targetKey,
  });

  @override
  State<Link> createState() => _LinkState();
}

class _LinkState extends State<Link> {
  final GlobalKey widgetKey = GlobalKey();

  Future<void> _handleTap() async {
    // 优先执行外部传入的 onTap
    if (widget.onTapBefore != null) {
      widget.onTapBefore!();
    }

    // 默认导航逻辑（如果外部未提供回调）
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final Offset offset = renderBox.localToGlobal(Offset.zero);
    final Size size = renderBox.size;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Global.routes[widget.route]!(context),
      )
      // CustomRoute(
      //   position: [offset.dx, offset.dy],
      //   size: [size.width, size.height],
      //   builder: (context) => Global.routes[widget.route]!(context),
      //   duration: widget.duration ?? const Duration(milliseconds: 300),
      //   curve: widget.curve ?? Curves.easeInOut,
      //   elevation: widget.elevation ?? 8.0,
      //   shadowColor: widget.shadowColor ?? Colors.black,
      //   borderRadius: widget.borderRadius ?? BorderRadius.zero,
      //   clipBehavior: widget.clipBehavior ?? Clip.antiAlias,
      //   sourceKey: widget.sourceKey,
      //   targetKey: widget.targetKey,
      // ),
    );

    if (widget.onTapAfter != null) {
      widget.onTapAfter!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      key: widgetKey,
      onTap: _handleTap, // 使用统一的点击处理
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
  final BorderRadius? borderRadius;
  final Clip? clipBehavior;
  final VoidCallback? onTapBefore; // 新增 onTap 回调
  final VoidCallback? onTapAfter; // 新增 onTap 回调

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
    this.onTapBefore, // 接收外部点击回调
    this.onTapAfter, // 接收外部点击回调
  });

  @override
  State<LinkBuilder> createState() => _LinkBuilderState();
}

class _LinkBuilderState extends State<LinkBuilder> {
  final GlobalKey widgetKey = GlobalKey();

  void _handleTap() {
    // 优先执行外部传入的 onTap
    if (widget.onTapBefore != null) {
      widget.onTapBefore!();
    }

    // 默认导航逻辑（如果外部未提供回调）
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final Offset offset = renderBox.localToGlobal(Offset.zero);
    final Size size = renderBox.size;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: widget.builder,
      ),
    );

    if (widget.onTapAfter != null) {
      widget.onTapAfter!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      key: widgetKey,
      onTap: _handleTap, // 使用统一的点击处理
      child: widget.child,
    );
  }
}
