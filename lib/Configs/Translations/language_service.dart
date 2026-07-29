import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageService extends GetxService {
  static const String languageKey = "language_code";

  Future<Locale> getLocale() async {
    final prefs = await SharedPreferences.getInstance();

    final languageCode = prefs.getString(languageKey) ?? "fr";

    switch (languageCode) {
      case "ar":
        return const Locale("ar", "AR");

      case "en":
        return const Locale("en", "US");

      default:
        return const Locale("fr", "FR");
    }
  }

  Future<void> changeLanguage(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(languageKey, languageCode);

    Locale locale;

    switch (languageCode) {
      case "ar":
        locale = const Locale("ar", "AR");
        break;

      case "en":
        locale = const Locale("en", "US");
        break;

      default:
        locale = const Locale("fr", "FR");
    }

    Get.updateLocale(locale);
  }
}