import 'package:flutter/material.dart';
import 'package:kanada/widgets/link.dart';

class LinkList extends StatefulWidget {
  final List<List<dynamic>> links;

  const LinkList({super.key, required this.links});

  @override
  State<LinkList> createState() => _LinkListState();
}

class _LinkListState extends State<LinkList> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: widget.links.length,
      itemBuilder: (context, index) {
        return Link(
          route: widget.links[index][2],
          child: ListTile(
            leading: Icon(widget.links[index][0]),
            title: Text(widget.links[index][1]),
            trailing: Icon(Icons.arrow_forward_ios),
          ),
        );
      },
    );
  }
}
