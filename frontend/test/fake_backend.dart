import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

/// Faux backend en mémoire qui imite l'API FastAPI, pour les tests widgets.
class FakeBackend {
  final users = <String, Map<String, dynamic>>{}; // email -> user
  final passwords = <String, String>{};
  final items = <Map<String, dynamic>>[];
  int _nextId = 1;
  bool online = true;

  late final client = MockClient(_handle);

  static const _token = 'fake-token';

  Future<http.Response> _handle(http.Request req) async {
    if (!online) throw http.ClientException('offline');
    final path = req.url.path.replaceFirst('/api/v1', '');
    final body = req.body.isEmpty ? null : jsonDecode(req.body);
    final authed = req.headers['Authorization'] == 'Bearer $_token';
    final user = users.values.firstOrNull;

    http.Response json(Object? data, [int status = 200]) => http.Response(
      data == null ? '' : jsonEncode(data),
      status,
      headers: {'content-type': 'application/json; charset=utf-8'},
    );

    switch ((req.method, path)) {
      case ('GET', '/health'):
        return json({'status': 'ok'});
      case ('POST', '/auth/register'):
        final email = body['email'] as String;
        if (users.containsKey(email)) {
          return json({'detail': 'Cet email est déjà utilisé'}, 409);
        }
        users[email] = {
          'id': _nextId++,
          'email': email,
          'full_name': body['full_name'],
          'created_at': '2026-01-01T00:00:00Z',
        };
        passwords[email] = body['password'] as String;
        return json(users[email], 201);
      case ('POST', '/auth/login'):
        if (passwords[body['email']] != body['password']) {
          return json({'detail': 'Email ou mot de passe incorrect'}, 401);
        }
        return json({'access_token': _token, 'token_type': 'bearer'});
    }

    if (!authed || user == null) return json({'detail': 'Non autorisé'}, 401);

    switch ((req.method, path)) {
      case ('GET', '/users/me'):
        return json(user);
      case ('PATCH', '/users/me'):
        if (body['full_name'] != null) user['full_name'] = body['full_name'];
        return json(user);
      case ('GET', '/items'):
        return json(items.reversed.toList());
      case ('POST', '/items'):
        final item = {
          'id': _nextId++,
          'title': body['title'],
          'description': body['description'] ?? '',
          'done': false,
        };
        items.add(item);
        return json(item, 201);
    }

    final match = RegExp(r'^/items/(\d+)$').firstMatch(path);
    if (match != null) {
      final id = int.parse(match.group(1)!);
      final item = items.where((i) => i['id'] == id).firstOrNull;
      if (item == null) return json({'detail': 'Introuvable'}, 404);
      if (req.method == 'PATCH') {
        item.addAll(Map<String, dynamic>.from(body as Map));
        return json(item);
      }
      if (req.method == 'DELETE') {
        items.remove(item);
        return json(null, 204);
      }
    }
    return json({'detail': 'Not found'}, 404);
  }
}
