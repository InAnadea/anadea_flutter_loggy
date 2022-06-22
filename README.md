A `loggy` extensions package.

## Features

* Logs inspector
* Dio integrations
* Navigation logging

## Getting started

You can use this package with `loggy` package. Add `loggy` and `anadea_flutter_loggy` dependencies to your project.

## Usage
For inspector overlay simply add inspector wrapper to the app builder.

```dart
class ExampleApp extends StatelessWidget {
  ExampleApp({Key? key}) : super(key: key);

  final _navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navigatorKey,
      builder: (context, child) => Inspector(
        navigatorKey: _navigatorKey,
        child: child!,
      ),
      ...
    );
  }
}
```

`_navigatorKey` used for navigation to the `LogsScreen`.

# Dio integration

For dio logging add `LogInterceptor` to the dio instanse.

```dart
final dio = Dio()..interceptors.add(LogInterceptor());
```

# Navigator integration

Add `LogNavigatorObserver` to the navigator.

```dart
@override
Widget build(BuildContext context) {
    return MaterialApp(
        navigatorKey: _navigatorKey,
        navigatorObservers: [LogNavigatorObserver()], // This line
        builder: (context, child) => Inspector(
            navigatorKey: _navigatorKey,
            child: child!,
        ),
        ...
    );
}
```
