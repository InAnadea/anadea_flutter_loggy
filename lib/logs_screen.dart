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
    this.customRecordBuilders = const {},
  }) : super(key: key);

  /// Minimum level for log records
  final LogLevel? logLevel;

  /// Custom bulders for speciffic [LogRecord] objects.
  final Map<Type, LogRecordCardBuilder> customRecordBuilders;

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

        final SplayTreeMap<String, List<LogRecord>> groupedRecords =
            SplayTreeMap((a, b) => a.compareTo(b));
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
                isScrollable: true,
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
                        if (record.object is NavigationLogRecord)
                          _buildNavigationRecord(
                            context,
                            record.object as NavigationLogRecord,
                          )
                        else if (record.object is DioLogRecord)
                          _buildDioRecord(
                            context,
                            record.object as DioLogRecord,
                          )
                        else if (customRecordBuilders
                            .containsKey(record.object.runtimeType))
                          customRecordBuilders[record.object.runtimeType]!
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

  Widget _buildNavigationRecord(
    BuildContext context,
    NavigationLogRecord record,
  ) {
    return Card(
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          record.toString(),
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
    );
  }

  Widget _buildDioRecord(BuildContext context, DioLogRecord record) {
    final theme = Theme.of(context);
    return Card(
      elevation: 5,
      color: _getDioRecordColor(context, record),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              record.toString(),
              style: theme.textTheme.bodyLarge,
            ),
            if (record.options != null) ...[
              if (record.options!.headers.isNotEmpty) ...[
                const Divider(),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'HEADERS',
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
                JsonViewer(record.options!.headers),
              ],
              if (record.options!.data != null) ...[
                const Divider(),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'DATA',
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
                if (record.options!.data is String)
                  JsonViewer(jsonDecode(record.options!.data))
                else
                  JsonViewer(record.options!.data)
              ],
            ],
            if (record.response != null) ...[
              const Divider(),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'HEADERS',
                  style: theme.textTheme.bodyMedium,
                ),
              ),
              JsonViewer(record.response!.headers.map),
              const Divider(),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'DATA',
                  style: theme.textTheme.bodyMedium,
                ),
              ),
              if (record.response!.data is String)
                JsonViewer(jsonDecode(record.response!.data))
              else
                JsonViewer(record.response!.data)
            ],
            if (record.error != null) ...[
              const Divider(),
              Text(record.error!.message),
            ],
          ],
        ),
      ),
    );
  }

  Color _getDioRecordColor(BuildContext context, DioLogRecord record) {
    final colorScheme = Theme.of(context).colorScheme;

    switch (record.type) {
      case DioLogRecordType.error:
        return colorScheme.errorContainer;

      case DioLogRecordType.request:
      case DioLogRecordType.response:
        return colorScheme.surface;
    }
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
      child: ListTile(
        title: Text(
          '${record.level.name.toUpperCase()} - $timeStr',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        subtitle: Text(
          record.message,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
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
