import 'package:anadea_flutter_loggy/anadea_flutter_loggy.dart';
import 'package:dio/dio.dart' hide LogInterceptor;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_loggy/flutter_loggy.dart';
import 'package:loggy/loggy.dart';

import 'bloc/example_bloc.dart';

void main() {
  BlocOverrides.runZoned(
    () async {
      Loggy.initLoggy(
        logPrinter: StreamPrinter(const PrettyPrinter()),
      );

      runApp(ExampleApp());
    },
    blocObserver: LogBlocObserver(),
  );
}

class ExampleApp extends StatelessWidget {
  ExampleApp({Key? key}) : super(key: key);

  final _navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navigatorKey,
      navigatorObservers: [LogNavigatorObserver()],
      home: BlocProvider(
        create: (context) => ExampleBloc(),
        child: DemoPage(),
      ),
      builder: (context, child) => Inspector(
        customRecordBuilders: {
          TestLogModel: (context, record) => Text(record.object.toString())
        },
        navigatorKey: _navigatorKey,
        child: child!,
      ),
    );
  }
}

class DemoPage extends StatelessWidget {
  DemoPage({
    Key? key,
  }) : super(key: key);

  final dio = Dio()..interceptors.add(LogInterceptor());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Loggy demo",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                logInfo('message');
              },
              child: Text("log message"),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                logWarning("warning message");
              },
              child: Text("log warning"),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                logDebug("debug message");
              },
              child: Text("log debug"),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                logError("error message");
              },
              child: Text("log error"),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                logError(TestLogModel('content'));
              },
              child: Text("log speciffic type"),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                dio.get(
                  'http://www.7timer.info/bin/api.pl?lon=113.17&lat=23.09&product=astro&output=json',
                );
                dio.get(
                  'http://www.7timer.info/bn/api.pl?lon=113.17&lat=23.09&product=astro&output=json',
                );
              },
              child: Text("test dio logs"),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                BlocProvider.of<ExampleBloc>(context)
                    .add(const GetExampleData());
              },
              child: Text("test bloc logs"),
            ),
          ],
        ),
      ),
    );
  }
}

class TestLogModel {
  TestLogModel(this.content);

  final String content;
}
