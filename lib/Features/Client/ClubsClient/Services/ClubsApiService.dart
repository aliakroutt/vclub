import 'package:vclub/API/ApiClient.dart';
import 'package:vclub/API/ApiRoutes.dart';
import 'package:vclub/Features/Client/ClubsClient/Models/LoyaltyCardModel.dart';
import 'package:vclub/Features/Client/ClubsClient/Models/MerchantModel.dart';


class CardsApiClient {
  CardsApiClient._();

  /// Fetches a merchant (club) and its loyalty programs by club slug.
  static Future<Merchant> getPrograms(String clubSlug) async {
    final response = await ApiClient.get(
      ApiRoutes.GetPrograms(clubSlug),
    );

    final data = response.data;

    return Merchant.fromJson(Map<String, dynamic>.from(data));
  }

  /// Fetches the current client's loyalty cards (their memberships
  /// across all clubs).
  static Future<List<LoyaltyCard>> getClientClubs() async {
    final response = await ApiClient.get(
      ApiRoutes.client_clubs,
    );

    final data = response.data as List<dynamic>;

    return LoyaltyCard.listFromJson(data);
  }
}