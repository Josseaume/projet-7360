import 'package:flutter/foundation.dart';

import '../models/user.dart';
import '../services/api_client.dart';
import '../services/auth_service.dart';
import '../services/token_storage.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

/// État global de connexion, écouté par l'UI via Provider.
class AuthState extends ChangeNotifier {
  AuthState({
    required this._api,
    required this._auth,
    required this._storage,
  }) {
    _api.onUnauthorized = logout;
  }

  final ApiClient _api;
  final AuthService _auth;
  final TokenStorage _storage;

  AuthStatus status = AuthStatus.unknown;
  User? user;

  /// Au démarrage : reprend la session si un token valide est stocké.
  Future<void> restore() async {
    final token = await _storage.read();
    if (token == null) return _setLoggedOut();
    _api.token = token;
    try {
      user = await _auth.me();
      status = AuthStatus.authenticated;
      notifyListeners();
    } on ApiException catch (e) {
      // Serveur injoignable : on garde le token mais on renvoie au login.
      if (e.isUnauthorized) await _storage.clear();
      _setLoggedOut();
    }
  }

  Future<void> login(String email, String password) async {
    final token = await _auth.login(email.trim(), password);
    _api.token = token;
    await _storage.write(token);
    user = await _auth.me();
    status = AuthStatus.authenticated;
    notifyListeners();
  }

  Future<void> register(String email, String password, String fullName) async {
    await _auth.register(email.trim(), password, fullName.trim());
    await login(email, password);
  }

  Future<void> updateProfile({String? fullName, String? password}) async {
    user = await _auth.updateMe(fullName: fullName, password: password);
    notifyListeners();
  }

  Future<void> deleteAccount() async {
    await _auth.deleteMe();
    await logout();
  }

  Future<void> logout() async {
    await _storage.clear();
    _setLoggedOut();
  }

  void _setLoggedOut() {
    _api.token = null;
    user = null;
    status = AuthStatus.unauthenticated;
    notifyListeners();
  }
}
