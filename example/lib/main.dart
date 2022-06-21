import 'package:anadea_flutter_loggy/anadea_flutter_loggy.dart';
import 'package:flutter/material.dart';
import 'package:flutter_loggy/flutter_loggy.dart';
import 'package:loggy/loggy.dart';

void main() {
  Loggy.initLoggy(
    logPrinter: StreamPrinter(const PrettyPrinter()),
  );

  runApp(ExampleApp());
}

class ExampleApp extends StatelessWidget {
  ExampleApp({Key? key}) : super(key: key);

  final _navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navigatorKey,
      navigatorObservers: [LogNavigatorObserver()],
      home: const DemoPage(),
      builder: (context, child) => LogsButton(
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
  const DemoPage({
    Key? key,
  }) : super(key: key);

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
