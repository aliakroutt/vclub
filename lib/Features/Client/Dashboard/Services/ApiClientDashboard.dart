import 'package:dio/dio.dart';
import 'package:vclub/API/ApiClient.dart';
import 'package:vclub/API/ApiRoutes.dart';
import 'package:vclub/Features/Client/Dashboard/Models/client_stats_model.dart';

class DashboardApiClient {
  DashboardApiClient._();

  static Future<ClientStatsModel> getStats() async {
    final Response response = await ApiClient.get(ApiRoutes.client_stats);

    final data = response.data;

    if (data is Map<String, dynamic>) {
      return ClientStatsModel.fromJson(data);
    }

    throw Exception("Invalid stats response");
  }
}
