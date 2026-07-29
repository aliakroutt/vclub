import 'package:dio/dio.dart';
import 'package:vclub/API/ApiClient.dart';
import 'package:vclub/API/ApiRoutes.dart';
import 'package:vclub/Features/Merchant/Clients/Models/ClientPaginationModel.dart';
import 'package:vclub/Features/Merchant/Clients/View/Widgets/ClientsTabs.dart';


class MerchantClientsApiClient {
  MerchantClientsApiClient._();

  static String _filterParam(ClientTab tab) {
    switch (tab) {
      case ClientTab.vip:
        return 'vip';
      case ClientTab.inactive:
        return 'inactive';
      case ClientTab.birthdays:
        return 'birthday';
      case ClientTab.active:
      case ClientTab.all:
        return 'all'; // API has no "active" filter yet
    }
  }

  static Future<ClientsPaginatedResponse> getClients({
    required int page,
    required int limit,
    String? search,
    ClientTab filter = ClientTab.all,
  }) async {
    final Response response = await ApiClient.get(
      ApiRoutes.merchant_clients,
      queryParameters: {
        "page": page,
        "limit": limit,
        "filter": _filterParam(filter),
        if (search != null && search.trim().isNotEmpty) "search": search.trim(),
      },
    );

    final data = response.data;
    if (data is Map<String, dynamic>) {
      return ClientsPaginatedResponse.fromJson(data);
    }
    throw Exception("Invalid clients response");
  }
}