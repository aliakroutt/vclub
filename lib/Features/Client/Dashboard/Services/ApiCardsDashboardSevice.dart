import 'package:dio/dio.dart';
import 'package:vclub/API/ApiClient.dart';
import 'package:vclub/API/ApiRoutes.dart';
import 'package:vclub/Features/Client/Dashboard/Models/ClientCardsModel.dart';


class CardsApiClient {
  CardsApiClient._();

  static Future<List<ClientCardModel>> getClientCards() async {
    final Response response = await ApiClient.get(
      ApiRoutes.client_cards,
    );

    final data = response.data;

    if (data is List) {
      return data
          .map((e) => ClientCardModel.fromJson(e))
          .toList();
    }

    throw Exception("Invalid cards response");
  }
}