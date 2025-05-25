import 'package:flutter/material.dart';

class RoundList extends StatelessWidget {
  final List<Widget> children;

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

class RoundListBuilder extends StatelessWidget {
  final int itemCount;
  final Widget Function(BuildContext context, int index) itemBuilder;

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
