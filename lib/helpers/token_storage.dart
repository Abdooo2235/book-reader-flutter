import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Secure storage for the auth token.
///
/// The token used to live in [SharedPreferences] under the key `token` in
/// plaintext. It is now kept in [FlutterSecureStorage]. Reads perform a
/// one-time migration so existing logged-in users are not signed out.
class TokenStorage {
  static const String _tokenKey = 'token';

  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  const TokenStorage._();

  /// Returns the stored token, or `null` if none exists.
  ///
  /// If secure storage has no token but a legacy plaintext token still lives
  /// in [SharedPreferences], it is migrated into secure storage and removed
  /// from [SharedPreferences].
  static Future<String?> read() async {
    final secureToken = await _secureStorage.read(key: _tokenKey);
    if (secureToken != null) {
      return secureToken;
    }

    // One-time migration from legacy plaintext SharedPreferences storage.
    final prefs = await SharedPreferences.getInstance();
    final legacyToken = prefs.getString(_tokenKey);
    if (legacyToken != null) {
      await _secureStorage.write(key: _tokenKey, value: legacyToken);
      await prefs.remove(_tokenKey);
      return legacyToken;
    }

    return null;
  }

  /// Persists [token] in secure storage.
  static Future<void> write(String token) async {
    await _secureStorage.write(key: _tokenKey, value: token);
  }

  /// Removes the token from both secure storage and any legacy copy.
  static Future<void> delete() async {
    await _secureStorage.delete(key: _tokenKey);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }
}
