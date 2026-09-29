import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'pages/home_page.dart';
import 'pages/login_page.dart';
import 'services/api_client.dart';
import 'services/auth_service.dart';
import 'services/item_service.dart';
import 'services/token_storage.dart';
import 'state/auth_state.dart';

void main() {
  final api = ApiClient();
  final auth = AuthService(api);
  runApp(
    App(
      authService: auth,
      itemService: ItemService(api),
      authState: AuthState(api: api, auth: auth, storage: TokenStorage())
        ..restore(),
    ),
  );
}

class App extends StatelessWidget {
  const App({
    super.key,
    required this.authService,
    required this.itemService,
    required this.authState,
  });

  final AuthService authService;
  final ItemService itemService;
  final AuthState authState;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider.value(value: authService),
        Provider.value(value: itemService),
        ChangeNotifierProvider.value(value: authState),
      ],
      child: MaterialApp(
        title: 'Projet 7360',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
          useMaterial3: true,
        ),
        darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.indigo,
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
        ),
        home: const AuthGate(),
      ),
    );
  }
}

/// Affiche l'écran adapté selon l'état de connexion.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final status = context.select<AuthState, AuthStatus>((s) => s.status);
    return switch (status) {
      AuthStatus.unknown => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      AuthStatus.authenticated => const HomePage(),
      AuthStatus.unauthenticated => const LoginPage(),
    };
  }
}
