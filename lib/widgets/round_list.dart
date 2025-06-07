import 'package:flutter/material.dart';

/// 圆角列表容器组件
///
/// 接收预构建的子组件列表，自动处理圆角边框样式
class RoundList extends StatelessWidget {
  final List<Widget> children;

  /// 构造函数
  ///
  /// [children] 子组件列表（必需）
  const RoundList({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return RoundListBuilder(
      itemCount: children.length,
      itemBuilder: (context, index) {
        return children[index];
      },
    );
  }
}

/// 可定制的圆角列表组件（使用构建器模式）
///
/// 支持动态构建列表项，适用于大数据量或需要动态生成的列表
class RoundListBuilder extends StatelessWidget {
  final int itemCount;
  final Widget Function(BuildContext context, int index) itemBuilder;

  /// 构造函数
  ///
  /// [itemCount]   列表项总数（必需）
  /// [itemBuilder] 列表项构建回调（必需）
  const RoundListBuilder({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: itemCount,
      itemBuilder:
          (context, index) => Container(child: itemBuilder(context, index)),
    );
  }
}
