import 'package:get/get.dart';
import 'package:vclub/Core/Snackbars.dart';
import 'package:vclub/Features/Client/Rewards/Models/ClientReviewRewardModel.dart';
import 'package:vclub/Features/Client/Rewards/Services/RewardsClientService.dart';

class GoogleReviewController extends GetxController {
  final Rxn<GoogleReviewModel> googleReview = Rxn<GoogleReviewModel>();

  final RxBool reviewLoading = false.obs;
  final RxString reviewError = "".obs;
  final RxBool initialLoaded = false.obs;

   final RxInt selectedIndex = 0.obs; // 0=programs, 1=fortune, 2=review

  void select(int index) => selectedIndex.value = index;

  // @override
  // void onInit() {
  //   super.onInit();
  //   fetchGoogleReview();
  // }

  Future<void> fetchGoogleReview() async {
    try {
      if (!initialLoaded.value) {
        reviewLoading.value = true;
      }

      reviewError.value = "";

      final result =
          await GoogleReviewApiClient.getGoogleReview();

      googleReview.value = result;

      initialLoaded.value = true;
    } catch (e) {
      reviewError.value = "failed_load_google_review".tr;
      AppSnackBar.error("failed_load_google_review".tr);
    } finally {
      reviewLoading.value = false;
    }
  }

  void resetGoogleReview() {
    googleReview.value = null;
    reviewError.value = "";
    reviewLoading.value = false;
    initialLoaded.value = false;
  }

  Future<void> refreshGoogleReview() async {
    await fetchGoogleReview();
  }
}