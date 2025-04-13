import 'package:flutter/material.dart';

class LinkDebug extends StatefulWidget {
  const LinkDebug({super.key});
  @override
  State<LinkDebug> createState() => _LinkDebugState();
}

class _LinkDebugState extends State<LinkDebug> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Link Debug Page'),
      ),
      backgroundColor: Theme.of(context).colorScheme.primary,
    );
  }
}