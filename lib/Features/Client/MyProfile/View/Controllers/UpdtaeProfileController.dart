import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:vclub/Core/Snackbars.dart';
import 'package:vclub/Core/Storage/Controllers/ClientController.dart';
import 'package:vclub/Features/Client/MyProfile/View/Service/ClientUpdateService.dart';


class UpdateProfileController extends GetxController {
  final ClientController _clientController = Get.find<ClientController>();

  final RxBool isSaving = false.obs;
  final RxString updateError = "".obs;


  Future<bool> updateProfile({
    required String firstName,
    required String lastName,
    required String phone,
    DateTime? birthday,
    String? avatar,
  }) async {
    if (isSaving.value) return false;

    try {
      isSaving.value = true;
      updateError.value = "";

      final body = <String, dynamic>{
        "firstName": firstName,
        "lastName": lastName,
        "phone": phone,
        "birthday": birthday?.toIso8601String(),
        "avatar": avatar,
        "language": Get.locale?.languageCode ?? 'en',
      };

      final updatedClient = await UpdateProfileApiClient.updateProfile(body);
      await ClientController.to.saveClient(updatedClient);
      _clientController.client.value = updatedClient;

      return true;
    } catch (e) {
      updateError.value = _resolveErrorMessage(e);
      AppSnackBar.error(updateError.value);
      debugPrint('updateProfile error: $e');
      return false;
    } finally {
      isSaving.value = false;
    }
  }
  String _resolveErrorMessage(Object e) {
    if (e is DioException) {
      // Prefer a message the backend explicitly sent us.
      final data = e.response?.data;
      if (data is Map && data['message'] is String && (data['message'] as String).trim().isNotEmpty) {
        return data['message'] as String;
      }

      switch (e.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return 'connection_timeout'.tr;
        case DioExceptionType.connectionError:
          return 'no_internet_connection'.tr;
        case DioExceptionType.badResponse:
          final status = e.response?.statusCode ?? 0;
          if (status == 422) return 'invalid_data'.tr;
          if (status == 401 || status == 403) return 'session_expired'.tr;
          if (status >= 500) return 'server_error'.tr;
          return 'profile_update_failed'.tr;
        case DioExceptionType.cancel:
          return 'request_cancelled'.tr;
        default:
          return 'profile_update_failed'.tr;
      }
    }

    return 'profile_update_failed'.tr;
  }
}