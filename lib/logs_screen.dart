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
  LogsScreen({
    this.logLevel = LogLevel.all,
    Key? key,
    Map<Type, LogRecordCardBuilder> customRecordBuilders = const {},
  })  : customRecordBuilders = {
          ...customRecordBuilders,
          DioLogRecord: LogsScreen._buildDioRecord,
          NavigationLogRecord: LogsScreen._buildNavigationRecord,
          BlocLogRecord: LogsScreen._buildBlocRecord,
        },
        super(key: key);

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
                        if (customRecordBuilders
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

  static Widget _buildNavigationRecord(
    BuildContext context,
    LogRecord record,
  ) {
    var theme = Theme.of(context);
    return Card(
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              record.object.toString(),
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 10),
            Text(
              record.time.toIso8601String().split('T')[1],
              style: theme.textTheme.caption,
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildDioRecord(BuildContext context, LogRecord record) {
    final theme = Theme.of(context);
    final dioLogRecord = record.object as DioLogRecord;
    return Card(
      elevation: 5,
      color: _getDioRecordColor(context, dioLogRecord),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              dioLogRecord.toString(),
              style: theme.textTheme.bodyLarge,
            ),
            if (dioLogRecord.options != null) ...[
              if (dioLogRecord.options!.headers.isNotEmpty) ...[
                const Divider(),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'HEADERS',
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
                JsonViewer(dioLogRecord.options!.headers),
              ],
              if (dioLogRecord.options!.data != null) ...[
                const Divider(),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'DATA',
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
                if (dioLogRecord.options!.data is String)
                  JsonViewer(json.decode(dioLogRecord.options!.data))
                else
                  JsonViewer(dioLogRecord.options!.data)
              ],
            ],
            if (dioLogRecord.response != null) ...[
              const Divider(),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'HEADERS',
                  style: theme.textTheme.bodyMedium,
                ),
              ),
              JsonViewer(dioLogRecord.response!.headers.map),
              const Divider(),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'DATA',
                  style: theme.textTheme.bodyMedium,
                ),
              ),
              if (dioLogRecord.response!.data is String)
                JsonViewer(json.decode(dioLogRecord.response!.data))
              else
                JsonViewer(dioLogRecord.response!.data)
            ],
            if (record.error != null) ...[
              const Divider(),
              Text(dioLogRecord.error!.message),
            ],
            const SizedBox(height: 10),
            Text(
              record.time.toIso8601String().split('T')[1],
              style: theme.textTheme.caption,
            ),
          ],
        ),
      ),
    );
  }

  static Color _getDioRecordColor(BuildContext context, DioLogRecord record) {
    final colorScheme = Theme.of(context).colorScheme;

    switch (record.type) {
      case DioLogRecordType.error:
        return colorScheme.errorContainer;

      case DioLogRecordType.request:
      case DioLogRecordType.response:
        return colorScheme.surface;
    }
  }

  static Widget _buildBlocRecord(BuildContext context, LogRecord record) {
    final blocRecord = record.object as BlocLogRecord;
    final theme = Theme.of(context);

    return Card(
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              blocRecord.toString(),
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 10),
            Text(
              record.time.toIso8601String().split('T')[1],
              style: theme.textTheme.caption,
            ),
          ],
        ),
      ),
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
