// ═══════════════════════════════════════════════════════════════════
// lib/services/base_donnees.dart
// ───────────────────────────────────────────────────────────────────
// Service de persistance locale (SQLite via le package sqflite).
//
// Rôle : conserver les endroits après la fermeture de l'application.
// Il gère :
//   - l'ouverture / création de la base de données
//   - les opérations CRUD (lire, insérer, supprimer)
//   - la copie des photos vers un stockage PERMANENT
//     (les fichiers d'image_picker sont temporaires et peuvent
//      être effacés par le système !)
// ═══════════════════════════════════════════════════════════════════

import 'dart:io';

import 'package:path/path.dart' as p; // Utilitaires de chemins de fichiers
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../modele/endroit.dart';

class BaseDonneesService {
  // ── SINGLETON : une seule instance pour toute l'application ──
  BaseDonneesService._interne();
  static final BaseDonneesService instance = BaseDonneesService._interne();

  static const _nomBase = 'endroits_favoris.db';
  Database? _base;

  /// Ouvre la base paresseusement (à la première utilisation)
  /// puis réutilise la connexion ouverte.
  Future<Database> get base async {
    _base ??= await _ouvrirBase();
    return _base!;
  }

  Future<Database> _ouvrirBase() async {
    // Emplacement standard des bases sur Android
    final dossier = await getDatabasesPath();

    return openDatabase(
      p.join(dossier, _nomBase),
      version: 1,
      // Exécuté UNIQUEMENT si la base n'existe pas encore
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE endroits(
            id TEXT PRIMARY KEY,
            nom TEXT NOT NULL,
            image TEXT NOT NULL,
            latitude REAL,
            longitude REAL,
            adresse TEXT
          )
        ''');
      },
    );
  }

  // ═══════════════════════════════════════════
  // IMAGES : copie vers stockage permanent
  // ═══════════════════════════════════════════

  /// Copie une photo temporaire (image_picker) vers le dossier
  /// documents de l'application. Retourne le nouveau chemin.
  Future<String> enregistrerImagePermanente(String cheminTemporaire) async {
    final documents = await getApplicationDocumentsDirectory();
    final nouveauChemin = p.join(documents.path, p.basename(cheminTemporaire));
    await File(cheminTemporaire).copy(nouveauChemin);
    return nouveauChemin;
  }

  /// Supprime un fichier image du stockage (best effort).
  Future<void> supprimerFichier(String? chemin) async {
    try {
      if (chemin != null && await File(chemin).exists()) {
        await File(chemin).delete();
      }
    } catch (_) {
      // Échec non bloquant : la suppression continue
    }
  }

  // ═══════════════════════════════════════════
  // CRUD : Create / Read / Delete
  // ═══════════════════════════════════════════

  /// Charge tous les endroits enregistrés (le plus récent en premier).
  Future<List<Endroit>> recupererTous() async {
    final db = await base;
    final lignes = await db.query('endroits', orderBy: 'rowid DESC');

    // Reconstituer les objets Endroit ; ignorer ceux dont la photo
    // a disparu du stockage (fichier nettoyé par le système)
    final endroits = <Endroit>[];
    for (final ligne in lignes) {
      if (await File(ligne['image'] as String).exists()) {
        endroits.add(
          Endroit.depuisBase(
            id: ligne['id'] as String,
            nom: ligne['nom'] as String,
            cheminImage: ligne['image'] as String,
            latitude: ligne['latitude'] as double?,
            longitude: ligne['longitude'] as double?,
            adresse: ligne['adresse'] as String?,
          ),
        );
      }
    }
    return endroits;
  }

  /// Insère un nouvel endroit dans la base.
  Future<void> insererEndroit(Endroit endroit) async {
    final db = await base;
    await db.insert('endroits', {
      'id': endroit.id,
      'nom': endroit.nom,
      'image': endroit.image.path,
      'latitude': endroit.latitude,
      'longitude': endroit.longitude,
      'adresse': endroit.adresse,
    });
  }

  /// Supprime un endroit de la base par son identifiant.
  Future<void> supprimerEndroit(String id) async {
    final db = await base;
    await db.delete('endroits', where: 'id = ?', whereArgs: [id]);
  }
}
