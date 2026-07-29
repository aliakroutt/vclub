import 'package:get/get.dart';
// import 'package:vclub/Core/Snackbars.dart';
import 'package:vclub/Features/Merchant/Dashboard/Models/MerchantClientModel.dart';
import 'package:vclub/Features/Merchant/Dashboard/Models/MerchantStatsModel.dart';
import 'package:vclub/Features/Merchant/Dashboard/Models/RewardsMerchantModel.dart';
import 'package:vclub/Features/Merchant/Dashboard/Services/DashboardApiService.dart';
import 'package:vclub/Features/Merchant/Dashboard/Services/MerchantClientsApiService.dart';
import 'package:vclub/Features/Merchant/Dashboard/Services/MerchantRewardsApiService.dart';

class MerchantDashboardController extends GetxController {
  static MerchantDashboardController get to => Get.find();

  // =========================
  // FIRST-LOAD FLAG
  // =========================
  RxBool initialLoaded = false.obs;

  // =========================
  // LOADING STATES
  // =========================
  final RxBool statsLoading = false.obs;
  final RxBool clientsLoading = false.obs;
  final RxBool rewardsLoading = false.obs;

  // =========================
  // ERROR STATES
  // =========================
  final RxString statsError = "".obs;
  final RxString clientsError = "".obs;
  final RxString rewardsError = "".obs;

  // =========================
  // DATA STATES
  // =========================
  final Rxn<MerchantStatsModel> stats = Rxn<MerchantStatsModel>();

  final RxList<MerchantClientModel> clients = <MerchantClientModel>[].obs;
  final RxInt clientsPage = 1.obs;
  final RxInt clientsTotal = 0.obs;
  final RxInt clientsTotalPages = 1.obs;

  final RxList<RewardModel> rewards = <RewardModel>[].obs;

  // =========================
  // MAIN ENTRY POINT
  // =========================
  Future<void> fetchDashboardData() async {
    await Future.wait([
      fetchStats(),
      fetchClients(),
      fetchRewards(),
    ]);

    initialLoaded.value = true;
  }

  // =========================
  // API CALLS
  // =========================
  Future<void> fetchStats() async {
    try {
      if (!initialLoaded.value) statsLoading.value = true;
      statsError.value = "";

      final result = await MerchantDashboardApiClient.getStats();

      stats.value = result;
    } catch (e) {
      statsError.value = "failed_load_stats".tr;
      // AppSnackBar.error("failed_load_stats".tr);
    } finally {
      if (!initialLoaded.value) statsLoading.value = false;
    }
  }

  Future<void> fetchClients({int page = 1, int limit = 5}) async {
    try {
      if (!initialLoaded.value) clientsLoading.value = true;
      clientsError.value = "";

      final result = await MerchantClientsApiClient.getClients(
        page: page,
        limit: limit,
      );

      if (page == 1) {
        clients.assignAll(result.data);
      } else {
        clients.addAll(result.data);
      }

      clientsPage.value = result.page;
      clientsTotal.value = result.total;
      clientsTotalPages.value = result.totalPages;
    } catch (e) {
      clientsError.value = "failed_load_clients".tr;
      // AppSnackBar.error("failed_load_clients".tr);
    } finally {
      if (!initialLoaded.value) clientsLoading.value = false;
    }
  }

  Future<void> fetchRewards() async {
    try {
      if (!initialLoaded.value) rewardsLoading.value = true;
      rewardsError.value = "";

      final result = await MerchantRewardsApiClient.getRewards();

      rewards.assignAll(result);
    } catch (e) {
      rewardsError.value = "failed_load_rewards".tr;
      // AppSnackBar.error("failed_load_rewards".tr);
    } finally {
      if (!initialLoaded.value) rewardsLoading.value = false;
    }
  }

  // =========================
  // RESET
  // =========================
  /// Clears all data, error, and loading states back to their initial values,
  /// and resets the first-load flag so the next fetch shows loading indicators again.
  /// Call this on logout, account switch, or whenever the dashboard needs a clean slate.
  void resetControllerData() {
    initialLoaded.value = false;

    statsLoading.value = false;
    clientsLoading.value = false;
    rewardsLoading.value = false;

    statsError.value = "";
    clientsError.value = "";
    rewardsError.value = "";

    stats.value = null;
    clients.clear();
    clientsPage.value = 1;
    clientsTotal.value = 0;
    clientsTotalPages.value = 1;
    rewards.clear();
  }
}