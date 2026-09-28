import '../models/item.dart';
import 'api_client.dart';

class ItemService {
  ItemService(this._api);

  final ApiClient _api;

  Future<List<Item>> list() async {
    final res = await _api.get('/items') as List<dynamic>;
    return res.map((e) => Item.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Item> create({required String title, String description = ''}) async {
    final res = await _api.post('/items', {
      'title': title,
      'description': description,
    });
    return Item.fromJson(res as Map<String, dynamic>);
  }

  Future<Item> update(
    int id, {
    String? title,
    String? description,
    bool? done,
  }) async {
    final res = await _api.patch('/items/$id', {
      'title': ?title,
      'description': ?description,
      'done': ?done,
    });
    return Item.fromJson(res as Map<String, dynamic>);
  }

  Future<void> delete(int id) => _api.delete('/items/$id');
}
