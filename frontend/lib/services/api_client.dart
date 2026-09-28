import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';

/// Erreur renvoyée par l'API, avec un message lisible pour l'utilisateur.
class ApiException implements Exception {
  ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  bool get isUnauthorized => statusCode == 401;

  @override
  String toString() => message;
}

/// Client HTTP bas niveau : ajoute le token, encode/décode le JSON,
/// transforme les erreurs FastAPI en [ApiException].
class ApiClient {
  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  String? token;

  /// Appelé quand l'API répond 401 (token expiré) : permet de déconnecter.
  void Function()? onUnauthorized;

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (token != null) 'Authorization': 'Bearer $token',
  };

  Future<dynamic> get(String path) => _send('GET', path);
  Future<dynamic> post(String path, [Object? body]) =>
      _send('POST', path, body);
  Future<dynamic> patch(String path, [Object? body]) =>
      _send('PATCH', path, body);
  Future<dynamic> delete(String path) => _send('DELETE', path);

  Future<dynamic> _send(String method, String path, [Object? body]) async {
    final request = http.Request(method, ApiConfig.uri(path))
      ..headers.addAll(_headers);
    if (body != null) request.body = jsonEncode(body);

    final http.Response res;
    try {
      res = await http.Response.fromStream(
        await _client.send(request).timeout(const Duration(seconds: 15)),
      );
    } catch (_) {
      throw ApiException('Impossible de joindre le serveur');
    }

    if (res.statusCode >= 200 && res.statusCode < 300) {
      if (res.body.isEmpty) return null;
      return jsonDecode(utf8.decode(res.bodyBytes));
    }

    if (res.statusCode == 401 && token != null) onUnauthorized?.call();
    throw ApiException(_errorMessage(res), statusCode: res.statusCode);
  }

  static String _errorMessage(http.Response res) {
    try {
      final detail = (jsonDecode(utf8.decode(res.bodyBytes)) as Map)['detail'];
      if (detail is String) return detail;
      // Erreurs de validation FastAPI (422) : liste de {loc, msg, ...}
      if (detail is List && detail.isNotEmpty) {
        return (detail.first as Map)['msg'] as String;
      }
    } catch (_) {}
    return 'Erreur serveur (${res.statusCode})';
  }
}
