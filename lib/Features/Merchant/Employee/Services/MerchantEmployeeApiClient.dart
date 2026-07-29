import 'package:dio/dio.dart';
import 'package:vclub/API/ApiClient.dart';
import 'package:vclub/API/ApiRoutes.dart';
import 'package:vclub/Features/Merchant/Employee/Models/EmployesModel.dart';

class MerchantEmployeeApiClient {
  MerchantEmployeeApiClient._();

  static Future<EmployeesPaginatedResponse> getEmployees({
    required int page,
    required int limit,
    String? search,
  }) async {
    final Response response = await ApiClient.get(
      ApiRoutes.merchant_agents,
      queryParameters: {
        "page": page,
        "limit": limit,
        if (search != null && search.trim().isNotEmpty) "search": search.trim(),
      },
    );

    final data = response.data;
    if (data is Map<String, dynamic>) {
      return EmployeesPaginatedResponse.fromJson(data);
    }
    throw Exception("Invalid employees response");
  }

  static Future<void> deleteEmployee(String id) async {
    await ApiClient.delete("${ApiRoutes.merchant_agents}/$id");
  }

  // ── NEW ──────────────────────────────────────────────────────────────

  static Future<EmployeeModel> createEmployee(
    Map<String, dynamic> payload,
  ) async {
    final Response response = await ApiClient.post(
      ApiRoutes.merchant_agents,
      data: payload,
    );

    final data = response.data;
    if (data is Map<String, dynamic>) {
      final json = data['data'] is Map<String, dynamic> ? data['data'] : data;
      return EmployeeModel.fromJson(json as Map<String, dynamic>);
    }
    throw Exception("Invalid create employee response");
  }

  static Future<EmployeeModel> updateEmployee(
    String id,
    Map<String, dynamic> payload,
  ) async {
    final Response response = await ApiClient.patch(
      "${ApiRoutes.merchant_agents}/$id",
      data: payload,
    );

    final data = response.data;
    if (data is Map<String, dynamic>) {
      final json = data['data'] is Map<String, dynamic> ? data['data'] : data;
      return EmployeeModel.fromJson(json as Map<String, dynamic>);
    }
    throw Exception("Invalid update employee response");
  }
}