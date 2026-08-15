import 'package:vclub/API/ApiClient.dart';
import 'package:vclub/API/ApiRoutes.dart';

class AgentProfileApiClient {
  AgentProfileApiClient._();

  static Future<void> updateName({
    required String firstName,
    required String lastName,
  }) async {
    await ApiClient.patch(
      ApiRoutes.merchant_me,
      data: {
        "firstName": firstName,
        "lastName": lastName,
      },
    );
  }
}