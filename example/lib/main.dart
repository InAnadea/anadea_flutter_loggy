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
      home: const DemoPage(),
      builder: (context, child) => LogsButton(
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
          ],
        ),
      ),
    );
  }
}
