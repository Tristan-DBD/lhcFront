import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _tokenKey = 'auth_token';
  static SharedPreferences? _prefs;

  static Future<SharedPreferences> _getPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  // Garde de token dans le stockage local
  static Future<void> saveToken(String token) async {
    final prefs = await _getPrefs();
    await prefs.setString(_tokenKey, token);
  }

  // Récupération du token depuis le stockage local
  static Future<String?> getToken() async {
    final prefs = await _getPrefs();
    return prefs.getString(_tokenKey);
  }

  // Suppression du token du stockage local
  static Future<void> clearToken() async {
    final prefs = await _getPrefs();
    await prefs.remove(_tokenKey);
  }
}
