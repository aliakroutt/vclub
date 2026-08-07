import 'package:dio/dio.dart';
import 'package:vclub/API/ApiClient.dart';
import 'package:vclub/API/ApiRoutes.dart';
import 'package:vclub/Features/Merchant/Avtivity/Models/MerchantActivityModel.dart';


class MerchantActivityApiClient {
  MerchantActivityApiClient._();

  static Future<MerchantActivityResponse> getActivity({
    int page = 1,
    int limit = 20,
    String? action,
    String? clientId,
    String? actorId,
    DateTime? from,
    DateTime? to,
  }) async {
    final Response response = await ApiClient.get(
      ApiRoutes.merchant_activity,
      queryParameters: {
        "page": page,
        "limit": limit,
        if (action != null && action.isNotEmpty) "action": action,
        if (clientId != null && clientId.isNotEmpty) "clientId": clientId,
        if (actorId != null && actorId.isNotEmpty) "actorId": actorId,
        if (from != null) "from": from.toIso8601String(),
        if (to != null) "to": to.toIso8601String(),
      },
    );

    final data = response.data;
    if (data is Map<String, dynamic>) {
      return MerchantActivityResponse.fromJson(data);
    }
    throw Exception("Invalid activity response");
  }
}