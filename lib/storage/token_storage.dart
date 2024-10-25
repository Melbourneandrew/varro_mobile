import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  static const String _tokenKey = 'jwt_token';
  static const FlutterSecureStorage _storage = FlutterSecureStorage();
  static String? _cachedToken;

  static Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
    _cachedToken = token;
  }

  static Future<String?> getToken() async {
    if (_cachedToken != null) {
      return _cachedToken;
    }
    _cachedToken = await _storage.read(key: _tokenKey);
    return _cachedToken;
  }

  static Future<void> deleteToken() async {
    await _storage.delete(key: _tokenKey);
    _cachedToken = null;
  }

  static void clearCache() {
    _cachedToken = null;
  }
}
