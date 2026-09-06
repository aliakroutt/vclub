// lib/Features/Auth/Services/DeleteAccountService.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Response;
import 'package:vclub/API/ApiClient.dart';
import 'package:vclub/API/ApiRoutes.dart';
import 'package:vclub/API/Socket/MerchantRealtimeController.dart';
import 'package:vclub/API/SocketService.dart';
import 'package:vclub/Core/Navigation/app_navigator.dart';
import 'package:vclub/Core/Storage/TokenStorage.dart';
import 'package:vclub/Core/Storage/UserStorage.dart';
import 'package:vclub/Features/Auth/Services/DeviceService.dart';
import 'package:vclub/Features/Auth/Views/Login.dart';

class DeleteAccountService {
  DeleteAccountService._();

  /// Permanently deletes the current user's account on the backend, then
  /// runs the exact same cleanup as a normal logout (device token
  /// unregistration, socket disconnect, controller resets, local storage
  /// clear) before returning to Login.
  ///
  /// Returns true if the account was actually deleted. On failure, nothing
  /// is cleared locally and the user stays logged in — a delete failure
  /// should never leave the app in a logged-out-but-not-deleted limbo.
  static Future<bool> deleteAccount({
    List<VoidCallback> resetControllers = const [],
  }) async {
    try {
      await ApiClient.delete(ApiRoutes.delete_account);
    } catch (e) {
      debugPrint('⚠️ DeleteAccountService: delete account API call failed: $e');
      return false;
    }

    // Account is confirmed deleted server-side at this point — proceed
    // with the same cleanup sequence as a normal logout. Each step is
    // best-effort and swallowed, since the account is already gone and
    // there's no going back regardless of what fails locally.
    try {
      await _unregisterDeviceToken();
    } catch (e) {
      debugPrint('⚠️ DeleteAccountService: device token unregister failed: $e');
    }

    _disconnectRealtime();

    for (final reset in resetControllers) {
      try {
        reset();
      } catch (e) {
        debugPrint('⚠️ DeleteAccountService: a controller reset failed: $e');
      }
    }

    await TokenStorage.clear();
    await UserStorage.clear();

    AppNavigator.to(const Login());
    return true;
  }

  static Future<void> _unregisterDeviceToken() async {
    final role = TokenStorage.userRole;
    if (role == null) return;
    await DeviceService.unregisterFcmToken(role);
  }

  static void _disconnectRealtime() {
    try {
      Get.find<SocketService>().disconnect();
    } catch (e) {
      debugPrint('⚠️ DeleteAccountService: socket disconnect failed: $e');
    }

    if (Get.isRegistered<MerchantRealtimeController>()) {
      Get.delete<MerchantRealtimeController>();
    }
  }
}