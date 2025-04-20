import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ToastDebug extends StatefulWidget {
  const ToastDebug({super.key});
  @override
  State<ToastDebug> createState() => _ToastDebugState();
}
class _ToastDebugState extends State<ToastDebug> {
  String echo = '';
  bool longToast = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Toast Debug'),
        ),
        body: Column(
          children: [
            TextField(
              decoration: const InputDecoration(
                hintText: 'Enter your message',
              ),
              onChanged: (value) {
                echo = value;
              },
            ),
            Row(
              children: [
                Checkbox(
                  value: longToast,
                  onChanged: (value) {
                    setState(() {
                      longToast = value!;
                    });
                  },
                ),
                const Text('Long Toast'),
              ]
            ),
            ElevatedButton(
              onPressed: () {
                Fluttertoast.showToast(
                    msg: echo,
                    toastLength: longToast?Toast.LENGTH_LONG:Toast.LENGTH_SHORT,
                );
              },
              child: const Text('Show Toast'),
            )
          ],
        ),
    );
  }
}