import 'package:flutter/material.dart';

import '../services/api_service.dart';
import 'login_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, this.api});

  static const route = '/';

  /// Injectable pour les tests.
  final ApiService? api;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final ApiService _api = widget.api ?? ApiService();
  bool? _apiOnline;

  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    setState(() => _apiOnline = null);
    final ok = await _api.checkHealth();
    if (mounted) setState(() => _apiOnline = ok);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Accueil')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Bienvenue sur le projet 7360',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              _ApiStatus(online: _apiOnline, onRetry: _check),
              const SizedBox(height: 32),
              FilledButton(
                onPressed: () => Navigator.pushNamed(context, LoginPage.route),
                child: const Text('Se connecter'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ApiStatus extends StatelessWidget {
  const _ApiStatus({required this.online, required this.onRetry});

  final bool? online;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    if (online == null) {
      return const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox.square(
            dimension: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          SizedBox(width: 8),
          Text('Connexion à l\'API…'),
        ],
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          online! ? Icons.check_circle : Icons.error,
          color: online! ? Colors.green : Colors.red,
        ),
        const SizedBox(width: 8),
        Text(online! ? 'API en ligne' : 'API injoignable'),
        if (!online!)
          TextButton(onPressed: onRetry, child: const Text('Réessayer')),
      ],
    );
  }
}
