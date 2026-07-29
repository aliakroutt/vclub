import 'package:vclub/API/ApiClient.dart';
import 'package:vclub/API/ApiRoutes.dart';
import 'package:vclub/Features/Auth/Models/MerchantModel.dart';

class MerchantService {
  static Future<MerchantProfileModel?> profile() async {
    final response = await ApiClient.get<Map<String, dynamic>>(
      ApiRoutes.merchant_me,
    );

    final data = response.data;
    if (data == null) return null;

    return MerchantProfileModel.fromJson(data);
  }
}