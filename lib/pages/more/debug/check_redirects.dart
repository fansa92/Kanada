import 'package:flutter/material.dart';
import 'package:kanada/tool.dart';

class CheckRedirectsDebug extends StatefulWidget {
  const CheckRedirectsDebug({super.key});
  @override
  State<CheckRedirectsDebug> createState() => _CheckRedirectsDebugState();
}
class _CheckRedirectsDebugState extends State<CheckRedirectsDebug> {
  final TextEditingController _controller = TextEditingController();
  String data = '';
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Check Redirects'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'Enter URL',
              ),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () async {
                data=(await checkRedirects(_controller.text));
                setState(() {});
              },
              child: const Text('Check Redirects'),
            ),
            const SizedBox(height: 16.0),
            Text('Location: ${data.toString()}'),
            Text('Uri: ${Uri.parse(data).path}'),
            Text('Get Args: ${Uri.parse(data).queryParameters}'),
          ]
        )
      )
    );
  }
}