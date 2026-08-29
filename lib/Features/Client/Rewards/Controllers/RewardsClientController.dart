import 'package:get/get.dart';
import 'package:vclub/Features/Client/FortuneWheel/Models/FortuneWheelModels.dart';
import 'package:vclub/Features/Client/FortuneWheel/Services/FortuneWheelApiClient.dart';
import 'package:vclub/Features/Client/Rewards/Models/ClientReviewRewardModel.dart';
import 'package:vclub/Features/Client/Rewards/Services/RewardsClientService.dart';


class CompanyReviewEntry {
  final ClientCompanyModel company;
  final GoogleReviewModel? review;

  CompanyReviewEntry({required this.company, this.review});
}

class GoogleReviewController extends GetxController {
  static GoogleReviewController get to => Get.find();

  final RxList<CompanyReviewEntry> entries = <CompanyReviewEntry>[].obs;

  final RxBool loading = false.obs;
  final RxBool hasError = false.obs;
  final RxBool initialLoaded = false.obs;

  final RxInt selectedIndex = 0.obs; // 0=programs, 1=fortune, 2=review

  void select(int index) => selectedIndex.value = index;

  @override
  void onInit() {
    super.onInit();
    fetchAll();
  }

  /// Loads every joined company, then fetches each company's Google
  /// Review reward info in parallel and combines them into one list.
  Future<void> fetchAll() async {
    try {
      loading.value = true;
      hasError.value = false;

      final companyList = await FortuneWheelApiClient.getMemberships();

      final seen = <String>{};
      final uniqueCompanies = companyList
          .where((c) => c.companyId.isNotEmpty)
          .where((c) => seen.add(c.companyId))
          .toList();

      final reviews = await Future.wait(
        uniqueCompanies.map((company) async {
          try {
            final review = await GoogleReviewApiClient.getGoogleReview(company.companyId);
            return CompanyReviewEntry(company: company, review: review);
          } catch (_) {
            return CompanyReviewEntry(company: company, review: null);
          }
        }),
      );

      entries.assignAll(reviews);
      hasError.value = false;
    } catch (e) {
      hasError.value = true;
      entries.clear();
    } finally {
      loading.value = false;
      initialLoaded.value = true;
    }
  }

  Future<void> refresh() => fetchAll();

  // =========================
  // RESET
  // =========================
  /// Clears company/review entries and tab selection back to initial
  /// values. Call this on logout so the next fetch starts clean and
  /// doesn't briefly flash a previous client's review data.
  void resetControllerData() {
    entries.clear();
    loading.value = false;
    hasError.value = false;
    initialLoaded.value = false;
    selectedIndex.value = 0;
  }
}