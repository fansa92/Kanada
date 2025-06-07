import 'package:flutter/material.dart';

class ColorDebug extends StatefulWidget {
  const ColorDebug({super.key});

  @override
  State<ColorDebug> createState() => _ColorDebugState();
}

class _ColorDebugState extends State<ColorDebug> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Color Debug')),
      body: ListView(
        children: [
          Container(
            color: Theme.of(context).primaryColor,
            height: 100,
            child: ListTile(
              title: Text('Primary'),
              subtitle: Text(
                '#${Theme.of(context).primaryColor.toARGB32().toRadixString(16).padLeft(8, '0').toUpperCase()}',
              ),
              trailing: Icon(Icons.color_lens),
            ),
          ),
          Container(
            color: Theme.of(context).colorScheme.primary,
            height: 100,
            child: ListTile(
              title: Text(
                'Primary',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
              subtitle: Text(
                '#${Theme.of(context).colorScheme.primary.toARGB32().toRadixString(16).padLeft(8, '0').toUpperCase()}\n#${Theme.of(context).colorScheme.onPrimary.toARGB32().toRadixString(16).padLeft(8, '0').toUpperCase()}',
              ),
              trailing: Icon(Icons.color_lens),
            ),
          ),
          Container(
            color: Theme.of(context).colorScheme.primaryContainer,
            height: 100,
            child: ListTile(
              title: Text(
                'Primary Container',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
              subtitle: Text(
                '#${Theme.of(context).colorScheme.primaryContainer.toARGB32().toRadixString(16).padLeft(8, '0').toUpperCase()}\n#${Theme.of(context).colorScheme.onPrimaryContainer.toARGB32().toRadixString(16).padLeft(8, '0').toUpperCase()}',
              ),
              trailing: Icon(Icons.color_lens),
            ),
          ),
          Container(
            color: Theme.of(context).colorScheme.secondary,
            height: 100,
            child: ListTile(
              title: Text(
                'Secondary',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSecondary,
                ),
              ),
              subtitle: Text(
                '#${Theme.of(context).colorScheme.secondary.toARGB32().toRadixString(16).padLeft(8, '0').toUpperCase()}\n#${Theme.of(context).colorScheme.onSecondary.toARGB32().toRadixString(16).padLeft(8, '0').toUpperCase()}',
              ),
              trailing: Icon(Icons.color_lens),
            ),
          ),
          Container(
            color: Theme.of(context).colorScheme.secondaryContainer,
            height: 100,
            child: ListTile(
              title: Text(
                'Secondary Container',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSecondaryContainer,
                ),
              ),
              subtitle: Text(
                '#${Theme.of(context).colorScheme.secondaryContainer.toARGB32().toRadixString(16).padLeft(8, '0').toUpperCase()}\n#${Theme.of(context).colorScheme.onSecondaryContainer.toARGB32().toRadixString(16).padLeft(8, '0').toUpperCase()}',
              ),
              trailing: Icon(Icons.color_lens),
            ),
          ),
          Container(
            color: Theme.of(context).colorScheme.tertiary,
            height: 100,
            child: ListTile(
              title: Text(
                'Tertiary',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onTertiary,
                ),
              ),
              subtitle: Text(
                '#${Theme.of(context).colorScheme.tertiary.toARGB32().toRadixString(16).padLeft(8, '0').toUpperCase()}\n#${Theme.of(context).colorScheme.onTertiary.toARGB32().toRadixString(16).padLeft(8, '0').toUpperCase()}',
              ),
              trailing: Icon(Icons.color_lens),
            ),
          ),
          Container(
            color: Theme.of(context).colorScheme.tertiaryContainer,
            height: 100,
            child: ListTile(
              title: Text(
                'Tertiary Container',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onTertiaryContainer,
                ),
              ),
              subtitle: Text(
                '#${Theme.of(context).colorScheme.tertiaryContainer.toARGB32().toRadixString(16).padLeft(8, '0').toUpperCase()}\n#${Theme.of(context).colorScheme.onTertiaryContainer.toARGB32().toRadixString(16).padLeft(8, '0').toUpperCase()}',
              ),
              trailing: Icon(Icons.color_lens),
            ),
          ),
          Container(
            color: Theme.of(context).colorScheme.error,
            height: 100,
            child: ListTile(
              title: Text(
                'Error',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onError,
                ),
              ),
              subtitle: Text(
                '#${Theme.of(context).colorScheme.error.toARGB32().toRadixString(16).padLeft(8, '0').toUpperCase()}\n#${Theme.of(context).colorScheme.onError.toARGB32().toRadixString(16).padLeft(8, '0').toUpperCase()}',
              ),
              trailing: Icon(Icons.color_lens),
            ),
          ),
          Container(
            color: Theme.of(context).colorScheme.errorContainer,
            height: 100,
            child: ListTile(
              title: Text(
                'Error Container',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onErrorContainer,
                ),
              ),
              subtitle: Text(
                '#${Theme.of(context).colorScheme.errorContainer.toARGB32().toRadixString(16).padLeft(8, '0').toUpperCase()}\n#${Theme.of(context).colorScheme.onErrorContainer.toARGB32().toRadixString(16).padLeft(8, '0').toUpperCase()}',
              ),
              trailing: Icon(Icons.color_lens),
            ),
          ),
        ],
      ),
    );
  }
}
