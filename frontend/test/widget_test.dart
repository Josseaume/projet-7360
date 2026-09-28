import 'package:app_7360/main.dart';
import 'package:app_7360/pages/home_page.dart';
import 'package:app_7360/pages/login_page.dart';
import 'package:app_7360/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeApi extends ApiService {
  _FakeApi(this.online);
  final bool online;

  @override
  Future<bool> checkHealth() async => online;
}

void main() {
  testWidgets('Accueil affiche le statut API', (tester) async {
    await tester.pumpWidget(MaterialApp(home: HomePage(api: _FakeApi(true))));
    await tester.pumpAndSettle();
    expect(find.text('API en ligne'), findsOneWidget);
  });

  testWidgets('Accueil affiche une erreur si API hors ligne', (tester) async {
    await tester.pumpWidget(MaterialApp(home: HomePage(api: _FakeApi(false))));
    await tester.pumpAndSettle();
    expect(find.text('API injoignable'), findsOneWidget);
  });

  testWidgets('Login valide le formulaire', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: LoginPage()));
    await tester.tap(find.widgetWithText(FilledButton, 'Se connecter'));
    await tester.pump();
    expect(find.text('Email invalide'), findsOneWidget);
    expect(find.text('8 caractères minimum'), findsOneWidget);
  });

  test('App se construit', () {
    expect(const App(), isA<StatelessWidget>());
  });
}
