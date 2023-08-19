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

  // Add flutter bloc
  await run('flutter pub add flutter_bloc', workingDirectory: appName);

  // Add the specified packages to the generated app
  for (final package in packages) {
    await run('flutter pub add $package', workingDirectory: appName);
  }

  // Custom code to update the default main.dart
  final mainFile = File('$appName/lib/main.dart');
  mainFile.writeAsStringSync(_customMainContent);

  // Create necessary folders and files
  await Directory('$appName/lib/modules/views').create(recursive: true);
  await Directory('$appName/lib/modules/bloc').create(recursive: true);

  final viewsFolder = Directory('$appName/lib/modules/views');
  final blocFolder = Directory('$appName/lib/modules/bloc');

  final demoViewFile = File('${viewsFolder.path}/demo_view.dart');
  final demoBlocFile = File('${blocFolder.path}/demo_bloc.dart');
  final demoEventFile = File('${blocFolder.path}/demo_event.dart');
  final demoStateFile = File('${blocFolder.path}/demo_state.dart');

  demoViewFile.writeAsStringSync(_sampleViewContent);
  demoBlocFile.writeAsStringSync(_sampleBlocContent);
  demoEventFile.writeAsStringSync(_sampleEventContent);
  demoStateFile.writeAsStringSync(_sampleStateContent);

  print(
      'Flutter app "$appName" with packages $packages generated successfully.');
}

const _customMainContent = '''
import 'package:flutter/material.dart';

import 'modules/views/demo_view.dart';

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
      home: const SampleView(),
    );
  }
}
''';

const _sampleViewContent = '''
import 'package:flutter/material.dart';

class SampleView extends StatelessWidget {
  const SampleView({super.key});

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

const _sampleBlocContent = '''
import 'package:flutter_bloc/flutter_bloc.dart';

import 'demo_event.dart';
import 'demo_state.dart';

class SampleBloc extends Bloc<SampleEvent, SampleState> {
  SampleBloc() : super(SampleInitial()) {
    on<SampleEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
''';

const _sampleEventContent = '''
import 'package:flutter/foundation.dart';

@immutable
sealed class SampleEvent {}
''';

const _sampleStateContent = '''
import 'package:flutter/foundation.dart';

@immutable
sealed class SampleState {}

final class SampleInitial extends SampleState {}
''';
