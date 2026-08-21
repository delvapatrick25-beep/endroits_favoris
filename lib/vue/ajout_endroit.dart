// ═══════════════════════════════════════════════════════════════════
// 7. lib/vue/ajout_endroit.dart
// ───────────────────────────────────────────────────────────────────
// Formulaire complet d'ajout d'un endroit :
//   - champ de saisie du nom
//   - widget caméra (ImagePrise)
//   - widget localisation GPS (LocalisationPrise)
//   - bouton d'enregistrement
//
// ConsumerStatefulWidget : combine un ÉTAT LOCAL (les champs du
// formulaire) ET l'accès aux providers Riverpod (via ref).
// ═══════════════════════════════════════════════════════════════════

import 'dart:io'; // Fournit la classe File

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/endroits_provider.dart';
import '../widgets/image_prise.dart';
import '../widgets/localisation_prise.dart';

class AjoutEndroit extends ConsumerStatefulWidget {
  const AjoutEndroit({super.key});

  @override
  ConsumerState<AjoutEndroit> createState() => _AjoutEndroitState();
}

class _AjoutEndroitState extends ConsumerState<AjoutEndroit> {
  // Contrôle le champ de saisie du nom (lire / écouter le texte saisi)
  final _nomController = TextEditingController();

  File? _imageSelectionnee; // Photo reçue depuis le widget ImagePrise
  double? _latitude;        // Coordonnées reçues depuis LocalisationPrise
  double? _longitude;
  String? _adresse;

  @override
  void dispose() {
    // LIBÉRER le controller pour éviter les fuites mémoire
    _nomController.dispose();
    super.dispose();
  }

  /// Callback passé à ImagePrise : appelé quand une photo est prise.
  void _surPhotoSelectionnee(File image) {
    setState(() => _imageSelectionnee = image);
  }

  /// Callback passé à LocalisationPrise : appelé quand la position
  /// est obtenue. Stocke coordonnées et adresse dans l'état local.
  void _surLocalisationSelectionnee(double lat, double lng, String adresse) {
    setState(() {
      _latitude = lat;
      _longitude = lng;
      _adresse = adresse;
    });
  }

  /// Validation puis enregistrement de l'endroit.
  void _enregistrerEndroit() {
    final nom = _nomController.text.trim(); // trim retire les espaces

    // VALIDATION 1 : le nom est obligatoire
    if (nom.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez saisir un nom.')),
      );
      return; // On stoppe ici : pas d'enregistrement
    }

    // VALIDATION 2 : la photo est obligatoire
    if (_imageSelectionnee == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez prendre une photo.')),
      );
      return;
    }

    // Riverpod v2 : ref.read + .notifier pour APPELER une méthode du Notifier
    // (ref.read = lecture ponctuelle, sans écoute → idéal pour une action)
    ref.read(endroitsProvider.notifier).ajouterEndroit(
          nom: nom,
          image: _imageSelectionnee!,
          latitude: _latitude,
          longitude: _longitude,
          adresse: _adresse,
        );

    // Fermer la page et revenir à la liste (mise à jour automatique
    // grâce au ref.watch présent dans EndroitsInterface)
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Ajout d'un nouvel endroit")),
      // SingleChildScrollView : permet le défilement si le clavier
      // ou le contenu dépasse la hauteur de l'écran
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Champ de saisie du nom ──
            TextField(
              controller: _nomController,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: "Nom de l'endroit",
                prefixIcon: Icon(Icons.title),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
                hintText: 'Ex: Ma plage préférée',
              ),
              textCapitalization: TextCapitalization.sentences,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 24),

            // ── Section photo ──
            Row(
              children: [
                const Icon(Icons.image, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Photo de l\'endroit',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ImagePrise(onPhotoSelectionnee: _surPhotoSelectionnee),
            const SizedBox(height: 24),

            // ── Section localisation GPS ──
            Row(
              children: [
                const Icon(Icons.location_on, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Localisation',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            LocalisationPrise(
              onLocalisationSelectionnee: _surLocalisationSelectionnee,
            ),
            const SizedBox(height: 32),

            // ── Bouton d'enregistrement ──
            SizedBox(
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _enregistrerEndroit,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.save),
                label: const Text(
                  "Enregistrer l'endroit",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
