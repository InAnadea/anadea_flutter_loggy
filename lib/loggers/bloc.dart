part of anadea_flutter_loggy;

mixin BlocLoggy implements LoggyType {
  @override
  Loggy<BlocLoggy> get loggy => Loggy<BlocLoggy>('Bloc (Business logic)');
}

enum BlocLogRecordType {
  onCreate,
  onEvent,
  onChange,
  onTransition,
  onError,
  onClose,
}

class BlocLogRecord {
  BlocLogRecord({
    required this.type,
    this.bloc,
    this.event,
    this.change,
    this.transition,
    this.error,
    this.stackTrace,
  });

  factory BlocLogRecord.onCreate(BlocBase bloc) => BlocLogRecord(
        type: BlocLogRecordType.onCreate,
        bloc: bloc,
      );

  factory BlocLogRecord.onEvent(BlocBase bloc, Object? event) => BlocLogRecord(
        type: BlocLogRecordType.onEvent,
        bloc: bloc,
        event: event,
      );

  factory BlocLogRecord.onChange(BlocBase bloc, Change change) => BlocLogRecord(
        type: BlocLogRecordType.onChange,
        bloc: bloc,
        change: change,
      );

  factory BlocLogRecord.onTransition(BlocBase bloc, Transition transition) =>
      BlocLogRecord(
        type: BlocLogRecordType.onTransition,
        bloc: bloc,
        transition: transition,
      );

  factory BlocLogRecord.onError(
    BlocBase bloc,
    Object error,
    StackTrace stackTrace,
  ) =>
      BlocLogRecord(
        type: BlocLogRecordType.onError,
        bloc: bloc,
        error: error,
        stackTrace: stackTrace,
      );

  factory BlocLogRecord.onClose(BlocBase bloc) => BlocLogRecord(
        type: BlocLogRecordType.onClose,
        bloc: bloc,
      );

  final BlocLogRecordType type;
  final BlocBase? bloc;
  final Object? event;
  final Change? change;
  final Transition? transition;
  final Object? error;
  final StackTrace? stackTrace;
}

class LogBlocObserver extends BlocObserver with BlocLoggy {
  @override
  void onCreate(BlocBase bloc) {
    super.onCreate(bloc);
    log(BlocLogRecord.onCreate(bloc));
  }

  @override
  void onEvent(Bloc bloc, Object? event) {
    super.onEvent(bloc, event);
    log(BlocLogRecord.onEvent(bloc, event));
  }

  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    log(BlocLogRecord.onChange(bloc, change));
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    log(BlocLogRecord.onTransition(bloc, transition));
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    super.onError(bloc, error, stackTrace);
    log(BlocLogRecord.onError(bloc, error, stackTrace), LogLevel.error);
  }

  @override
  void onClose(BlocBase bloc) {
    super.onClose(bloc);
    log(BlocLogRecord.onClose(bloc));
  }

  void log(
    BlocLogRecord record, [
    LogLevel level = LogLevel.info,
  ]) {
    loggy.log(level, record);
  }
}
