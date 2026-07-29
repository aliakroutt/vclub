import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppNavigator {
  /// Check if current language is Arabic
  static bool get isArabic =>
      Get.locale?.languageCode == 'ar';

  /// Custom Get.to with RTL-aware animation
  static Future<T?> to<T>(
    Widget page, {
    int durationMs = 300,
    bool fullscreenDialog = false,
    bool preventDuplicates = true,
    RouteSettings? settings,
  }) async {
    return Get.to<T>(
      page,
      transition: _getTransition(),
      duration: Duration(milliseconds: durationMs),
      fullscreenDialog: fullscreenDialog,
      preventDuplicates: preventDuplicates,
      curve: Curves.easeOutCubic,
    );
  }

  /// Custom Get.off
  static Future<T?> off<T>(
    Widget page, {
    int durationMs = 300,
  }) async {
    return Get.off<T>(
      page,
      transition: _getTransition(),
      duration: Duration(milliseconds: durationMs),
      curve: Curves.easeOutCubic,
    );
  }

  /// Custom Get.offAll
  static Future<T?> offAll<T>(
    Widget page, {
    int durationMs = 300,
  }) async {
    return Get.offAll<T>(
      page,
      transition: _getTransition(),
      duration: Duration(milliseconds: durationMs),
      curve: Curves.easeOutCubic,
    );
  }

  /// 🎯 RTL-aware transition logic
  static Transition _getTransition() {
    return isArabic
        ? Transition.leftToRight // Arabic: from left
        : Transition.rightToLeft; // English/French: from right
  }
}