import 'package:dio/dio.dart';
import 'package:vclub/API/ApiClient.dart';
import 'package:vclub/API/ApiRoutes.dart';

class MerchantLoyaltyApiClient {
  MerchantLoyaltyApiClient._();

  static Future<Response> createProgram(Map<String, dynamic> payload) {
    return ApiClient.post(ApiRoutes.merchant_loyalty_programs, data: payload);
  }
}