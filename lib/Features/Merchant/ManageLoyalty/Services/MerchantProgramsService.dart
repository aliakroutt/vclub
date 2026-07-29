import 'package:dio/dio.dart';
import 'package:vclub/API/ApiClient.dart';
import 'package:vclub/API/ApiRoutes.dart';
import 'package:vclub/Features/Merchant/ManageLoyalty/Models/ClientPageModel.dart';
import 'package:vclub/Features/Merchant/ManageLoyalty/Models/ProgramClientsStatsModel.dart';
import 'package:vclub/Features/Merchant/ManageLoyalty/Models/ProgramsModel.dart';


class MerchantProgramsApiClient {
  MerchantProgramsApiClient._();

  static Future<ProgramsPageModel> getPrograms({
    String search = '',
    int page = 1,
    int limit = 10,
  }) async {
    final Response response = await ApiClient.get(
      ApiRoutes.merchant_programs,
      queryParameters: {
        "search": search,
        "page": page,
        "limit": limit,
      },
    );

    final data = response.data;

    if (data is Map<String, dynamic>) {
      return ProgramsPageModel.fromJson(data);
    }

    throw Exception("Invalid programs response");
  }

  static Future<ProgramClientsStatsModel> getProgramClientsStats(
    String programId,
  ) async {
    final Response response = await ApiClient.get(
      "${ApiRoutes.program_clients_stats}$programId/stats",
    );

    final data = response.data;

    if (data is Map<String, dynamic>) {
      return ProgramClientsStatsModel.fromJson(data);
    }

    throw Exception("Invalid program clients stats response");
  }

  static Future<ClientsPageModel> getProgramClients({
  required String programId,
  String search = '',
  int page = 1,
  int limit = 15,
}) async {
  final Response response = await ApiClient.get(
    ApiRoutes.program_clients,
    queryParameters: {
      // NOTE: guessing the query param name is "program" — swap to
      // "programId" or whatever your backend expects if this 400s.
      "programId": programId,
      "search": search,
      "page": page,
      "limit": limit,
    },
  );

  final data = response.data;

  if (data is Map<String, dynamic>) {
    return ClientsPageModel.fromJson(data);
  }

  throw Exception("Invalid clients response");
}
static Future<void> freezeProgram(String id) async {
    await ApiClient.patch("${ApiRoutes.merchant_programs}/$id/freeze");
  }

  static Future<void> unfreezeProgram(String id) async {
    await ApiClient.patch("${ApiRoutes.merchant_programs}/$id/unfreeze");
  }
}