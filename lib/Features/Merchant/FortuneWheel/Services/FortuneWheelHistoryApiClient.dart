import 'package:dio/dio.dart';
import 'package:vclub/API/ApiClient.dart';
import 'package:vclub/API/ApiRoutes.dart';
import 'package:vclub/Features/Merchant/FortuneWheel/Models/HistoryWheelModel.dart';


class FortuneWheelHistoryApiClient {
  FortuneWheelHistoryApiClient._();

  static Future<WheelHistoryPageModel> getHistory({
    int page = 1,
    int limit = 20,
    DateTime? from,
    DateTime? to,
  }) async {
    final Response response = await ApiClient.get(
      ApiRoutes.merchant_wheel_history,
      queryParameters: {
        "page": page,
        "limit": limit,
        if (from != null) "from": _startOfDayIso(from),
        if (to != null) "to": _endOfDayIso(to),
      },
    );

    final data = response.data;
    if (data is Map<String, dynamic>) {
      return WheelHistoryPageModel.fromJson(data);
    }

    throw Exception("Invalid wheel history response");
  }

  // API expects full ISO datetimes (UTC, e.g. 2026-08-06T00:00:00.000Z)
  static String _startOfDayIso(DateTime d) =>
      DateTime.utc(d.year, d.month, d.day, 0, 0, 0).toIso8601String();

  static String _endOfDayIso(DateTime d) =>
      DateTime.utc(d.year, d.month, d.day, 23, 59, 59, 999).toIso8601String();
}