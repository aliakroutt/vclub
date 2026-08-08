import 'package:dio/dio.dart';
import 'package:vclub/API/ApiClient.dart';
import 'package:vclub/API/ApiRoutes.dart';
import 'package:vclub/Features/Merchant/Audit/Models/MerchantAuditModel.dart';

class MerchantAuditApiClient {
  MerchantAuditApiClient._();

  static Future<MerchantAuditResponse> getAuditLogs({
    int page = 1,
    int limit = 20,
    String? action,
    DateTime? from,
    DateTime? to,
  }) async {
    final Response response = await ApiClient.get(
      ApiRoutes.merchant_audit,
      queryParameters: {
        "page": page,
        "limit": limit,
        if (action != null && action.isNotEmpty) "action": action,
        if (from != null) "from": from.toIso8601String(),
        if (to != null) "to": to.toIso8601String(),
      },
    );

    final data = response.data;
    if (data is Map<String, dynamic>) {
      return MerchantAuditResponse.fromJson(data);
    }
    throw Exception("Invalid audit response");
  }
}