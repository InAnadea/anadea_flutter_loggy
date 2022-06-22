import 'package:flutter/material.dart';
import 'package:loggy/loggy.dart';

mixin NavigationLoggy implements LoggyType {
  @override
  Loggy<NavigationLoggy> get loggy => Loggy<NavigationLoggy>('Navigation');
}

enum NavigationLogRecordType {
  didPop,
  didPush,
  didRemove,
  didReplace,
  didStartUserGesture,
  didStopUserGesture,
}

class NavigationLogRecord {
  final Route? route;
  final Route? secondRoute;
  final NavigationLogRecordType type;

  NavigationLogRecord({this.route, this.secondRoute, required this.type});

  factory NavigationLogRecord.didPop(Route route, Route? previousRoute) =>
      NavigationLogRecord(
        route: route,
        secondRoute: previousRoute,
        type: NavigationLogRecordType.didPop,
      );

  factory NavigationLogRecord.didPush(Route route, Route? previousRoute) =>
      NavigationLogRecord(
        route: route,
        secondRoute: previousRoute,
        type: NavigationLogRecordType.didPush,
      );

  factory NavigationLogRecord.didRemove(Route route, Route? previousRoute) =>
      NavigationLogRecord(
        route: route,
        secondRoute: previousRoute,
        type: NavigationLogRecordType.didRemove,
      );

  factory NavigationLogRecord.didReplace(Route? newRoute, Route? oldRoute) =>
      NavigationLogRecord(
        route: newRoute,
        secondRoute: oldRoute,
        type: NavigationLogRecordType.didReplace,
      );

  factory NavigationLogRecord.didStartUserGesture(
          Route route, Route? previousRoute) =>
      NavigationLogRecord(
        route: route,
        secondRoute: previousRoute,
        type: NavigationLogRecordType.didStartUserGesture,
      );

  factory NavigationLogRecord.didStopUserGesture() => NavigationLogRecord(
        type: NavigationLogRecordType.didStopUserGesture,
      );

  @override
  String toString() {
    final String title;
    switch (type) {
      case NavigationLogRecordType.didRemove:
      case NavigationLogRecordType.didPop:
        title = '"${secondRoute?.settings.name ?? 'undefined route name'}"'
            ' <<< "${route?.settings.name ?? 'undefined route name'}"';
        break;

      case NavigationLogRecordType.didReplace:
      case NavigationLogRecordType.didPush:
        title = '"${secondRoute?.settings.name ?? 'undefined route name'}"'
            ' >>> "${route?.settings.name ?? 'undefined route name'}"';
        break;

      case NavigationLogRecordType.didStartUserGesture:
        title = 'Gesture started';
        break;
      case NavigationLogRecordType.didStopUserGesture:
        title = 'Gesture stoped';
        break;
    }
    return title;
  }
}

class LogNavigatorObserver extends NavigatorObserver with NavigationLoggy {
  @override
  void didPop(Route route, Route? previousRoute) {
    _log(NavigationLogRecord.didPop(route, previousRoute));
  }

  @override
  void didPush(Route route, Route? previousRoute) {
    _log(NavigationLogRecord.didPush(route, previousRoute));
  }

  @override
  void didRemove(Route route, Route? previousRoute) {
    _log(NavigationLogRecord.didRemove(route, previousRoute));
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    _log(NavigationLogRecord.didReplace(newRoute, oldRoute));
  }

  @override
  void didStartUserGesture(Route route, Route? previousRoute) {
    _log(NavigationLogRecord.didStartUserGesture(route, previousRoute));
  }

  @override
  void didStopUserGesture() {
    _log(NavigationLogRecord.didStopUserGesture());
  }

  void _log(NavigationLogRecord record) {
    loggy.log(LogLevel.info, record);
  }
}
