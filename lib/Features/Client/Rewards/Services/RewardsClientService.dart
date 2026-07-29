import 'package:get/get.dart';
import 'package:vclub/API/ApiClient.dart';
import 'package:vclub/API/ApiRoutes.dart';
import 'package:vclub/Core/Storage/Controllers/ClientController.dart';
import 'package:vclub/Features/Client/Rewards/Models/ClientReviewRewardModel.dart';


class GoogleReviewApiClient {
  GoogleReviewApiClient._();
  
  static Future<GoogleReviewModel?> getGoogleReview() async {
    final controller = Get.find<ClientController>();
    final response = await ApiClient.get(
      ApiRoutes.client_review_reward+ "6a2c33c9cb2fd780542ce0c2"
    );

    final data = response.data;

    if (data == null || data is! Map<String, dynamic>) {
      return null;
    }

    return GoogleReviewModel.fromJson(data);
  }
}