import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vclub/Features/Auth/Models/MerchantModel.dart';

/// Mirrors UserStorage's merchant persistence, but keyed separately so an
/// agent's cached profile never collides with a merchant/admin profile
/// cached on the same device.
class AgentStorage {
  AgentStorage._();

  static const String _agentKey = "cached_agent_profile";

  static Future<void> saveAgent(MerchantProfileModel model) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_agentKey, jsonEncode(model.toJson()));
  }

  static Future<MerchantProfileModel?> getAgent() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_agentKey);
    if (raw == null) return null;

    try {
      return MerchantProfileModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_agentKey);
  }
}