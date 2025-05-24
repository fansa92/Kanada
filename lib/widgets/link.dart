import 'package:flutter/material.dart';
import 'package:kanada/global.dart';

class Link extends StatefulWidget {
  final Widget child;
  final String route;
  final Function? onTapBefore; // 新增 onTap 回调
  final Function? onTapAfter; // 新增 onTap 回调

  const Link({
    super.key,
    required this.child,
    required this.route,
    this.onTapBefore, // 接收外部点击回调
    this.onTapAfter, // 接收外部点击回调
  });

  @override
  State<Link> createState() => _LinkState();
}

class _LinkState extends State<Link> {
  Future<void> _handleTap() async {
    // 优先执行外部传入的 onTap
    if (widget.onTapBefore != null) {
      widget.onTapBefore!();
    }

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Global.routes[widget.route]!(context),
      )
    );

    if (widget.onTapAfter != null) {
      widget.onTapAfter!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _handleTap, // 使用统一的点击处理
      child: widget.child,
    );
  }
}

class LinkBuilder extends StatefulWidget {
  final Widget child;
  final WidgetBuilder builder;
  final VoidCallback? onTapBefore; // 新增 onTap 回调
  final VoidCallback? onTapAfter; // 新增 onTap 回调

  const LinkBuilder({
    super.key,
    required this.child,
    required this.builder,
    this.onTapBefore, // 接收外部点击回调
    this.onTapAfter, // 接收外部点击回调
  });

  @override
  State<LinkBuilder> createState() => _LinkBuilderState();
}

class _LinkBuilderState extends State<LinkBuilder> {
  void _handleTap() {
    // 优先执行外部传入的 onTap
    if (widget.onTapBefore != null) {
      widget.onTapBefore!();
    }

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
      onTap: _handleTap, // 使用统一的点击处理
      child: widget.child,
    );
  }
}
