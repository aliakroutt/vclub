import 'package:vclub/API/ApiClient.dart';
import 'package:vclub/API/ApiRoutes.dart';
import 'package:vclub/Features/Auth/Models/ClientModel.dart'; // adjust import to your actual ClientModel location

class UpdateProfileApiClient {
  UpdateProfileApiClient._();

  /// Sends the updated profile fields and returns the fresh client object
  /// from the API response so the caller can sync local state with it.
  static Future<ClientProfileModel> updateProfile(Map<String, dynamic> body) async {
    final response = await ApiClient.patch(
      ApiRoutes.client_me, // add this route if it doesn't exist yet
      data: body,
    );

    final data = response.data;

    // Adjust this if your API wraps the client under a key, e.g. data['client']
    return ClientProfileModel.fromJson(Map<String, dynamic>.from(data));
  }
}