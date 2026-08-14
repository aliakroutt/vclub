import 'package:vclub/API/ApiClient.dart';
import 'package:vclub/API/ApiRoutes.dart';
import 'package:vclub/Features/Merchant/NotificationsMerchant/Models/MerchantNotificationsModel.dart';

class MerchantNotificationsApiClient {
  MerchantNotificationsApiClient._();

  static Future<MerchantNotificationsResponseModel> getNotifications({
    int page = 1,
    int limit = 20,
  }) async {
    final response = await ApiClient.get(
      ApiRoutes.merchant_notifications,
      queryParameters: {
        "page": page,
        "limit": limit,
      },
    );

    final data = response.data;

    return MerchantNotificationsResponseModel.fromJson(
      Map<String, dynamic>.from(data),
    );
  }

  static Future<void> markNotificationAsRead(String notifId) async {
    await ApiClient.patch(
      ApiRoutes.merchantReadNotif(notifId),
      data: {},
    );
  }

  static Future<void> markNotificationAsReadAll() async {
    await ApiClient.patch(
      ApiRoutes.merchant_notifications_readall,
      data: {},
    );
  }
}