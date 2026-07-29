import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response;
import 'package:vclub/API/ApiClient.dart';
import 'package:vclub/API/ApiRoutes.dart';
import 'package:vclub/Features/Merchant/QRScanner/Models/ScanModels.dart';

/// Thrown when the API responds with a handled error (either a non-2xx
/// status, or a 200 that embeds success:false / an error message).
class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  @override
  String toString() => message;
}

class ScanApiClient {
  ScanApiClient._();

  static Future<ClientLookupResult> getClientByCode(String code) async {
    final response =
        await ApiClient.get("${ApiRoutes.clients_by_code}/$code");
    _throwIfError(response);
    return ClientLookupResult.fromJson(response.data);
  }

  static Future<ScanResultModel> addPoints(
      Map<String, dynamic> payload) async {
    final response = await ApiClient.post(ApiRoutes.scan_points, data: payload);
    _throwIfError(response);
    return ScanResultModel.fromJson(response.data);
  }
  
  static Future<RedeemResultModel> validateCode(String code) async {
  final response = await ApiClient.post(
    ApiRoutes.scan_redeem,
    data: {"code": code},
  );
  _throwIfError(response);
  return RedeemResultModel.fromJson(response.data);
}
 

  static void _throwIfError(Response response) {
    final status = response.statusCode ?? 200;
    final data = response.data;

    // Non-2xx that Dio didn't throw for (e.g. validateStatus override)
    if (status < 200 || status >= 300) {
      throw ApiException(_extractMessage(data) ?? "request_failed".tr);
    }

    // HTTP 200 but body signals failure
    if (data is Map<String, dynamic> && data["success"] == false) {
      throw ApiException(_extractMessage(data) ?? "request_failed".tr);
    }
  }

  static String? _extractMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data["message"]?.toString() ?? data["error"]?.toString();
    } else if (data is String && data.isNotEmpty) {
      return data;
    }
    return null;
  }
}