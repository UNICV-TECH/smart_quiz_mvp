// Teste básico para verificar se o aplicativo inicia corretamente
// com a SplashScreen como tela inicial.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:unicv_tech_mvp/main.dart';

void main() {
  testWidgets('App starts with SplashScreen and navigates to WelcomeScreen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that we can find the logo image in splash screen
    expect(find.byType(Image), findsOneWidget);

    // Wait for the splash screen duration (2.5 seconds) plus animation time
    await tester.pumpAndSettle(const Duration(seconds: 3));

    // After navigation, should be on welcome screen
    // Verify that welcome screen elements are present
    expect(find.text('Bem vindo'), findsOneWidget);
    expect(find.text('Prepare-se para se divertir aprendendo!'), findsOneWidget);
    expect(find.text('Entrar'), findsOneWidget);
  });
}
