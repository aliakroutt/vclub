// lib/Core/Notifications/NotificationService.dart

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class NotificationService {
  NotificationService._();

  static const String channelKey = 'high_importance_channel';

  /// ============================================================
  /// SHOW FCM MESSAGE AS LOCAL NOTIFICATION
  /// ============================================================

  static Future<void> showNotificationFromFCM(RemoteMessage message) async {
    try {
      final notification = message.notification;

      final title =
          notification?.title ?? message.data['title']?.toString() ?? 'VClub';

      final body = notification?.body ?? message.data['body']?.toString() ?? '';

      // Don't create an empty notification
      if (title.isEmpty && body.isEmpty) {
        debugPrint('⚠️ Notification ignored: empty title/body');

        return;
      }

      final payload = <String, String>{};

      message.data.forEach((key, value) {
        payload[key] = value.toString();
      });

      final notificationId = DateTime.now().millisecondsSinceEpoch.remainder(
        2147483647,
      );

      debugPrint('🔔 Creating local notification');

      debugPrint('   title: $title');

      debugPrint('   body: $body');

      debugPrint('   payload: $payload');

      final result = await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: notificationId,

          channelKey: channelKey,

          title: title,

          body: body,

          payload: payload,

          notificationLayout: NotificationLayout.Default,

          category: NotificationCategory.Message,

          wakeUpScreen: true,

          autoDismissible: true,

          displayOnForeground: true,

          displayOnBackground: true,
        ),
      );

      debugPrint('🔔 Awesome notification result: $result');
    } catch (e, stack) {
      debugPrint('❌ showNotificationFromFCM error: $e');

      debugPrint(stack.toString());

      rethrow;
    }
  }

  /// ============================================================
  /// NOTIFICATION TAP
  /// ============================================================

  static Future<void> handleNotificationTap(
    Map<String, String?> payload,
  ) async {
    debugPrint('📬 Notification payload:');

    debugPrint(payload.toString());

    final type = payload['type'];

    switch (type) {
      case 'reward':
        debugPrint('🎁 Reward notification');

        // TODO:
        // Navigate to reward details
        //
        // Get.to(
        //   () => RewardDetailsScreen(
        //     id: payload['id']!,
        //   ),
        // );

        break;

      case 'points':
        debugPrint('⭐ Points notification');

        // TODO:
        // Navigate to card details

        break;

      case 'campaign':
        debugPrint('📢 Campaign notification');

        break;

      default:
        debugPrint('🔔 Unknown notification type: $type');
    }
  }
}
