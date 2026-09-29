import '../models/user.dart';
import 'api_client.dart';

class AuthService {
  AuthService(this._api);

  final ApiClient _api;

  Future<bool> checkHealth() async {
    try {
      final res = await _api.get('/health') as Map<String, dynamic>;
      return res['status'] == 'ok';
    } catch (_) {
      return false;
    }
  }

  /// Retourne le token d'accès.
  Future<String> login(String email, String password) async {
    final res = await _api.post('/auth/login', {
      'email': email,
      'password': password,
    }) as Map<String, dynamic>;
    return res['access_token'] as String;
  }

  Future<void> register(String email, String password, String fullName) =>
      _api.post('/auth/register', {
        'email': email,
        'password': password,
        'full_name': fullName,
      });

  Future<User> me() async =>
      User.fromJson(await _api.get('/users/me') as Map<String, dynamic>);

  Future<User> updateMe({String? fullName, String? password}) async {
    final res = await _api.patch('/users/me', {
      'full_name': ?fullName,
      'password': ?password,
    });
    return User.fromJson(res as Map<String, dynamic>);
  }

  Future<void> deleteMe() => _api.delete('/users/me');
}
