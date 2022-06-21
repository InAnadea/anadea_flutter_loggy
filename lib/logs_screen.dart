part of anadea_flutter_loggy;

class WrongPrinterException implements Exception {
  WrongPrinterException();

  @override
  String toString() {
    return 'WrongPrinterException: Loggy printer is not set as StreamPrinter!';
  }
}

typedef LogRecordCardBuilder = Widget Function(
  BuildContext context,
  LogRecord record,
);

class LogsScreen extends StatelessWidget {
  const LogsScreen({
    this.logLevel = LogLevel.all,
    Key? key,
    this.builders = const {},
  }) : super(key: key);

  final LogLevel? logLevel;
  final Map<Type, LogRecordCardBuilder> builders;

  @override
  Widget build(BuildContext context) {
    if (Loggy.currentPrinter is! StreamPrinter ||
        Loggy.currentPrinter == null) {
      throw WrongPrinterException();
    }
    final StreamPrinter printer = Loggy.currentPrinter as StreamPrinter;

    return StreamBuilder<List<LogRecord>>(
      stream: printer.logRecord,
      builder: (
        BuildContext context,
        AsyncSnapshot<List<LogRecord>> records,
      ) {
        if (!records.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final Map<String, List<LogRecord>> groupedRecords = {};
        for (final record in records.data!) {
          if (record.level.priority < logLevel!.priority) continue;

          if (!groupedRecords.containsKey(record.loggerName)) {
            groupedRecords[record.loggerName] = [];
          }
          groupedRecords[record.loggerName]!.add(record);
        }

        return DefaultTabController(
          length: groupedRecords.keys.length,
          child: Scaffold(
            appBar: AppBar(
              bottom: TabBar(
                tabs: [
                  for (final loggerName in groupedRecords.keys)
                    Tab(text: loggerName)
                ],
              ),
            ),
            body: TabBarView(
              children: [
                for (final loggerName in groupedRecords.keys)
                  ListView(
                    reverse: true,
                    children: [
                      for (final record in groupedRecords[loggerName]!)
                        if (builders.containsKey(record.object.runtimeType))
                          builders[record.object.runtimeType]!
                              .call(context, record)
                        else
                          _DefaultLoggyItemWidget(record)
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _DefaultLoggyItemWidget extends StatelessWidget {
  const _DefaultLoggyItemWidget(this.record, {Key? key}) : super(key: key);

  final LogRecord record;

  @override
  Widget build(BuildContext context) {
    final String timeStr = record.time.toIso8601String().split('T')[1];

    return Card(
      clipBehavior: Clip.hardEdge,
      color: _getLogColor(context),
      child: ExpansionTile(
        expandedAlignment: Alignment.topCenter,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Expanded(
              child: Text(
                '${record.level.name.toUpperCase()} - $timeStr',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            Flexible(
              child: Text(
                record.loggerName,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ),
        subtitle: Text(
          record.message,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        children: [
          Text(
            record.message,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Color _getLogColor(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    switch (record.level) {
      case LogLevel.info:
        return colorScheme.surface;

      case LogLevel.debug:
        return colorScheme.surfaceVariant;

      case LogLevel.warning:
        return colorScheme.tertiaryContainer;

      case LogLevel.error:
        return colorScheme.errorContainer;
    }

    return Colors.white;
  }
}
