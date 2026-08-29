import 'package:get/get.dart';
import 'package:vclub/Features/Client/ClubsClient/Models/LoyaltyCardModel.dart';
import 'package:vclub/Features/Client/ClubsClient/Models/MerchantModel.dart';
import 'package:vclub/Features/Client/ClubsClient/Services/ClubsApiService.dart';


class CardsController extends GetxController {
  static CardsController get to => Get.find();

  // ---- Merchant / programs (single club) ----
  final Rxn<Merchant> merchant = Rxn<Merchant>();
  final RxBool isLoadingPrograms = false.obs;
  final RxString programsError = ''.obs;

  // ---- Client cards (all memberships) ----
  final RxList<LoyaltyCard> cards = <LoyaltyCard>[].obs;
  final RxBool isLoadingCards = false.obs;
  final RxString cardsError = ''.obs;

 

  /// Loads a club's programs by slug (e.g. when opening a merchant page).
  Future<void> fetchPrograms(String clubSlug) async {
    try {
      isLoadingPrograms.value = true;
      programsError.value = '';

      final result = await CardsApiClient.getPrograms(clubSlug);
      merchant.value = result;
    } catch (e) {
      programsError.value = e.toString();
    } finally {
      isLoadingPrograms.value = false;
    }
  }

  /// Loads the current client's loyalty cards.
  Future<void> fetchClientCards() async {
    try {
      isLoadingCards.value = true;
      cardsError.value = '';

      final result = await CardsApiClient.getClientClubs();
      cards.assignAll(result);
    } catch (e) {
      cardsError.value = e.toString();
    } finally {
      isLoadingCards.value = false;
    }
  }

  Future<void> refreshCards() => fetchClientCards();

  // =========================
  // RESET
  // =========================
  /// Clears merchant/programs and client cards data back to initial
  /// values. Call this on logout so the next fetch starts clean and
  /// doesn't briefly flash a previous client's clubs/cards.
  void resetControllerData() {
    merchant.value = null;
    isLoadingPrograms.value = false;
    programsError.value = '';

    cards.clear();
    isLoadingCards.value = false;
    cardsError.value = '';
  }
}