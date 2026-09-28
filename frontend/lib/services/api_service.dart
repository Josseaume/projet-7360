import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';

/// Point d'entrée unique pour parler au backend.
class ApiService {
  ApiService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  /// Retourne true si l'API répond sur /health.
  Future<bool> checkHealth() async {
    try {
      final res = await _client
          .get(ApiConfig.uri('/health'))
          .timeout(const Duration(seconds: 5));
      if (res.statusCode != 200) return false;
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      return body['status'] == 'ok';
    } catch (_) {
      return false;
    }
  }
}
