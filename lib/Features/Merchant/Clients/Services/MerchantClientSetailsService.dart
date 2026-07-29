import 'package:dio/dio.dart';
import 'package:vclub/API/ApiClient.dart';
import 'package:vclub/API/ApiRoutes.dart';
import 'package:vclub/Features/Merchant/Clients/Models/ClientDetailsResponse.dart';

class MerchantClientDetailsApiClient {
  MerchantClientDetailsApiClient._();

  static Future<ClientDetailsResponse> getClientDetails(String membershipId) async {
    final Response response = await ApiClient.get(
      "${ApiRoutes.merchant_clients}/$membershipId",
    );

    final data = response.data;
    if (data is Map<String, dynamic>) {
      return ClientDetailsResponse.fromJson(data);
    }
    throw Exception("Invalid client details response");
  }
}