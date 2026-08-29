// lib/Features/Auth/Services/DeviceService.dart
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:vclub/API/ApiClient.dart';
import 'package:vclub/API/ApiRoutes.dart';
import 'package:vclub/Core/Storage/Eneums.dart';

class DeviceService {
  DeviceService._();

  /// Fetches the device's FCM token and registers it with the backend,
  /// using the endpoint that matches [role]. Never throws — any failure
  /// (missing FCM token, network error, server error) is logged and
  /// swallowed so it never blocks login or app startup.
  static Future<void> registerFcmToken(UserRole role) async {
    try {
      await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      final token = await FirebaseMessaging.instance.getToken();

      if (token == null || token.isEmpty) {
        debugPrint(
          '⚠️ DeviceService: no FCM token available, skipping registration',
        );
        return;
      }

      final path = role == UserRole.client
          ? ApiRoutes.client_save_token
          : ApiRoutes.merchant_save_token;

      await ApiClient.post(path, data: {'token': token});

      debugPrint('✅ DeviceService: FCM token registered ($path)');
    } catch (e, st) {
      // Intentionally swallowed — device-token registration must never
      // block or fail the login/app-start flow.
      debugPrint('⚠️ DeviceService: failed to register FCM token: $e');
      debugPrint('$st');
    }
  }
}
