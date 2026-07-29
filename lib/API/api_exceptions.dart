import 'package:dio/dio.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final String? type;

  ApiException({
    required this.message,
    this.statusCode,
    this.type,
  });

  @override
  String toString() => message;

  /// Convert DioException → ApiException
  static ApiException fromDio(DioException error) {
    final response = error.response;

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return ApiException(
          message: "Connection timeout",
          type: "TIMEOUT",
        );

      case DioExceptionType.sendTimeout:
        return ApiException(
          message: "Send timeout",
          type: "TIMEOUT",
        );

      case DioExceptionType.receiveTimeout:
        return ApiException(
          message: "Receive timeout",
          type: "TIMEOUT",
        );

      case DioExceptionType.cancel:
        return ApiException(
          message: "Request cancelled",
          type: "CANCEL",
        );

      case DioExceptionType.connectionError:
        return ApiException(
          message: "No internet connection",
          type: "NETWORK",
        );

      case DioExceptionType.badResponse:
        final data = response?.data;

        String serverMessage = "Something went wrong";

        if (data is Map && data["message"] != null) {
          serverMessage = data["message"];
        }

        return ApiException(
          message: serverMessage,
          statusCode: response?.statusCode,
          type: "SERVER",
        );

      default:
        return ApiException(
          message: "Unexpected error occurred",
          type: "UNKNOWN",
        );
    }
  }
}