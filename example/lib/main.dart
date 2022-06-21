import 'package:anadea_flutter_loggy/anadea_flutter_loggy.dart';
import 'package:flutter/material.dart';
import 'package:flutter_loggy/flutter_loggy.dart';
import 'package:loggy/loggy.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Loggy.initLoggy(
    logPrinter: StreamPrinter(const PrettyPrinter()),
  );

  runApp(const ExampleApp());
}

class ExampleApp extends StatelessWidget {
  const ExampleApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: DemoPage(),
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
              child: Text("log warning"),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                logWarning("warning message");
              },
              child: Text("log message"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LogsScreen()),
                );
              },
              child: Text("Open Logs"),
            ),
          ],
        ),
      ),
    );
  }
}
