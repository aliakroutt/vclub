import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:vclub/API/ApiClient.dart';
import 'package:vclub/API/ApiRoutes.dart';
import 'package:vclub/Features/Client/QRScanner/Models/JoinResponseModel.dart';

/// Holds the two dynamic segments parsed from a merchant join QR code.
class QrJoinData {
  final String clubSlug;
  final String programSlug;

  const QrJoinData({required this.clubSlug, required this.programSlug});
}

class ProgramApiClient {
  ProgramApiClient._();

 
  static QrJoinData? extractJoinData(String qrValue) {
    try {
      final uri = Uri.parse(qrValue.trim());
      final segments = uri.pathSegments.where((s) => s.isNotEmpty).toList();
      if (segments.length < 2) return null;
      return QrJoinData(clubSlug: segments[0], programSlug: segments[1]);
    } catch (_) {
      return null;
    }
  }

  static Future<JoinProgramResponseModel> joinProgram({
    required String clubSlug,
    required String programSlug,
  }) async {
    final response = await ApiClient.post(
      ApiRoutes.joinProgram(clubSlug, programSlug),
      data: {},
    );

    return JoinProgramResponseModel.fromJson(
      Map<String, dynamic>.from(response.data),
    );
  }

  static String extractErrorMessage(Object error) {
    if (error is DioException) {
      final data = error.response?.data;
      if (data is Map) {
        final msg = data['message'] ?? data['error'] ?? data['msg'];
        if (msg is String && msg.trim().isNotEmpty) return msg;
        if (msg is List && msg.isNotEmpty) return msg.first.toString();
      } else if (data is String && data.trim().isNotEmpty) {
        return data;
      }
      if (error.message != null && error.message!.trim().isNotEmpty) {
        return error.message!;
      }
    }

   
    try {
      final dynamic dynError = error;
      final dynamic maybeMessage = dynError.message;
      if (maybeMessage is String && maybeMessage.trim().isNotEmpty) {
        return maybeMessage;
      }
    } catch (_) {
    
    }

    return 'something_went_wrong'.tr;
  }
}