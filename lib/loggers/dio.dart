import 'package:dio/dio.dart';
import 'package:loggy/loggy.dart';

mixin DioLoggy implements LoggyType {
  @override
  Loggy<DioLoggy> get loggy => Loggy<DioLoggy>('Dio (Http)');
}

enum DioLogRecordType {
  request,
  error,
  response,
}

class DioLogRecord {
  DioLogRecord({
    required this.type,
    this.options,
    this.error,
    this.response,
  });

  final RequestOptions? options;
  final DioError? error;
  final Response<dynamic>? response;
  final DioLogRecordType type;

  @override
  String toString() {
    String str = '';

    switch (type) {
      case DioLogRecordType.request:
        str += '> REQUEST ${options?.method} ${options?.path}';
        break;

      case DioLogRecordType.error:
        str +=
            '< ERROR  ${error?.requestOptions.method}  ${error?.requestOptions.uri} ${error?.message}';
        break;

      case DioLogRecordType.response:
        str +=
            '< RESPONSE  ${response?.requestOptions.method}  ${response?.requestOptions.uri}';
        break;
    }

    return str;
  }
}

class LogInterceptor extends Interceptor with DioLoggy {
  LogInterceptor();

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    super.onRequest(options, handler);

    loggy.log(
      LogLevel.info,
      DioLogRecord(
        options: options,
        type: DioLogRecordType.request,
      ),
    );
  }

  @override
  void onError(DioError err, ErrorInterceptorHandler handler) async {
    super.onError(err, handler);

    loggy.log(
      LogLevel.error,
      DioLogRecord(
        error: err,
        type: DioLogRecordType.error,
      ),
    );
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) async {
    super.onResponse(response, handler);

    loggy.log(
      LogLevel.info,
      DioLogRecord(
        response: response,
        type: DioLogRecordType.response,
      ),
    );
  }
}
