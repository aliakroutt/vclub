import 'package:dio/dio.dart';
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
      data: {
        "name": name,
        "type": type,
        "active": true,
      },
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
  final Response response = await ApiClient.get(
    "${ApiRoutes.merchant_reddem_by_code}$code",
  );

  final data = response.data;

  if (response.statusCode == 200 || response.statusCode == 201) {
    if (data is Map<String, dynamic>) return data;
    throw Exception("Invalid validate response");
  }

  // Non-2xx: surface the API's own error message
  String? apiMessage;
  if (data is Map<String, dynamic>) {
    apiMessage = data["message"]?.toString() ?? data["error"]?.toString();
  } else if (data is String && data.isNotEmpty) {
    apiMessage = data;
  }

  throw ApiException(apiMessage ?? "Request failed");
}
}

class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  @override
  String toString() => message;
}