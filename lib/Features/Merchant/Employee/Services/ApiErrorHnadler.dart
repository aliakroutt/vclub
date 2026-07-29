import 'package:dio/dio.dart';
import 'package:get/get.dart';

class ApiErrorHandler {
  ApiErrorHandler._();

  static String extract(Object error, {String fallbackKey = "something_went_wrong"}) {
    if (error is DioException) {
      final data = error.response?.data;

      if (data is Map<String, dynamic>) {
        // Adjust these keys to match your backend's actual error shape
        final msg = data['message'] ?? data['error'] ?? data['errors'];

        if (msg is String && msg.trim().isNotEmpty) {
          return msg;
        }

        // Some APIs return errors as a list of strings
        if (msg is List && msg.isNotEmpty) {
          return msg.first.toString();
        }
      }

      // Fallback based on connection-level issues
      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout ||
          error.type == DioExceptionType.sendTimeout) {
        return "connection_timeout".tr;
      }
      if (error.type == DioExceptionType.connectionError) {
        return "no_internet_connection".tr;
      }
    }

    return fallbackKey.tr;
  }
}