import 'package:dio/dio.dart';
import 'package:vclub/API/ApiClient.dart';
import 'package:vclub/API/ApiRoutes.dart';
import 'package:vclub/Features/Client/FortuneWheel/Models/FortuneWheelModels.dart';

class FortuneWheelApiClient {
  FortuneWheelApiClient._();

  static List<Map<String, dynamic>> _extractList(dynamic data) {
    if (data is List) return data.whereType<Map<String, dynamic>>().toList();
    if (data is Map<String, dynamic> && data['data'] is List) {
      return (data['data'] as List).whereType<Map<String, dynamic>>().toList();
    }
    return [];
  }

  static Future<List<ClientCompanyModel>> getMemberships() async {
    final Response response = await ApiClient.get(ApiRoutes.client_cards);
    return _extractList(response.data).map((e) => ClientCompanyModel.fromJson(e)).toList();
  }

  static Future<WheelModel> getWheel(String companyId) async {
    final Response response = await ApiClient.get(ApiRoutes.getWheel(companyId));
    final data = response.data;
    if (data is Map<String, dynamic>) {
      return WheelModel.fromJson(companyId, data);
    }
    throw Exception("Invalid wheel response");
  }

  static Future<List<WheelHistoryItemModel>> getHistory() async {
    final Response response = await ApiClient.get(ApiRoutes.client_wheel_history);
    return _extractList(response.data).map((e) => WheelHistoryItemModel.fromJson(e)).toList();
  }

  static Future<WheelSpinResult> spin(String wheelId) async {
    final Response response = await ApiClient.post(ApiRoutes.spinwheel(wheelId));
    final data = response.data;
    if (data is Map<String, dynamic>) {
      return WheelSpinResult.fromJson(data);
    }
    throw Exception("Invalid spin response");
  }
}