// lib/Core/Notifications/InitNotifications.dart

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:vclub/Core/Notifications/NotificationService.dart';
import 'package:vclub/firebase_options.dart';

/// ============================================================
/// FCM BACKGROUND HANDLER
/// ============================================================

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    WidgetsFlutterBinding.ensureInitialized();

    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    debugPrint('🔔 [Background] Message received: ${message.messageId}');

    debugPrint(
      '🔔 [Background] notification: '
      '${message.notification?.title} / '
      '${message.notification?.body}',
    );

    debugPrint('🔔 [Background] data: ${message.data}');

    // IMPORTANT:
    // If this is a data-only notification, we need to
    // create the local notification ourselves.
    await NotificationService.showNotificationFromFCM(message);

    debugPrint('✅ [Background] Local notification created');
  } catch (e, stack) {
    debugPrint('❌ [Background] Notification error: $e');

    debugPrint(stack.toString());
  }
}

/// ============================================================
/// AWESOME NOTIFICATIONS CALLBACKS
/// ============================================================

@pragma('vm:entry-point')
Future<void> onActionReceivedMethod(ReceivedAction receivedAction) async {
  debugPrint('📬 Awesome notification tapped');

  debugPrint('📦 Payload: ${receivedAction.payload}');

  await NotificationService.handleNotificationTap(receivedAction.payload ?? {});
}

@pragma('vm:entry-point')
Future<void> onNotificationCreatedMethod(
  ReceivedNotification receivedNotification,
) async {
  debugPrint('🟢 Notification created: ${receivedNotification.id}');
}

@pragma('vm:entry-point')
Future<void> onNotificationDisplayedMethod(
  ReceivedNotification receivedNotification,
) async {
  debugPrint('🟢 Notification displayed: ${receivedNotification.id}');
}

@pragma('vm:entry-point')
Future<void> onDismissActionReceivedMethod(
  ReceivedAction receivedAction,
) async {
  debugPrint('⚪ Notification dismissed');
}

/// ============================================================
/// INITIALIZATION
/// ============================================================

Future<void> initNotifications() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();

    // ----------------------------------------------------------
    // Firebase
    // ----------------------------------------------------------

    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    debugPrint('✅ Firebase initialized');

    final messaging = FirebaseMessaging.instance;

    // ----------------------------------------------------------
    // FCM permission
    // ----------------------------------------------------------

    final settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    debugPrint(
      '🔐 FCM permission: '
      '${settings.authorizationStatus}',
    );

    // ----------------------------------------------------------
    // Android local notification permission
    // ----------------------------------------------------------

    final awesomeNotifications = AwesomeNotifications();

    final isAllowed = await awesomeNotifications.isNotificationAllowed();

    debugPrint('🔐 Awesome notification permission: $isAllowed');

    if (!isAllowed) {
      await awesomeNotifications.requestPermissionToSendNotifications();
    }

    // ----------------------------------------------------------
    // Awesome Notifications initialization
    // ----------------------------------------------------------

    await awesomeNotifications.initialize(null, [
      NotificationChannel(
        channelKey: 'high_importance_channel',
        channelName: 'High Importance Notifications',
        channelDescription: 'Channel for important notifications',

        importance: NotificationImportance.Max,

        playSound: true,
        enableVibration: true,

        // Good for Android heads-up notifications
        enableLights: true,
        ledColor: Colors.white,
      ),
    ], debug: true);

    debugPrint('✅ Awesome Notifications initialized');

    // ----------------------------------------------------------
    // Awesome callbacks
    // ----------------------------------------------------------

    await awesomeNotifications.setListeners(
      onActionReceivedMethod: onActionReceivedMethod,
      onNotificationCreatedMethod: onNotificationCreatedMethod,
      onNotificationDisplayedMethod: onNotificationDisplayedMethod,
      onDismissActionReceivedMethod: onDismissActionReceivedMethod,
    );

    debugPrint('✅ Awesome notification listeners registered');

    // ----------------------------------------------------------
    // FCM background handler
    // ----------------------------------------------------------

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    debugPrint('✅ FCM background handler registered');

    // ----------------------------------------------------------
    // FOREGROUND
    // ----------------------------------------------------------

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      debugPrint('🔔 [Foreground] Message received');

      debugPrint('🆔 ID: ${message.messageId}');

      debugPrint(
        '🔔 notification: '
        '${message.notification?.title} / '
        '${message.notification?.body}',
      );

      debugPrint('📦 data: ${message.data}');

      try {
        await NotificationService.showNotificationFromFCM(message);

        debugPrint('✅ [Foreground] Notification displayed');
      } catch (e, stack) {
        debugPrint('❌ [Foreground] Notification error: $e');

        debugPrint(stack.toString());
      }
    });

    debugPrint('✅ FCM foreground listener registered');

    // ----------------------------------------------------------
    // APP OPENED FROM BACKGROUND
    // ----------------------------------------------------------

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('📬 App opened from notification');

      debugPrint('📦 data: ${message.data}');

      NotificationService.handleNotificationTap(
        message.data.map((key, value) => MapEntry(key, value?.toString())),
      );
    });

    // ----------------------------------------------------------
    // APP OPENED FROM TERMINATED STATE
    // ----------------------------------------------------------

    final initialMessage = await messaging.getInitialMessage();

    if (initialMessage != null) {
      debugPrint('📬 App launched from notification');

      debugPrint('📦 data: ${initialMessage.data}');

      WidgetsBinding.instance.addPostFrameCallback((_) {
        NotificationService.handleNotificationTap(
          initialMessage.data.map(
            (key, value) => MapEntry(key, value?.toString()),
          ),
        );
      });
    }

    // ----------------------------------------------------------
    // FCM TOKEN
    // ----------------------------------------------------------

    final token = await messaging.getToken();

    debugPrint('🔥 FCM TOKEN:');

    debugPrint(token);

    // ----------------------------------------------------------
    // TOKEN REFRESH
    // ----------------------------------------------------------

    messaging.onTokenRefresh.listen((newToken) {
      debugPrint('🔄 FCM TOKEN REFRESHED:');

      debugPrint(newToken);

      // TODO:
      // Send newToken to your backend.
    });

    debugPrint('✅ Notification initialization completed');
  } catch (e, stack) {
    debugPrint('❌ initNotifications error: $e');

    debugPrint(stack.toString());
  }
}
