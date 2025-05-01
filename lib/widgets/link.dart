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
  final BorderRadius borderRadius;
  final Clip clipBehavior;
  final GlobalKey? sourceKey; // 源页面元素的Key
  final GlobalKey? targetKey; // 目标页面元素的Key

  CustomRoute({
    required this.builder,
    required this.position,
    required this.size,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeInOut,
    this.elevation = 8.0,
    this.shadowColor = Colors.black,
    this.borderRadius = BorderRadius.zero,
    this.clipBehavior = Clip.antiAlias,
    this.sourceKey,
    this.targetKey,
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

    // 页面展开动画
    final beginRect = Rect.fromLTWH(position[0], position[1], size[0], size[1]);
    final endRect = Rect.fromLTWH(0, 0, screenSize.width, screenSize.height);
    final rectTween = RectTween(begin: beginRect, end: endRect);
    final curvedAnimation = CurvedAnimation(parent: animation, curve: curve);

    // 动态获取共享元素位置
    Rect? sharedStartRect;
    Rect? sharedEndRect;
    if (sourceKey != null && targetKey != null) {
      sharedStartRect = _getWidgetRect(sourceKey!);
      sharedEndRect = _getWidgetRect(targetKey!);
    }

    return AnimatedBuilder(
      animation: Listenable.merge([
        rectTween.animate(curvedAnimation),
        curvedAnimation,
      ]),
      builder: (context, child) {
        final currentRect = rectTween.evaluate(curvedAnimation)!;
        final progress = curvedAnimation.value;

        return Stack(
          children: [
            // 主页面动画
            CustomSingleChildLayout(
              delegate: _LayoutDelegate(currentRect),
              child: PhysicalModel(
                color: Colors.transparent,
                elevation: elevation,
                shadowColor: shadowColor,
                borderRadius: borderRadius,
                clipBehavior: clipBehavior,
                child: ClipRRect(
                  borderRadius: borderRadius,
                  clipBehavior: clipBehavior,
                  child: child,
                ),
              ),
            ),

            // 共享元素动画
            if (sharedStartRect != null && sharedEndRect != null)
              _buildSharedElementAnimation(
                context,
                sharedStartRect,
                sharedEndRect,
                progress,
              ),
          ],
        );
      },
      child: child,
    );
  }

  // 获取任意元素的全局坐标
  Rect? _getWidgetRect(GlobalKey key) {
    final renderBox = key.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return null;

    // 关键计算步骤：将局部坐标转换为全局坐标
    final offset = renderBox.localToGlobal(Offset.zero);
    return offset & renderBox.size;
  }

  // 构建共享元素动画
  Widget _buildSharedElementAnimation(
      BuildContext context,
      Rect startRect,
      Rect endRect,
      double progress,
      ) {
    final currentLeft = startRect.left + (endRect.left - startRect.left) * progress;
    final currentTop = startRect.top + (endRect.top - startRect.top) * progress;
    final currentWidth = startRect.width + (endRect.width - startRect.width) * progress;
    final currentHeight = startRect.height + (endRect.height - startRect.height) * progress;

    return Positioned(
      left: currentLeft,
      top: currentTop,
      child: SizedBox(
        width: currentWidth,
        height: currentHeight,
        child: targetKey?.currentWidget ?? const SizedBox(),
      ),
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
  bool shouldRelayout(_LayoutDelegate oldDelegate) => rect != oldDelegate.rect;
}

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
      CustomRoute(
        position: [offset.dx, offset.dy],
        size: [size.width, size.height],
        builder: (context) => Global.routes[widget.route]!(context),
        duration: widget.duration ?? const Duration(milliseconds: 300),
        curve: widget.curve ?? Curves.easeInOut,
        elevation: widget.elevation ?? 8.0,
        shadowColor: widget.shadowColor ?? Colors.black,
        borderRadius: widget.borderRadius ?? BorderRadius.zero,
        clipBehavior: widget.clipBehavior ?? Clip.antiAlias,
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
      CustomRoute(
        position: [offset.dx, offset.dy],
        size: [size.width, size.height],
        builder: widget.builder,
        duration: widget.duration ?? const Duration(milliseconds: 300),
        curve: widget.curve ?? Curves.easeInOut,
        elevation: widget.elevation ?? 8.0,
        shadowColor: widget.shadowColor ?? Colors.black,
        borderRadius: widget.borderRadius ?? BorderRadius.zero,
        clipBehavior: widget.clipBehavior ?? Clip.antiAlias,
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
