import 'package:vclub/API/ApiClient.dart';
import 'package:vclub/API/ApiRoutes.dart';
import 'package:vclub/Features/Client/Dashboard/Models/ClientCardTokenModel.dart';


class ClientCardQrApi {
  ClientCardQrApi._();

  static Future<ClientCardQrModel> getCardQr(String cardId) async {
    final response = await ApiClient.get(
      ApiRoutes.clientCardQr(cardId),
    );

    return ClientCardQrModel.fromJson(
      Map<String, dynamic>.from(response.data),
    );
  }
}