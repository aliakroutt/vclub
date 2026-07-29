import 'package:get/get.dart';
import 'package:vclub/Features/Client/ClubsClient/Models/LoyaltyCardModel.dart';
import 'package:vclub/Features/Client/ClubsClient/Models/MerchantModel.dart';
import 'package:vclub/Features/Client/ClubsClient/Services/ClubsApiService.dart';


class CardsController extends GetxController {
  // ---- Merchant / programs (single club) ----
  final Rxn<Merchant> merchant = Rxn<Merchant>();
  final RxBool isLoadingPrograms = false.obs;
  final RxString programsError = ''.obs;

  // ---- Client cards (all memberships) ----
  final RxList<LoyaltyCard> cards = <LoyaltyCard>[].obs;
  final RxBool isLoadingCards = false.obs;
  final RxString cardsError = ''.obs;

  @override
  void onInit() {
    super.onInit();
    // fetchClientCards();
  }

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
}