part of anadea_flutter_loggy;

class WrongPrinterException implements Exception {
  WrongPrinterException();

  @override
  String toString() {
    return 'ERROR: Loggy printer is not set as StreamPrinter!\n\n';
  }
}

class LogsScreen extends StatelessWidget {
  const LogsScreen({
    this.logLevel = LogLevel.all,
    Key? key,
  }) : super(key: key);

  final LogLevel? logLevel;

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

          if (groupedRecords.containsKey(record.loggerName)) {
            groupedRecords[record.loggerName] = [];
          }
          groupedRecords[record.loggerName]!.add(record);
        }

        return DefaultTabController(
          length: groupedRecords.keys.length,
          child: Scaffold(
            appBar: TabBar(tabs: [
              for (final loggerName in groupedRecords.keys)
                Tab(text: loggerName)
            ]),
            body: TabBarView(
              children: [
                for (final loggerName in groupedRecords.keys)
                  ListView(
                    reverse: true,
                    children: [
                      for (final record in groupedRecords[loggerName]!)
                        _CustomLoggyItemWidget(record)
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

class _CustomLoggyItemWidget extends StatelessWidget {
  const _CustomLoggyItemWidget(this.record, {Key? key}) : super(key: key);

  final LogRecord record;

  @override
  Widget build(BuildContext context) {
    final Color logColor = _getLogColor();
    final String time = record.time.toIso8601String().split('T')[1];
    const Color dividerColor = Colors.white;

    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 2.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Flexible(
                    child: Text(
                      '${record.level.name.toUpperCase()} - $time',
                      style: Theme.of(context).textTheme.bodyText2!.copyWith(
                            color: logColor,
                            fontWeight: FontWeight.w700,
                            fontSize: 12.0,
                          ),
                    ),
                  ),
                  Text(
                    record.loggerName,
                    style: Theme.of(context).textTheme.bodyText2!.copyWith(
                          color: logColor,
                          fontWeight: FontWeight.w400,
                          fontSize: 14.0,
                        ),
                  ),
                ],
              ),
              subtitle: Text(
                record.message,
                style: Theme.of(context).textTheme.bodyText2!.copyWith(
                      color: logColor,
                      fontWeight: _getTextWeight(),
                      fontSize: 14.0,
                    ),
                maxLines: 2,
              ),
              children: [
                Text(
                  record.message,
                  style: Theme.of(context).textTheme.bodyText2!.copyWith(
                        color: logColor,
                        fontWeight: _getTextWeight(),
                        fontSize: 16.0,
                      ),
                ),
              ],
            ),
          ),
          const Divider(
            color: dividerColor,
          ),
        ],
      ),
    );
  }

  FontWeight _getTextWeight() {
    switch (record.level) {
      case LogLevel.error:
        return FontWeight.w700;
      case LogLevel.debug:
        return FontWeight.w300;
      case LogLevel.info:
        return FontWeight.w300;
      case LogLevel.warning:
        return FontWeight.w400;
    }

    return FontWeight.w300;
  }

  Color _getLogColor() {
    switch (record.level) {
      case LogLevel.error:
        return Colors.redAccent;
      case LogLevel.debug:
        return Colors.lightBlue;
      case LogLevel.info:
        return Colors.lightGreen;
      case LogLevel.warning:
        return Colors.yellow;
    }

    return Colors.white;
  }
}
