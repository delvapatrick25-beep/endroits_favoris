// ═══════════════════════════════════════════════════════════════════
// 3. lib/widgets/image_prise.dart
// ───────────────────────────────────────────────────────────────────
// Widget caméra : permet à l'utilisateur de prendre une photo.
// Il affiche soit un bouton de prise de photo,
// soit l'aperçu de la photo capturée.
// ═══════════════════════════════════════════════════════════════════

import 'dart:io'; // Fournit la classe File pour manipuler l'image

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

/// StatefulWidget car il possède un état local :
/// la photo capturée change au fil des interactions.
class ImagePrise extends StatefulWidget {
  const ImagePrise({super.key, required this.onPhotoSelectionnee});

  /// Callback : fonction de rappel appelée dès qu'une photo est prise,
  /// pour transmettre le fichier image au widget parent
  /// (le formulaire AjoutEndroit).
  final void Function(File image) onPhotoSelectionnee;

  @override
  State<ImagePrise> createState() => _ImagePriseState();
}

class _ImagePriseState extends State<ImagePrise> {
  /// Photo capturée — nulle au départ car aucune photo n'a encore été prise.
  File? _photoSelectionnee;

  /// Méthode ASYNCHRONE qui ouvre la caméra via ImagePicker.
  /// "async/await" : on attend le résultat sans bloquer l'interface.
  Future<void> _prendrePhoto() async {
    final imagePicker = ImagePicker();

    // Ouvre la caméra ; maxWidth réduit la taille de l'image (économie mémoire)
    final photoPrise = await imagePicker.pickImage(
      source: ImageSource.camera,
      maxWidth: 600,
    );

    // Si photoPrise est null → l'utilisateur a annulé, on quitte sans rien faire
    if (photoPrise == null) return;

    // setState() notifie Flutter que l'état a changé → rebuild du widget
    setState(() {
      // Le XFile retourné par image_picker est converti en File (dart:io)
      _photoSelectionnee = File(photoPrise.path);
    });

    // Transmettre la photo au widget parent via le callback
    widget.onPhotoSelectionnee(_photoSelectionnee!);
  }

  @override
  Widget build(BuildContext context) {
    // CAS 1 — Aucune photo : afficher le bouton de prise de photo
    if (_photoSelectionnee == null) {
      return TextButton.icon(
        onPressed: _prendrePhoto,
        icon: const Icon(Icons.camera_alt),
        label: const Text('Prendre une photo'),
      );
    }

    // CAS 2 — Photo disponible : afficher un aperçu cliquable.
    // GestureDetector permet d'appuyer sur l'image pour reprendre une photo.
    return GestureDetector(
      onTap: _prendrePhoto,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8), // Coins arrondis
        child: Image.file(
          _photoSelectionnee!, // "!" : on garantit que ce n'est pas null ici
          width: double.infinity,
          height: 200,
          fit: BoxFit.cover, // Remplit l'espace en recadrant proprement
        ),
      ),
    );
  }
}
