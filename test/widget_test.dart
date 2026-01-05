import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:voucho/main.dart';
import 'package:voucho/providers/app_state.dart';
import 'package:firebase_core/firebase_core.dart';

void main() {
  testWidgets('Vérification de l\'affichage de la page de connexion', (WidgetTester tester) async {
    // On crée une instance de AppState pour le test
    final appState = AppState();

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => appState,
        // Correction ici : on ajoute l'argument startScreen requis
        child: const MyApp(startScreen: '/login'), 
      ),
    );

    // On attend que l'interface se stabilise
    await tester.pumpAndSettle();

    // Vérifie que le MaterialApp est bien présent
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}