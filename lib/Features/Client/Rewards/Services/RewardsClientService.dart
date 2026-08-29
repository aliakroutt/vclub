import 'package:vclub/API/ApiClient.dart';
import 'package:vclub/API/ApiRoutes.dart';
import 'package:vclub/Features/Client/Rewards/Models/ClientReviewRewardModel.dart';

class GoogleReviewApiClient {
  GoogleReviewApiClient._();

  static Future<GoogleReviewModel?> getGoogleReview(String companyId) async {
    final response = await ApiClient.get(
      ApiRoutes.client_review_reward + companyId,
    );

    final data = response.data;
    if (data == null || data is! Map<String, dynamic>) return null;

    return GoogleReviewModel.fromJson(data);
  }

  static Future<ReviewStartModel> startReview(String companyId) async {
    final response = await ApiClient.post(ApiRoutes.reviewStart(companyId));

    final data = response.data;
    if (data is Map<String, dynamic>) {
      return ReviewStartModel.fromJson(data);
    }
    throw Exception("Invalid review-start response");
  }

  static Future<ReviewClaimModel> claimReview(
    String companyId,
    String reviewToken,
  ) async {
    final response = await ApiClient.post(
      ApiRoutes.reviewClaim(companyId),
      data: {"reviewToken": reviewToken},
    );

    final data = response.data;
    if (data is Map<String, dynamic>) {
      return ReviewClaimModel.fromJson(data);
    }
    throw Exception("Invalid review-claim response");
  }
}