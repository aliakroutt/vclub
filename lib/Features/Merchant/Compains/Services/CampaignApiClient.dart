import 'package:dio/dio.dart';
import 'package:vclub/API/ApiClient.dart';
import 'package:vclub/API/ApiRoutes.dart';
import 'package:vclub/Features/Merchant/Compains/Models/CampaignModel.dart';

class CampaignApiClient {
  CampaignApiClient._();

  static Future<CampaignsPaginatedResponse> getCampaigns({
    required int page,
    required int limit,
    String? search,
  }) async {
    final Response response = await ApiClient.get(
      ApiRoutes.merchant_compaigns,
      queryParameters: {
        "page": page,
        "limit": limit,
        if (search != null && search.trim().isNotEmpty) "search": search.trim(),
      },
    );

    final data = response.data;
    if (data is Map<String, dynamic>) {
      return CampaignsPaginatedResponse.fromJson(data);
    }
    throw Exception("Invalid campaigns response");
  }

  static Future<void> deleteCampaign(String id) async {
    await ApiClient.delete("${ApiRoutes.merchant_compaigns}/$id");
  }

  static Future<CampaignModel> createCampaign(Map<String, dynamic> payload) async {
    final Response response = await ApiClient.post(
      ApiRoutes.merchant_compaigns,
      data: payload,
    );

    final data = response.data;
    if (data is Map<String, dynamic>) {
      final json = data['data'] is Map<String, dynamic> ? data['data'] : data;
      return CampaignModel.fromJson(json as Map<String, dynamic>);
    }
    throw Exception("Invalid create campaign response");
  }
}