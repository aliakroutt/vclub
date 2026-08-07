import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:vclub/API/ApiClient.dart';
import 'package:vclub/API/ApiRoutes.dart';
import 'package:vclub/Features/Merchant/NotificationsMerchant/Models/SendNotificationDto.dart';

class MerchantNotificationsComposeApiClient {
  MerchantNotificationsComposeApiClient._();

  static Future<void> sendNotification(SendNotificationDto dto) async {
    await ApiClient.post(
      ApiRoutes.merchant_notifications_compose,
      data: dto.toJson(),
    );
  }

  static String extractErrorMessage(Object error) {
    if (error is DioException) {
      debugPrint("Send notification failed: "
          "${error.response?.statusCode} ${error.response?.data} "
          "(${error.message})");

      final data = error.response?.data;
      if (data is Map && data["message"] != null) {
        final msg = data["message"];
        if (msg is List && msg.isNotEmpty) return msg.first.toString();
        return msg.toString();
      }
      if (error.response?.statusCode != null) {
        return "Error ${error.response?.statusCode}";
      }
    } else {
      debugPrint("Send notification failed: $error");
    }
    return "";
  }
}