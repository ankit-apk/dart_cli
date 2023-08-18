import 'dart:io';

import 'package:args/args.dart';
import 'package:process_run/process_run.dart';

void createApp(List<String> arguments) async {
  final parser = ArgParser()
    ..addMultiOption(
      'packages',
      abbr: 'p',
      help: 'List of pub packages',
    )
    ..addMultiOption(
      'appName',
      abbr: 'n',
      help: 'Name of your application',
    );

  final results = parser.parse(arguments);
  final packages = results['packages'];
  final appName = results['appName'][0];

  if (packages.isEmpty) {
    print('Please provide at least one package using the -p flag.');
    return;
  }
  if (appName.isEmpty) {
    print('Please provide an app name');
    return;
  }

  await run('flutter create $appName');

  // Add the specified packages to the generated app
  for (final package in packages) {
    await run('flutter pub add $package', workingDirectory: appName);
  }

  // Custom code to update the default main.dart
  final mainFile = File('$appName/lib/main.dart');
  mainFile.writeAsStringSync(_customMainContent);

  print(
      'Flutter app "$appName" with packages $packages generated successfully.');
}

const _customMainContent = '''
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Custom Flutter App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const CustomScreen(),
    );
  }
}

class CustomScreen extends StatelessWidget {
  const CustomScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Custom Screen'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Add your button's onPressed logic here
          },
          child: const Text('Click Me'),
        ),
      ),
    );
  }
}
''';
