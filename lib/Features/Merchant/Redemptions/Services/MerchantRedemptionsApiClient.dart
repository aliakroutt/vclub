import 'package:dio/dio.dart';
import 'package:vclub/API/ApiClient.dart';
import 'package:vclub/API/ApiRoutes.dart';
import 'package:vclub/Features/Merchant/Redemptions/Models/MerchantRedemptionModel.dart';

class MerchantRedemptionsApiClient {
  MerchantRedemptionsApiClient._();

  static Future<MerchantRedemptionsResponse> getRedemptions({
    int page = 1,
    int limit = 20,
    String? status,
    DateTime? from,
    DateTime? to,
  }) async {
    final Response response = await ApiClient.get(
      ApiRoutes.merchant_redemptions,
      queryParameters: {
        "page": page,
        "limit": limit,
        if (status != null && status.isNotEmpty) "status": status,
        if (from != null) "from": from.toIso8601String(),
        if (to != null) "to": to.toIso8601String(),
      },
    );

    final data = response.data;
    if (data is Map<String, dynamic>) {
      return MerchantRedemptionsResponse.fromJson(data);
    }
    throw Exception("Invalid redemptions response");
  }
}