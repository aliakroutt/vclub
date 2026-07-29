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
}