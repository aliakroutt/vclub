import 'package:dio/dio.dart';
import 'package:vclub/API/ApiClient.dart';
import 'package:vclub/API/ApiRoutes.dart';
import 'package:vclub/Features/Merchant/GoogleReview/Models/GoogleReviewModels.dart';

class GoogleReviewApiClient {
  GoogleReviewApiClient._();

  static Future<LoyaltyProgramModel> getProgram() async {
    final Response response = await ApiClient.get(ApiRoutes.merchant_loyalty_program);

    final data = response.data;
    if (data is Map<String, dynamic>) {
      return LoyaltyProgramModel.fromJson(data);
    }
    throw Exception("Invalid loyalty program response");
  }

  static Future<List<RewardModel>> getRewards() async {
    final Response response = await ApiClient.get(ApiRoutes.merchant_rewards_list);

    final data = response.data;
    if (data is List) {
      return data.whereType<Map<String, dynamic>>().map((e) => RewardModel.fromJson(e)).toList();
    }
    throw Exception("Invalid rewards response");
  }
  static Future<void> updateGoogleReviewLink(String link) async {
  await ApiClient.patch(
    ApiRoutes.merchant_my_company,
    data: {"googleReviewLink": link},
  );
}
static Future<void> updateProgramReviewSettings({
  required String reviewRewardId,
  required String reviewTrigger,
}) async {
  await ApiClient.put(
    ApiRoutes.merchant_loyalty_program,
    data: {
      "reviewRewardId": reviewRewardId,
      "reviewTrigger": reviewTrigger,
    },
  );
}
}