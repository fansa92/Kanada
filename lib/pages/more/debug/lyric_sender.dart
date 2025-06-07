import 'package:flutter/material.dart';
import 'package:kanada_lyric_sender/kanada_lyric_sender.dart';

class LyricSenderDebug extends StatefulWidget {
  const LyricSenderDebug({super.key});
  @override
  State<LyricSenderDebug> createState() => _LyricSenderDebugState();
}

class _LyricSenderDebugState extends State<LyricSenderDebug> {
  final TextEditingController _controller = TextEditingController();
  final TextEditingController _delayController = TextEditingController();
  bool state=false;

  @override
  void initState() {
    super.initState();
    KanadaLyricSenderPlugin.hasEnable().then((value) {
      setState(() {
        state=value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lyric Sender Debug'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'Lyric',
              )
            ),
            TextField(
              controller: _delayController,
              decoration: const InputDecoration(
                labelText: 'Delay',
              )
            ),
            ElevatedButton(
              onPressed: () {
                int delay=0;
                try {
                  delay=int.parse(_delayController.text);
                }
                catch (e) {
                  delay=0;
                }
                KanadaLyricSenderPlugin.sendLyric(_controller.text, delay);
              },
              child: const Text('Send Lyric'),
            ),
            ElevatedButton(
              onPressed: () {
                KanadaLyricSenderPlugin.clearLyric();
              },
              child: const Text('Clear Lyric'),
            ),
            Text('状态: $state')
          ]
        )
      )
    );
  }
}