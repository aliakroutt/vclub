import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart' hide Response;
import 'package:vclub/API/ApiClient.dart';
import 'package:vclub/API/ApiRoutes.dart';
import 'package:vclub/Features/Merchant/Settings/Models/ChangePasswordModel.dart';
import 'package:vclub/Features/Merchant/Settings/Models/SessionModel.dart';

class SettingsApiClient {
  SettingsApiClient._();

  static Future<void> updateCompany(Map<String, dynamic> payload) async {
    try {
      await ApiClient.patch(
        ApiRoutes.merchant_my_company,
        data: payload,
      );
    } on DioException catch (e) {
      debugPrint("❌ UPDATE COMPANY FAILED");
      debugPrint("Status: ${e.response?.statusCode}");
      debugPrint("Response data: ${e.response?.data}");
      rethrow;
    }
  }

  static Future<ChangePasswordResult> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await ApiClient.post(
        ApiRoutes.change_password,
        data: {
          "currentPassword": currentPassword,
          "newPassword": newPassword,
        },
      );

      return ChangePasswordResult.success();
    } on DioException catch (e) {
      debugPrint("❌ CHANGE PASSWORD FAILED");
      debugPrint("Status: ${e.response?.statusCode}");
      debugPrint("Response data: ${e.response?.data}");

      final data = e.response?.data;

      if (data is Map<String, dynamic>) {
        final rawMessage = data["message"];
        final code = data["code"]?.toString();

        String parsedMessage;
        if (rawMessage is List) {
          parsedMessage = rawMessage.map((e) => e.toString()).join("\n");
        } else if (rawMessage != null) {
          parsedMessage = rawMessage.toString();
        } else {
          parsedMessage = "change_password_failed_generic".tr;
        }

        return ChangePasswordResult.failure(parsedMessage, errorCode: code);
      }

      return ChangePasswordResult.failure("change_password_failed_generic".tr);
    } catch (e) {
      debugPrint("❌ CHANGE PASSWORD UNEXPECTED ERROR: $e");
      return ChangePasswordResult.failure("change_password_failed_generic".tr);
    }
  }
  static Future<List<SessionModel>> getSessions() async {
  final Response response = await ApiClient.get(ApiRoutes.merchant_sessions);

  final data = response.data;
  if (data is List) {
    return data.whereType<Map<String, dynamic>>().map((e) => SessionModel.fromJson(e)).toList();
  }
  throw Exception("Invalid sessions response");
}

static Future<void> revokeSession(String jti) async {
  await ApiClient.delete("${ApiRoutes.merchant_sessions}/$jti");
}
}