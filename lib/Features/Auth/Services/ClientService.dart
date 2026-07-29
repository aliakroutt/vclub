import 'package:vclub/API/ApiClient.dart';
import 'package:vclub/API/ApiRoutes.dart';
import 'package:vclub/Features/Auth/Models/ClientModel.dart';



class ClientService {
  static Future<ClientProfileModel?> profile() async {
    final response = await ApiClient.get<Map<String, dynamic>>(
      ApiRoutes.client_me,
    );

    final data = response.data;
    if (data == null) return null;

    return ClientProfileModel.fromJson(data);
  }
}