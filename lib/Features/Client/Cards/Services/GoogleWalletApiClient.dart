import 'package:dio/dio.dart';
import 'package:vclub/API/ApiClient.dart';
import 'package:vclub/API/ApiRoutes.dart';
import 'package:vclub/Features/Client/Cards/Models/GoogleWalletModel.dart';


class GoogleWalletApiClient {
  GoogleWalletApiClient._();

  static Future<GoogleWalletResult> getGoogleWalletSaveUrl(String cardId) async {
    final Response response = await ApiClient.get(ApiRoutes.google_wallet + cardId);

    final data = response.data;
    if (data is Map<String, dynamic>) {
      return GoogleWalletResult.fromJson(data);
    }
    throw Exception("Invalid Google Wallet response");
  }
}