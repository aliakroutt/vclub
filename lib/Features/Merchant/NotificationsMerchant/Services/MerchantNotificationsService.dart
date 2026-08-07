import 'package:dio/dio.dart';
import 'package:vclub/API/ApiClient.dart';
import 'package:vclub/API/ApiRoutes.dart';
import 'package:vclub/Features/Merchant/NotificationsMerchant/Models/MerchantNotificationsSendModel.dart';


class MerchantNotificationsApiClient {
  MerchantNotificationsApiClient._();

  static Future<MerchantNotificationsResponse> getNotifications({
    int page = 1,
    int limit = 20,
  }) async {
    final Response response = await ApiClient.get(
      ApiRoutes.merchant_notifications_send,
      queryParameters: {
        "page": page,
        "limit": limit,
      },
    );

    final data = response.data;

    if (data is Map<String, dynamic>) {
      return MerchantNotificationsResponse.fromJson(data);
    }

    throw Exception("Invalid notifications response");
  }
}