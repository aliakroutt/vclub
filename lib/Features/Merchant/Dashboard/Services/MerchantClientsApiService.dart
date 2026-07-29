import 'package:dio/dio.dart';
import 'package:vclub/API/ApiClient.dart';
import 'package:vclub/API/ApiRoutes.dart';
import 'package:vclub/Features/Merchant/Dashboard/Models/MerchantClientModel.dart';

class MerchantClientsApiClient {
  MerchantClientsApiClient._();

  static Future<MerchantClientsPageModel> getClients({
    int page = 1,
    int limit = 5,
  }) async {
    final Response response = await ApiClient.get(
      ApiRoutes.merchant_clients,
      queryParameters: {
        "page": page,
        "limit": limit,
      },
    );

    final data = response.data;

    if (data is Map<String, dynamic>) {
      return MerchantClientsPageModel.fromJson(data);
    }

    throw Exception("Invalid clients response");
  }
}