// ═══════════════════════════════════════════════════════════════════
// lib/providers/endroits_provider.dart
// ───────────────────────────────────────────────────────────────────
// Contient deux éléments :
//   1. EndroitsNotifier : gère l'état de la liste des endroits
//   2. endroitsProvider : expose cette liste à toute l'application
//
// Syntaxe Riverpod v2 : Notifier et NotifierProvider remplacent
// les anciens StateNotifier et StateNotifierProvider (dépréciés).
//
// PERSISTANCE : chaque modification de l'état est synchronisée
// avec la base SQLite (voir services/base_donnees.dart) :
//   - au démarrage  -> chargement des endroits enregistrés
//   - ajout         -> insertion en base + copie image permanente
//   - suppression   -> retrait en base + suppression du fichier
// ═══════════════════════════════════════════════════════════════════

import 'dart:io'; // Fournit la classe File pour le paramètre image

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../modele/endroit.dart';
import '../services/base_donnees.dart';

/// Classe qui gère l'état global : une liste d'objets Endroit.
///
/// Elle étend `Notifier<List<Endroit>>` : Riverpod lui confie la
/// responsabilité de détenir et modifier la liste.
class EndroitsNotifier extends Notifier<List<Endroit>> {
  /// Méthode OBLIGATOIRE imposée par Riverpod v2.
  /// Elle remplace le constructeur et retourne l'état initial :
  /// ici, une liste vide [] affichée immédiatement, pendant que les
  /// endroits sauvegardés sont chargés en arrière-plan depuis SQLite.
  @override
  List<Endroit> build() {
    _chargerDepuisBase(); // Appel asynchrone sans "await" volontaire
    return [];
  }

  /// Charge les endroits persistés puis met à jour l'état :
  /// tous les widgets qui écoutent le provider se reconstruisent.
  Future<void> _chargerDepuisBase() async {
    try {
      final endroits = await BaseDonneesService.instance.recupererTous();
      state = endroits;
    } catch (_) {
      // Base indisponible au premier lancement -> on garde []
    }
  }

  /// Ajoute un nouvel endroit EN TÊTE de liste ET le persiste.
  ///
  /// On ne fait jamais state.add() : on réaffecte un NOUVEAU tableau
  /// avec le spread operator (...state). C'est ce qui permet à
  /// Riverpod de détecter le changement et de reconstruire l'interface.
  Future<void> ajouterEndroit({
    required String nom,
    required File image,
    double? latitude,
    double? longitude,
    String? adresse,
  }) async {
    // IMPORTANT : copier la photo vers un stockage PERMANENT.
    // Le fichier fourni par image_picker est temporaire et peut être
    // supprimé par le système à tout moment !
    final cheminPermanent =
        await BaseDonneesService.instance.enregistrerImagePermanente(
      image.path,
    );

    // Création du nouvel objet Endroit avec l'image permanente
    final nouvelEndroit = Endroit(
      nom: nom,
      image: File(cheminPermanent),
      latitude: latitude,
      longitude: longitude,
      adresse: adresse,
    );

    // [nouvelEndroit, ...state] = nouveau tableau commençant par le
    // nouvel endroit, suivi de tous les anciens endroits.
    state = [nouvelEndroit, ...state];

    // Persistance dans la base SQLite
    await BaseDonneesService.instance.insererEndroit(nouvelEndroit);
  }

  /// Supprime l'endroit dont l'id correspond (état + base + fichier).
  void supprimerEndroit(String id) {
    // Retrouver l'endroit AVANT retrait pour nettoyer sa photo
    final cible = state.where((endroit) => endroit.id == id).firstOrNull;

    // where() filtre la liste en gardant tous les éléments SAUF celui
    // dont l'id correspond, puis on réaffecte state.
    state = state.where((endroit) => endroit.id != id).toList();

    // Nettoyage asynchrone : ligne SQLite + fichier image sur disque
    () async {
      await BaseDonneesService.instance.supprimerEndroit(id);
      if (cible != null) {
        await BaseDonneesService.instance.supprimerFichier(cible.image.path);
      }
    }();
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
