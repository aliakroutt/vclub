import 'package:dio/dio.dart';
import 'package:vclub/API/ApiClient.dart';
import 'package:vclub/API/ApiRoutes.dart';
import 'package:vclub/Features/Merchant/FortuneWheel/Models/UpdateWheelConfigDto.dart';

class FortuneWheelApiClient {
  FortuneWheelApiClient._();

  static Future<void> updateWheelConfig(UpdateWheelConfigDto dto) async {
    final Response response = await ApiClient.put(
      ApiRoutes.merchant_wheel,
      data: dto.toJson(),
    );

    if (response.statusCode == null ||
        response.statusCode! < 200 ||
        response.statusCode! >= 300) {
      throw Exception("Invalid wheel config update response");
    }
  }

  static Future<Map<String, dynamic>> getWheelConfig() async {
    final Response response = await ApiClient.get(ApiRoutes.merchant_wheel);

    final data = response.data;

    if (data is Map<String, dynamic>) {
      return data;
    }

    throw Exception("Invalid wheel config response");
  }
}