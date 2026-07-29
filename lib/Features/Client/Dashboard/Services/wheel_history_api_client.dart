import 'package:vclub/API/ApiClient.dart';
import 'package:vclub/API/ApiRoutes.dart';
import 'package:vclub/Features/Client/Dashboard/Models/Client_wheel_history.dart';


class WheelHistoryApiClient {
  WheelHistoryApiClient._();

  static Future<List<WheelHistoryModel>> getHistory() async {
    final response = await ApiClient.get(ApiRoutes.client_wheel_history);

    final data = response.data;

    if (data is! List) return [];

    return data
        .map((e) => WheelHistoryModel.fromJson(
              Map<String, dynamic>.from(e),
            ))
        .toList();
  }
}