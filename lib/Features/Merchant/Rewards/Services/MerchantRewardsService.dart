import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response;
import 'package:vclub/API/ApiClient.dart';
import 'package:vclub/API/ApiRoutes.dart';
import 'package:vclub/Features/Merchant/Dashboard/Models/RewardsMerchantModel.dart';

class MerchantRewardsApiClient {
  MerchantRewardsApiClient._();

  static Future<List<RewardModel>> getRewards() async {
    final Response response = await ApiClient.get(ApiRoutes.merchant_rewards);
    final data = response.data;

    if (data is List) {
      return data
          .map((e) => RewardModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    throw Exception("Invalid rewards response");
  }

  static Future<RewardModel> addReward({
    required String name,
    required String type,
  }) async {
    final Response response = await ApiClient.post(
      ApiRoutes.merchant_rewards,
      data: {"name": name, "type": type, "active": true},
    );

    final data = response.data;
    if (data is Map<String, dynamic>) {
      return RewardModel.fromJson(data);
    }

    throw Exception("Invalid add reward response");
  }

  static Future<void> deleteReward(String id) async {
    await ApiClient.delete("${ApiRoutes.merchant_rewards}/$id");
  }

 static Future<Map<String, dynamic>> validateRewardByCode(String code) async {
  final response = await ApiClient.post(
    ApiRoutes.scan_redeem,
    data: {"code": code},
  );

  final data = response.data;

  if (response.statusCode == 200 || response.statusCode == 201) {
    if (data is Map<String, dynamic>) return data;
    throw Exception("Invalid validate response");
  }

  // Non-2xx: surface the API's own error message, translated if it's an i18n key
  String? apiMessage;
  if (data is Map<String, dynamic>) {
    apiMessage = data["message"]?.toString() ?? data["error"]?.toString();
  } else if (data is String && data.isNotEmpty) {
    apiMessage = data;
  }

  throw ApiException(humanizeError(apiMessage));
}

static String humanizeError(String? raw) {
  if (raw == null || raw.isEmpty) return "reward_validate_failed".tr;

  final translated = raw.tr;
  // GetX returns the key unchanged if no translation exists — catch that case
  if (translated == raw) {
    return "reward_validate_failed".tr;
  }
  return translated;
}
}

class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  @override
  String toString() => message;
}
