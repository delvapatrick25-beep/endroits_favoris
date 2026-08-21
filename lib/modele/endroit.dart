// ═══════════════════════════════════════════════════════════════════
// 1. lib/modele/endroit.dart
// ───────────────────────────────────────────────────────────────────
// Le modèle de données central de l'application.
// Il représente un endroit favori avec toutes ses informations.
// C'est une classe simple, sans gestion d'état.
// ═══════════════════════════════════════════════════════════════════

import 'dart:io';            // Fournit la classe File pour représenter l'image
import 'package:uuid/uuid.dart'; // Package qui génère des identifiants uniques

// Constante globale — instance unique du générateur d'UUID.
// Déclarée avant la classe pour être utilisée dans le constructeur.
const uuid = Uuid();

class Endroit {
  /// Constructeur de la classe Endroit.
  ///
  /// - `nom` et `image` sont obligatoires (required).
  /// - Les données GPS sont optionnelles (peuvent être nulles).
  /// - L'`id` N'EST PAS passé en paramètre : il est généré automatiquement
  ///   via `uuid.v4()` grâce à la syntaxe d'initialisation Dart
  ///   (le séparateur ":" après la liste de paramètres).
  Endroit({
    required this.nom,
    required this.image,
    this.latitude,
    this.longitude,
    this.adresse,
  }) : id = uuid.v4();

  final String id;        // Identifiant unique généré automatiquement
  final String nom;       // Nom de l'endroit saisi par l'utilisateur
  final File image;       // Photo prise avec la caméra (dart:io)
  final double? latitude; // Coordonnée GPS latitude (optionnelle)
  final double? longitude;// Coordonnée GPS longitude (optionnelle)
  final String? adresse;  // Adresse lisible ex: "Paris, France" (optionnelle)

  /// Constructeur secondaire : recrée un endroit DEPUIS LA BASE DE
  /// DONNÉES. Ici l'id n'est PAS régénéré — on réutilise celui
  /// enregistré, et l'image est reconstruite depuis son chemin.
  Endroit.depuisBase({
    required this.id,
    required this.nom,
    required String cheminImage,
    this.latitude,
    this.longitude,
    this.adresse,
  }) : image = File(cheminImage);

  /// Retourne true si une localisation GPS est disponible.
  /// Utilisé dans la page de détails pour décider d'afficher ou non la carte.
  bool get aLocalisation => latitude != null && longitude != null;
}
