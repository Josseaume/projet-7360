import 'package:shared_preferences/shared_preferences.dart';

/// Persistance du token entre deux lancements de l'app.
///
/// Pour la prod, envisager flutter_secure_storage (Keychain / Keystore).
class TokenStorage {
  static const _key = 'access_token';

  Future<String?> read() async =>
      (await SharedPreferences.getInstance()).getString(_key);

  Future<void> write(String token) async =>
      (await SharedPreferences.getInstance()).setString(_key, token);

  Future<void> clear() async =>
      (await SharedPreferences.getInstance()).remove(_key);
}
