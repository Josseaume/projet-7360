import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/item.dart';
import '../services/item_service.dart';
import '../state/auth_state.dart';
import '../widgets/error_snackbar.dart';
import 'item_form_page.dart';
import 'profile_page.dart';

/// Accueil : liste des items de l'utilisateur connecté.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Item>? _items;
  Object? _error;

  ItemService get _service => context.read<ItemService>();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final items = await _service.list();
      if (mounted) {
        setState(() {
          _items = items;
          _error = null;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _error = e);
    }
  }

  Future<void> _openForm([Item? item]) async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => ItemFormPage(item: item)),
    );
    if (changed == true) _load();
  }

  Future<void> _toggle(Item item) async {
    try {
      final updated = await _service.update(item.id, done: !item.done);
      setState(() {
        _items = [for (final i in _items!) i.id == item.id ? updated : i];
      });
    } catch (e) {
      if (mounted) showError(context, e);
    }
  }

  Future<void> _delete(Item item) async {
    final previous = _items!;
    setState(() => _items = previous.where((i) => i.id != item.id).toList());
    try {
      await _service.delete(item.id);
    } catch (e) {
      if (!mounted) return;
      setState(() => _items = previous);
      showError(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthState>().user;
    return Scaffold(
      appBar: AppBar(
        title: Text('Bonjour ${user?.displayName ?? ''}'),
        actions: [
          IconButton(
            tooltip: 'Profil',
            icon: const Icon(Icons.account_circle),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfilePage()),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(),
        icon: const Icon(Icons.add),
        label: const Text('Ajouter'),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_error != null && _items == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error.toString()),
            const SizedBox(height: 8),
            OutlinedButton(onPressed: _load, child: const Text('Réessayer')),
          ],
        ),
      );
    }
    if (_items == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return RefreshIndicator(
      onRefresh: _load,
      child: _items!.isEmpty
          ? ListView(
              children: const [
                SizedBox(height: 120),
                Icon(Icons.inbox_outlined, size: 64),
                SizedBox(height: 8),
                Center(child: Text('Aucun élément pour l\'instant')),
              ],
            )
          : ListView.separated(
              padding: const EdgeInsets.only(bottom: 88),
              itemCount: _items!.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final item = _items![index];
                return Dismissible(
                  key: ValueKey(item.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 24),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (_) => _delete(item),
                  child: ListTile(
                    leading: Checkbox(
                      value: item.done,
                      onChanged: (_) => _toggle(item),
                    ),
                    title: Text(
                      item.title,
                      style: item.done
                          ? const TextStyle(
                              decoration: TextDecoration.lineThrough,
                            )
                          : null,
                    ),
                    subtitle: item.description.isEmpty
                        ? null
                        : Text(
                            item.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                    onTap: () => _openForm(item),
                  ),
                );
              },
            ),
    );
  }
}
