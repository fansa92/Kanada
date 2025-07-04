import 'package:flutter/material.dart';
import 'package:kanada/widgets/link.dart';
import 'package:kanada/widgets/round_list.dart';

class LinkList extends StatelessWidget {
  final List<List<dynamic>> links;
  final Function? onTapBefore; // 新增点击回调
  final Function? onTapAfter; // 新增点击回调

  const LinkList({
    super.key,
    required this.links,
    this.onTapBefore, // 接收回调参数
    this.onTapAfter, // 接收回调参数
  });

  @override
  Widget build(BuildContext context) {
    return RoundListBuilder(
      itemCount: links.length,
      itemBuilder: (context, index) {
        final route = links[index][2] as String; // 明确类型为String
        return Link(
          route: route,
          onTapBefore: onTapBefore, // 传递点击事件到父组件
          onTapAfter: onTapAfter, // 传递点击事件到父组件
          child: ListTile(
            leading: Icon(links[index][0]),
            title: Text(links[index][1]),
            trailing: const Icon(Icons.arrow_forward_ios),
          ),
        );
      },
    );
  }
}