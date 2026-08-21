// ═══════════════════════════════════════════════════════════════════
// 9. lib/main.dart
// ───────────────────────────────────────────────────────────────────
// Point d'entrée de l'application.
// ProviderScope est OBLIGATOIRE pour que Riverpod fonctionne :
// il initialise le système de providers et le rend accessible
// à toute l'application.
// ═══════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'vue/endroits_interface.dart';

void main() {
  runApp(
    // ProviderScope obligatoire pour Riverpod : sans lui,
    // ref.watch / ref.read lèveront une erreur à l'exécution.
    const ProviderScope(
      child: MonApplication(),
    ),
  );
}

/// Racine de l'application : configure le MaterialApp (thème, page d'accueil).
class MonApplication extends StatelessWidget {
  const MonApplication({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Endroits Favoris',
      debugShowCheckedModeBanner: false, // Masque le bandeau "debug"
      theme: ThemeData(
        colorSchemeSeed: Colors.teal, // Couleur de base du thème
        useMaterial3: true, // Active le design Material 3
      ),
      home: const EndroitsInterface(), // Première page affichée
    );
  }
}
