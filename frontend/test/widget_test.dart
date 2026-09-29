import 'package:app_7360/main.dart';
import 'package:app_7360/services/api_client.dart';
import 'package:app_7360/services/auth_service.dart';
import 'package:app_7360/services/item_service.dart';
import 'package:app_7360/services/token_storage.dart';
import 'package:app_7360/state/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fake_backend.dart';

late FakeBackend backend;

Future<void> pumpApp(WidgetTester tester) async {
  final api = ApiClient(client: backend.client);
  final auth = AuthService(api);
  final state = AuthState(api: api, auth: auth, storage: TokenStorage());
  await tester.pumpWidget(
    App(authService: auth, itemService: ItemService(api), authState: state),
  );
  await state.restore();
  await tester.pumpAndSettle();
}

Future<void> login(WidgetTester tester) async {
  await tester.enterText(find.widgetWithText(TextFormField, 'Email'), 'a@b.fr');
  await tester.enterText(
    find.widgetWithText(TextFormField, 'Mot de passe'),
    'password123',
  );
  await tester.tap(find.widgetWithText(FilledButton, 'Se connecter'));
  await tester.pumpAndSettle();
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    backend = FakeBackend()
      ..users['a@b.fr'] = {
        'id': 1,
        'email': 'a@b.fr',
        'full_name': 'Alice',
        'created_at': '2026-01-01T00:00:00Z',
      }
      ..passwords['a@b.fr'] = 'password123';
  });

  testWidgets('sans token : affiche la page de connexion', (tester) async {
    await pumpApp(tester);
    expect(find.text('Connexion'), findsOneWidget);
  });

  testWidgets('formulaire de connexion validé', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.widgetWithText(FilledButton, 'Se connecter'));
    await tester.pump();
    expect(find.text('Email invalide'), findsOneWidget);
    expect(find.text('8 caractères minimum'), findsOneWidget);
  });

  testWidgets('mauvais mot de passe : message d\'erreur', (tester) async {
    await pumpApp(tester);
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Email'),
      'a@b.fr',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Mot de passe'),
      'mauvais123',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Se connecter'));
    await tester.pumpAndSettle();
    expect(find.text('Email ou mot de passe incorrect'), findsOneWidget);
  });

  testWidgets('API hors ligne : indicateur affiché', (tester) async {
    backend.online = false;
    await pumpApp(tester);
    expect(find.text('API injoignable'), findsOneWidget);
  });

  testWidgets('connexion puis création / cochage d\'un item', (tester) async {
    await pumpApp(tester);
    await login(tester);
    expect(find.text('Bonjour Alice'), findsOneWidget);
    expect(find.text('Aucun élément pour l\'instant'), findsOneWidget);

    await tester.tap(find.text('Ajouter'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Titre'),
      'Acheter du pain',
    );
    await tester.tap(find.text('Enregistrer'));
    await tester.pumpAndSettle();
    expect(find.text('Acheter du pain'), findsOneWidget);

    await tester.tap(find.byType(Checkbox));
    await tester.pumpAndSettle();
    expect(backend.items.single['done'], isTrue);
  });

  testWidgets('session restaurée au redémarrage', (tester) async {
    SharedPreferences.setMockInitialValues({'access_token': 'fake-token'});
    await pumpApp(tester);
    expect(find.text('Bonjour Alice'), findsOneWidget);
  });

  testWidgets('inscription connecte directement', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.text('Pas de compte ? Créer un compte'));
    await tester.pumpAndSettle();
    backend.users.clear(); // le faux backend ne gère qu'un utilisateur
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Nom complet'),
      'Bob',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Email'),
      'bob@b.fr',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Mot de passe'),
      'password123',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Confirmer le mot de passe'),
      'password123',
    );
    await tester.tap(find.text('Créer mon compte'));
    await tester.pumpAndSettle();
    expect(find.text('Bonjour Bob'), findsOneWidget);
  });

  testWidgets('déconnexion depuis le profil', (tester) async {
    await pumpApp(tester);
    await login(tester);
    await tester.tap(find.byTooltip('Profil'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Se déconnecter'));
    await tester.tap(find.text('Se déconnecter'));
    await tester.pumpAndSettle();
    expect(find.text('Connexion'), findsOneWidget);
  });
}
