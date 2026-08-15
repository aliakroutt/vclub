import 'package:vclub/API/ApiClient.dart';
import 'package:vclub/API/ApiRoutes.dart';
import 'package:vclub/Features/Auth/Models/MerchantModel.dart';

class AgentService {
  /// Agent profile is returned by the same "me" endpoint as merchant/admin —
  /// the API response shape is identical (role differs: "AGENT" vs "ADMIN").
  static Future<MerchantProfileModel?> profile() async {
    final response = await ApiClient.get<Map<String, dynamic>>(
      ApiRoutes.merchant_me,
    );

    final data = response.data;
    if (data == null) return null;

    return MerchantProfileModel.fromJson(data);
  }
}