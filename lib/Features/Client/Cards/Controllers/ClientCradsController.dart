import 'package:get/get.dart';
import 'package:vclub/Core/Snackbars.dart';
import 'package:vclub/Features/Client/Dashboard/Models/ClientCardsModel.dart';
import 'package:vclub/Features/Client/Dashboard/Services/ApiCardsDashboardSevice.dart';

class ClientCardsController extends GetxController {
  static ClientCardsController get to {
    if (!Get.isRegistered<ClientCardsController>()) {
      Get.put(ClientCardsController());
    }
    return Get.find();
  }

  // =========================
  // FIRST-LOAD FLAG
  // =========================
  RxBool initialLoaded = false.obs;

  // =========================
  // LOADING STATE
  // =========================
  final RxBool cardsLoading = false.obs;

  // =========================
  // ERROR STATE
  // =========================
  final RxString cardsError = "".obs;

  // =========================
  // DATA STATES
  // =========================
  final RxList<ClientCardModel> cards = <ClientCardModel>[].obs;
  final RxList<ClientCardModel> filteredCards = <ClientCardModel>[].obs;

  // =========================
  // FILTER STATE
  // =========================
  final RxString searchQuery = "".obs;
  final RxString modeFilter = "all".obs; // "all", "points", "stamps", "cashback"
  final RxString completionFilter = "all".obs; // "all", "completed", "in_progress"

  int countForMode(String mode) {
    if (mode == "all") return cards.length;
    return cards.where((c) => c.program.mode == mode).length;
  }

  bool get hasActiveFilters =>
      modeFilter.value != "all" ||
      completionFilter.value != "all" ||
      searchQuery.value.trim().isNotEmpty;

  @override
  void onReady() {
    super.onReady();
    fetchCards();
  }

  // =========================
  // MAIN ENTRY POINT
  // =========================
  Future<void> fetchCardsData() async {
    await fetchCards();
    initialLoaded.value = true;
  }

  // =========================
  // API CALLS
  // =========================
  Future<void> fetchCards() async {
    try {
      if (!initialLoaded.value) cardsLoading.value = true;
      cardsError.value = "";

      final List<ClientCardModel> result =
          await CardsApiClient.getClientCards();

      cards.assignAll(result);
      applyFilters();
    } catch (e) {
      cardsError.value = "failed_load_cards".tr;
      AppSnackBar.error("failed_load_cards".tr);
    } finally {
      if (!initialLoaded.value) cardsLoading.value = false;
    }
  }

  // =========================
  // FILTERING
  // =========================
  void setSearchQuery(String query) {
    searchQuery.value = query;
    applyFilters();
  }

  void setModeFilter(String mode) {
    modeFilter.value = mode;
    applyFilters();
  }

  void setCompletionFilter(String completion) {
    completionFilter.value = completion;
    applyFilters();
  }

  void applyFilters() {
    List<ClientCardModel> result = cards;

    // Filter by program mode (points / stamps / cashback)
    if (modeFilter.value != "all") {
      result = result
          .where((card) => card.program.mode == modeFilter.value)
          .toList();
    }

    // Filter by completion status
    if (completionFilter.value == "completed") {
      result = result.where((card) => card.cardCompleted).toList();
    } else if (completionFilter.value == "in_progress") {
      result = result.where((card) => !card.cardCompleted).toList();
    }

    // Search by company or program name
    if (searchQuery.value.trim().isNotEmpty) {
      final query = searchQuery.value.trim().toLowerCase();
      result = result
          .where((card) =>
              card.company.name.toLowerCase().contains(query) ||
              card.program.name.toLowerCase().contains(query))
          .toList();
    }

    filteredCards.assignAll(result);
  }

  void clearFilters() {
    searchQuery.value = "";
    modeFilter.value = "all";
    completionFilter.value = "all";
    filteredCards.assignAll(cards);
  }

  // =========================
  // RESET
  // =========================
  void resetControllerData() {
    initialLoaded.value = false;
    cardsLoading.value = false;
    cardsError.value = "";
    cards.clear();
    filteredCards.clear();
    searchQuery.value = "";
    modeFilter.value = "all";
    completionFilter.value = "all";
  }
}