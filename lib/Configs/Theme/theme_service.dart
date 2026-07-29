import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService extends GetxService {
  static const String _key = "theme_mode";

  /// true = dark, false = light
  final RxBool isDarkMode = false.obs;

  /// INIT (call on app start)
  Future<ThemeMode> initTheme() async {
    final prefs = await SharedPreferences.getInstance();

    final saved = prefs.getBool(_key);

    // default = light mode
    isDarkMode.value = saved ?? false;

    return isDarkMode.value ? ThemeMode.dark : ThemeMode.light;
  }

  /// TOGGLE THEME
  Future<void> toggleTheme() async {
    final prefs = await SharedPreferences.getInstance();

    isDarkMode.value = !isDarkMode.value;

    await prefs.setBool(_key, isDarkMode.value);

    Get.changeThemeMode(
      isDarkMode.value ? ThemeMode.dark : ThemeMode.light,
    );
  }

  /// SET LIGHT
  Future<void> setLightMode() async {
    final prefs = await SharedPreferences.getInstance();

    isDarkMode.value = false;

    await prefs.setBool(_key, false);

    Get.changeThemeMode(ThemeMode.light);
  }

  /// SET DARK
  Future<void> setDarkMode() async {
    final prefs = await SharedPreferences.getInstance();

    isDarkMode.value = true;

    await prefs.setBool(_key, true);

    Get.changeThemeMode(ThemeMode.dark);
  }

  /// CHECK
  bool get isDark => isDarkMode.value;
}