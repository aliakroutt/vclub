import 'package:vclub/API/ApiClient.dart';
import 'package:vclub/API/ApiRoutes.dart';
import 'package:vclub/Features/Client/Notifications/Models/ClientNotificationsModel.dart';



class NotificationsApiClient {
  NotificationsApiClient._();


  static Future<NotificationsResponseModel> getNotifications({
    int page = 1,
    int limit = 20,
  }) async {

    final response = await ApiClient.get(
      ApiRoutes.client_notifications,
      queryParameters: {
        "page": page,
        "limit": limit,
      },
    );


    final data = response.data;


    return NotificationsResponseModel.fromJson(
      Map<String, dynamic>.from(data),
    );
  }

  static Future<void> markNotificationAsRead(
      String notifId,
  ) async {


    await ApiClient.patch(
      ApiRoutes.clientReadNotif(notifId),
      data: {},
    );

  }
  
  static Future<void> markNotificationAsReadAll(
  ) async {
    await ApiClient.patch(
      ApiRoutes.client_notifications_readall,
      data: {},
    );
  }

}


