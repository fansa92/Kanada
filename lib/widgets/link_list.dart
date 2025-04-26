import 'package:flutter/material.dart';
import 'package:kanada/widgets/link.dart';

class LinkList extends StatelessWidget {
  final List<List<dynamic>> links;
  final Function? onTap; // 新增点击回调

  const LinkList({
    super.key,
    required this.links,
    this.onTap, // 接收回调参数
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: links.length,
      itemBuilder: (context, index) {
        final route = links[index][2] as String; // 明确类型为String
        return Link(
          route: route,
          onTap: onTap, // 传递点击事件到父组件
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