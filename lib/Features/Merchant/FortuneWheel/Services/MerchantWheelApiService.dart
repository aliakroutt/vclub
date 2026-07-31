// Features/Merchant/FortuneWheel/Services/MerchantWheelApiService.dart
import 'package:dio/dio.dart';
import 'package:vclub/API/ApiClient.dart';
import 'package:vclub/API/ApiRoutes.dart';
import 'package:vclub/Features/Merchant/FortuneWheel/Models/FortuneSegmentModel.dart';


class MerchantWheelApiClient {
  MerchantWheelApiClient._();

  static Future<FortuneWheelConfigModel> getWheelConfig() async {
    final Response response = await ApiClient.get(ApiRoutes.merchant_wheel);

    final data = response.data;

    if (data is Map<String, dynamic>) {
      return FortuneWheelConfigModel.fromJson(data);
    }

    throw Exception("Invalid wheel config response");
  }
}