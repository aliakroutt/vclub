import 'package:shared_preferences/shared_preferences.dart';
import 'package:vclub/Core/Storage/Eneums.dart';

class TokenStorage {
  TokenStorage._();

  static const String _accessTokenKey = "accessToken";
  static const String _refreshTokenKey = "refreshToken";
  static const String _roleKey = "userRole";
  static const String _userIdKey = "userId";
  static const String _companyIdKey = "companyId";

  static SharedPreferences? _prefs;

  /// MUST be called in main()
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  //==========================================================
  // ACCESS TOKEN
  //==========================================================

  static Future<void> saveAccessToken(String token) async {
    await _prefs?.setString(_accessTokenKey, token);
  }

  static String? getAccessToken() {
    return _prefs?.getString(_accessTokenKey);
  }

  //==========================================================
  // REFRESH TOKEN
  //==========================================================

  static Future<void> saveRefreshToken(String token) async {
    await _prefs?.setString(_refreshTokenKey, token);
  }

  static String? getRefreshToken() {
    return _prefs?.getString(_refreshTokenKey);
  }

  //==========================================================
  // SAVE BOTH TOKENS (LOGIN)
  //==========================================================

  static Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await saveAccessToken(accessToken);
    await saveRefreshToken(refreshToken);
  }

  //==========================================================
  // CLEAR (LOGOUT)
  //==========================================================

  static Future<void> clear() async {
    await _prefs?.remove(_accessTokenKey);
    await _prefs?.remove(_refreshTokenKey);
    await _prefs?.remove(_roleKey);
    await _prefs?.remove(_userIdKey);
    await _prefs?.remove(_companyIdKey);
  }

  //==========================================================
  // AUTH STATE
  //==========================================================

  static bool get isLoggedIn {
    final token = _prefs?.getString(_accessTokenKey);
    return token != null && token.isNotEmpty;
  }

  /// user role
  static Future<void> saveUserRole(UserRole role) async {
    await _prefs!.setString(_roleKey, role.value);
  }

  static UserRole? get userRole {
    final role = _prefs?.getString(_roleKey);

    if (role == null) return null;

    return UserRoleExtension.fromString(role);
  }

  // save user id
  static Future<void> saveUserId(String id) async {
    await _prefs!.setString(_userIdKey, id);
  }

  static String? get userId => _prefs?.getString(_userIdKey);

  // save company id
  static Future<void> saveCompanyId(String? id) async {
    if (id == null) {
      await _prefs!.remove(_companyIdKey);
      return;
    }

    await _prefs!.setString(_companyIdKey, id);
  }

  static String? get companyId => _prefs?.getString(_companyIdKey);
}
