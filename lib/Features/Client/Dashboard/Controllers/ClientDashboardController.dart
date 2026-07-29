import 'package:get/get.dart';
import 'package:vclub/Core/Snackbars.dart';
import 'package:vclub/Features/Client/Dashboard/Models/ClientCardTokenModel.dart';
import 'package:vclub/Features/Client/Dashboard/Models/ClientCardsModel.dart';
import 'package:vclub/Features/Client/Dashboard/Models/Client_History_Model.dart';
import 'package:vclub/Features/Client/Dashboard/Models/Client_wheel_history.dart';
import 'package:vclub/Features/Client/Dashboard/Models/client_stats_model.dart';
import 'package:vclub/Features/Client/Dashboard/Services/ApiCardsDashboardSevice.dart';
import 'package:vclub/Features/Client/Dashboard/Services/ApiClientDashboard.dart';
import 'package:vclub/Features/Client/Dashboard/Services/Client_history_api.dart';
import 'package:vclub/Features/Client/Dashboard/Services/client_card_qr_api.dart';
import 'package:vclub/Features/Client/Dashboard/Services/rewards_api_client.dart';
import 'package:vclub/Features/Client/Dashboard/Services/wheel_history_api_client.dart';

class ClientDashboardController extends GetxController {
  static ClientDashboardController get to => Get.find();
  final RxInt rewardsSelectedTab = 0.obs;
  // =========================
  // FIRST-LOAD FLAG
  // =========================
  RxBool initialLoaded = false.obs;

  // =========================
  // LOADING STATES
  // =========================
  final RxBool statsLoading = false.obs;
  final RxBool cardsLoading = false.obs;
  final RxBool rewardsLoading = false.obs;
  final RxBool historyLoading = false.obs;
  final RxBool wheelhistoryLoading = false.obs;

  // =========================
  // ERROR STATES
  // =========================
  final RxString statsError = "".obs;
  final RxString cardsError = "".obs;
  final RxString rewardsError = "".obs;
  final RxString historyError = "".obs;
  final RxString wheelhistoryError = "".obs;

  // =========================
  // DATA STATES
  // =========================
  final Rxn<ClientStatsModel> stats = Rxn<ClientStatsModel>();
  // 👇 Now strongly typed instead of a raw RxList<dynamic>
  final RxList<ClientCardModel> cards = <ClientCardModel>[].obs;
  final RxList rewards = [].obs;
  final RxList<HistoryModel> history = <HistoryModel>[].obs;
  final RxList<WheelHistoryModel> wheel_history = <WheelHistoryModel>[].obs;

  // =========================
  // MAIN ENTRY POINT
  // =========================
  Future<void> fetchDashboardData() async {
    await Future.wait([
      fetchStats(),
      fetchCards(),
      fetchRewards(),
      fetchHistory(),
      fetchWheelHistory(),
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

      final result = await DashboardApiClient.getStats();

      // 👇 Adjust this line to match what getStats() actually returns:
      // - If it already returns a ClientStatsModel, just do: stats.value = result;
      // - If it returns a raw Map<String, dynamic> (typical API json), keep the line below.
      stats.value = result is ClientStatsModel
          ? result
          : ClientStatsModel.fromJson(result as Map<String, dynamic>);
    } catch (e) {
      statsError.value = "failed_load_stats".tr;
      AppSnackBar.error("failed_load_stats".tr);
    } finally {
      if (!initialLoaded.value) statsLoading.value = false;
    }
  }

  // fetch qr code token 
  Future<ClientCardQrModel?> fetchCardQr(String cardId) async {
  try {
    return await ClientCardQrApi.getCardQr(cardId);
  } catch (e) {
    AppSnackBar.error("failed_load_qr".tr);
    return null;
  }
}

  Future<void> fetchCards() async {
    try {
      if (!initialLoaded.value) cardsLoading.value = true;
      cardsError.value = "";

      // Same pattern as fetchHistory(): CardsApiClient.getClientCards() is
      // expected to already return List<ClientCardModel> (it parses the
      // JSON internally), matching how HistoryApiClient.gethistory() works.
      final List<ClientCardModel> result =
          await CardsApiClient.getClientCards();

      cards.assignAll(result);
    } catch (e) {
      cardsError.value = "failed_load_cards".tr;
      AppSnackBar.error("failed_load_cards".tr);
    } finally {
      if (!initialLoaded.value) cardsLoading.value = false;
    }
  }

  Future<void> fetchRewards() async {
    try {
      if (!initialLoaded.value) rewardsLoading.value = true;

      final result = await RewardsApiClient.getRewards();

      rewards.assignAll(result);
    } catch (e) {
      rewardsError.value = "failed_load_rewards";
      AppSnackBar.error("failed_load_rewards".tr);
    } finally {
      if (!initialLoaded.value) rewardsLoading.value = false;
    }
  }

  Future<void> fetchHistory() async {
    try {
      if (!initialLoaded.value) historyLoading.value = true;
      historyError.value = "";

      final List<HistoryModel> result = await HistoryApiClient.gethistory();

      history.assignAll(result);
    } catch (e) {
      historyError.value = "failed_load_history".tr;
      AppSnackBar.error("failed_load_history".tr);
    } finally {
      if (!initialLoaded.value) historyLoading.value = false;
    }
  }

  Future<void> fetchWheelHistory() async {
    try {
      if (!initialLoaded.value) wheelhistoryLoading.value = true;

      final result = await WheelHistoryApiClient.getHistory();

      wheel_history.assignAll(result);
    } catch (e) {
      wheelhistoryError.value = "failed_load_history";
      AppSnackBar.error("failed_load_history".tr);
    } finally {
      if (!initialLoaded.value) wheelhistoryLoading.value = false;
    }
  }

// =========================
  // RESET
  // =========================
  /// Clears all data, error, and loading states back to their initial values,
  /// and resets the first-load flag so the next fetch shows loading indicators again.
  /// Call this on logout, account switch, or whenever the dashboard needs a clean slate.
  void resetControllerData() {
    // Reset first-load flag
    initialLoaded.value = false;

    // Reset loading states
    statsLoading.value = false;
    cardsLoading.value = false;
    rewardsLoading.value = false;
    historyLoading.value = false;
    wheelhistoryLoading.value = false;

    // Reset error states
    statsError.value = "";
    cardsError.value = "";
    rewardsError.value = "";
    historyError.value = "";
    wheelhistoryError.value = "";

    // Reset data states
    stats.value = null;
    cards.clear();
    rewards.clear();
    history.clear();
    wheel_history.clear();

    // Reset misc UI state
    rewardsSelectedTab.value = 0;
  }

}