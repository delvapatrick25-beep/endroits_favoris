// Test de base de l'application Endroits Favoris.
// Vérifie que l'écran principal s'affiche correctement au démarrage.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:endroits_favoris/main.dart';

void main() {
  testWidgets(
    "L'écran principal affiche le titre et l'état vide",
    (WidgetTester tester) async {
      // Construit l'application dans un ProviderScope
      // (obligatoire pour Riverpod) et déclenche une frame.
      await tester.pumpWidget(
        const ProviderScope(child: MonApplication()),
      );

      // Le titre de l'AppBar est présent.
      expect(find.text('Mes endroits préférés'), findsOneWidget);

      // La liste est vide : message d'accueil affiché.
      expect(find.text('Aucun endroit pour le moment.'), findsOneWidget);
    },
  );
}
