// lib/Features/Auth/Services/LogoutService.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Response;
import 'package:vclub/API/ApiClient.dart';
import 'package:vclub/API/ApiRoutes.dart';
import 'package:vclub/API/Socket/MerchantRealtimeController.dart';
import 'package:vclub/API/SocketService.dart';
import 'package:vclub/Core/Navigation/app_navigator.dart';
import 'package:vclub/Core/Storage/TokenStorage.dart';
import 'package:vclub/Core/Storage/UserStorage.dart';
import 'package:vclub/Features/Auth/Views/Login.dart';

VoidCallback safeReset<T>(void Function() reset) {
  return () {
    if (Get.isRegistered<T>()) {
      reset();
    }
  };
}

class LogoutService {
  LogoutService._();

  static Future<void> logout({
  List<VoidCallback> resetControllers = const [],
}) async {
  try {
    await _callLogoutApi();
    _disconnectRealtime();

    for (final reset in resetControllers) {
      try {
        reset();
      } catch (e) {
        debugPrint('⚠️ LogoutService: a controller reset failed: $e');
      }
    }

    await TokenStorage.clear();
    await UserStorage.clear();

    AppNavigator.to(const Login());
  } catch (e) {
    debugPrint('⚠️ LogoutService: unexpected error during logout: $e');
    AppNavigator.to(const Login());
  }
}

  static Future<void> _callLogoutApi() async {
    try {
      final refreshToken = TokenStorage.getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) return;

      await ApiClient.post(
        ApiRoutes.Logout,
        data: {"refreshToken": refreshToken},
      );
    } catch (e) {
      debugPrint('⚠️ LogoutService: logout API call failed: $e');
    }
  }

  static void _disconnectRealtime() {
    try {
      Get.find<SocketService>().disconnect();
    } catch (e) {
      debugPrint('⚠️ LogoutService: socket disconnect failed: $e');
    }

    if (Get.isRegistered<MerchantRealtimeController>()) {
      Get.delete<MerchantRealtimeController>();
    }
  }
}