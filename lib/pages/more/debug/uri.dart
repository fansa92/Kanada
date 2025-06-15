import 'package:flutter/material.dart';

class UriDebug extends StatefulWidget {
  const UriDebug({super.key});
  @override
  State<UriDebug> createState() => _UriDebugState();
}
class _UriDebugState extends State<UriDebug> {
  final controller = TextEditingController();
  @override
  void initState() {
    super.initState();
    controller.text = 'kanada://netease/playlist?id=3779629';
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Uri Debug'),
      ),
      body: ListView(
        children: [
          TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Uri',
            ),
            onChanged: (value) {
              setState(() {});
            }
          ),
          ListTile(
            title: Text('toString'),
            subtitle: Text(Uri.parse(controller.text).toString()),
          ),
          ListTile(
            title: Text('scheme'),
            subtitle: Text(Uri.parse(controller.text).scheme),
          ),
          ListTile(
            title: Text('authority'),
            subtitle: Text(Uri.parse(controller.text).authority),
          ),
          ListTile(
            title: Text('path'),
            subtitle: Text(Uri.parse(controller.text).path),
          ),
          ListTile(
            title: Text('query'),
            subtitle: Text(Uri.parse(controller.text).query),
          ),
          ListTile(
            title: Text('fragment'),
            subtitle: Text(Uri.parse(controller.text).fragment),
          ),
          ListTile(
            title: Text('queryParameters'),
            subtitle: Text(Uri.parse(controller.text).queryParameters.toString()),
          ),
          ListTile(
            title: Text('queryParametersAll'),
            subtitle: Text(Uri.parse(controller.text).queryParametersAll.toString()),
          )
        ]
      )
    );
  }
}