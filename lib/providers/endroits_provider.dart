// ═══════════════════════════════════════════════════════════════════
// 2. lib/providers/endroits_provider.dart
// ───────────────────────────────────────────────────────────────────
// Contient deux éléments :
//   1. EndroitsNotifier : gère l'état de la liste des endroits
//   2. endroitsProvider : expose cette liste à toute l'application
//
// Syntaxe Riverpod v2 : Notifier et NotifierProvider remplacent
// les anciens StateNotifier et StateNotifierProvider (dépréciés).
// ═══════════════════════════════════════════════════════════════════

import 'dart:io'; // Fournit la classe File pour le paramètre image

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../modele/endroit.dart';

/// Classe qui gère l'état global : une liste d'objets Endroit.
///
/// Elle étend `Notifier<List<Endroit>>` : Riverpod lui confie la
/// responsabilité de détenir et modifier la liste.
class EndroitsNotifier extends Notifier<List<Endroit>> {
  /// Méthode OBLIGATOIRE imposée par Riverpod v2.
  /// Elle remplace le constructeur et retourne l'état initial :
  /// ici, une liste vide [] au démarrage de l'application.
  @override
  List<Endroit> build() => [];

  /// Ajoute un nouvel endroit EN TÊTE de liste.
  ///
  /// On ne fait jamais state.add() : on réaffecte un NOUVEAU tableau
  /// avec le spread operator (...state). C'est ce qui permet à
  /// Riverpod de détecter le changement et de reconstruire l'interface.
  void ajouterEndroit({
    required String nom,
    required File image,
    double? latitude,
    double? longitude,
    String? adresse,
  }) {
    // Création du nouvel objet Endroit (l'id est généré automatiquement)
    final nouvelEndroit = Endroit(
      nom: nom,
      image: image,
      latitude: latitude,
      longitude: longitude,
      adresse: adresse,
    );

    // [nouvelEndroit, ...state] = nouveau tableau commençant par le
    // nouvel endroit, suivi de tous les anciens endroits.
    state = [nouvelEndroit, ...state];
  }

  /// Supprime l'endroit dont l'id correspond.
  ///
  /// where() filtre la liste en gardant tous les éléments SAUF celui
  /// dont l'id correspond, puis on réaffecte state.
  void supprimerEndroit(String id) {
    state = state.where((endroit) => endroit.id != id).toList();
  }
}

/// Provider GLOBAL accessible depuis n'importe quel widget de l'app.
///
/// `NotifierProvider<EndroitsNotifier, List<Endroit>>` précise :
///   - le type du Notifier qui gère l'état
///   - le type de l'état exposé (`List<Endroit>`)
/// EndroitsNotifier.new est la référence au constructeur : Riverpod
/// crée l'instance automatiquement.
final endroitsProvider =
    NotifierProvider<EndroitsNotifier, List<Endroit>>(
  EndroitsNotifier.new,
);
