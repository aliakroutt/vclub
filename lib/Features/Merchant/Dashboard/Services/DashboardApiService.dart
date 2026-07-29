import 'package:dio/dio.dart';
import 'package:vclub/API/ApiClient.dart';
import 'package:vclub/API/ApiRoutes.dart';
import 'package:vclub/Features/Merchant/Dashboard/Models/MerchantStatsModel.dart';

class MerchantDashboardApiClient {
  MerchantDashboardApiClient._();

  static Future<MerchantStatsModel> getStats() async {
    final Response response = await ApiClient.get(ApiRoutes.merchant_stats);

    final data = response.data;

    if (data is Map<String, dynamic>) {
      return MerchantStatsModel.fromJson(data);
    }

    throw Exception("Invalid stats response");
  }
}