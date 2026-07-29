import 'dart:developer';
import 'package:dio/dio.dart';

class LoggerInterceptor extends Interceptor {
  static const _border = "────────────────────────────────────";

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    log(_border);
    log("🚀 REQUEST → ${options.method} ${options.baseUrl}${options.path}");

    log("Headers:");
    options.headers.forEach((k, v) => log("  $k: $v"));

    if (options.data != null) {
      log("Body:");
      log(options.data.toString());
    }

    log(_border);

    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    log("✅ RESPONSE → ${response.statusCode} ${response.requestOptions.path}");

    log("Data:");
    log(response.data.toString());

    log(_border);

    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    log("❌ ERROR → ${err.requestOptions.path}");

    log("Message: ${err.message}");

    if (err.response != null) {
      log("Status: ${err.response?.statusCode}");
      log("Data: ${err.response?.data}");
    }

    log(_border);

    handler.next(err);
  }
}