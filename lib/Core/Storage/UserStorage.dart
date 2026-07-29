import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:vclub/Features/Auth/Models/ClientModel.dart';
import 'package:vclub/Features/Auth/Models/MerchantModel.dart';

class UserStorage {
  UserStorage._();

  static SharedPreferences? _prefs;
  static Future<SharedPreferences>? _initFuture;

  static const _clientKey = "client_profile";
  static const _merchantKey = "merchant_profile";

  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// Ensures prefs are ready even if init() was never awaited elsewhere.
  static Future<SharedPreferences> _ensurePrefs() async {
    if (_prefs != null) return _prefs!;
    _initFuture ??= SharedPreferences.getInstance();
    _prefs = await _initFuture;
    return _prefs!;
  }

  static Future<void> saveClient(ClientProfileModel client) async {
    final prefs = await _ensurePrefs();
    try {
      await prefs.setString(_clientKey, jsonEncode(client.toJson()));
    } catch (e) {
      // Encoding failure shouldn't crash the caller
      // ignore: avoid_print
      print("⚠️ UserStorage.saveClient failed: $e");
    }
  }

  static Future<ClientProfileModel?> getClient() async {
    final prefs = await _ensurePrefs();
    final json = prefs.getString(_clientKey);

    if (json == null || json.isEmpty) return null;

    try {
      final decoded = jsonDecode(json);
      if (decoded is! Map<String, dynamic>) return null;
      return ClientProfileModel.fromJson(decoded);
    } catch (e) {
      // Corrupted/old-format data shouldn't crash the app
      print("⚠️ UserStorage.getClient failed to parse: $e");
      await clear();
      return null;
    }
  }

  static Future<void> saveMerchant(MerchantProfileModel merchant) async {
    final prefs = await _ensurePrefs();
    try {
      await prefs.setString(_merchantKey, jsonEncode(merchant.toJson()));
    } catch (e) {
      // Encoding failure shouldn't crash the caller
      // ignore: avoid_print
      print("⚠️ UserStorage.saveMerchant failed: $e");
    }
  }

  static Future<MerchantProfileModel?> getMerchant() async {
    final prefs = await _ensurePrefs();
    final json = prefs.getString(_merchantKey);

    if (json == null || json.isEmpty) return null;

    try {
      final decoded = jsonDecode(json);
      if (decoded is! Map<String, dynamic>) return null;
      return MerchantProfileModel.fromJson(decoded);
    } catch (e) {
      // Corrupted/old-format data shouldn't crash the app
      print("⚠️ UserStorage.getMerchant failed to parse: $e");
      await clear();
      return null;
    }
  }

  static Future<void> clear() async {
    final prefs = await _ensurePrefs();
    await prefs.remove(_clientKey);
    await prefs.remove(_merchantKey);
  }
}