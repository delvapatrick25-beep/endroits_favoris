// ═══════════════════════════════════════════════════════════════════
// 5. lib/vue/endroit_detail.dart
// ───────────────────────────────────────────────────────────────────
// Page de détails : affiche les informations complètes d'un endroit :
// sa photo, son nom, son adresse et sa localisation sur une carte
// Google Maps.
// StatelessWidget suffit : aucune donnée ne change sur cette page.
// ═══════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../modele/endroit.dart';

class EndroitDetail extends StatelessWidget {
  const EndroitDetail({super.key, required this.endroit});

  /// L'endroit dont on affiche les détails,
  /// transmis par la liste au moment de la navigation.
  final Endroit endroit;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Le nom de l'endroit sert de titre dans l'AppBar
      appBar: AppBar(title: Text(endroit.nom)),
      body: Column(
        children: [
          // ── Photo en pleine largeur (hauteur fixe 250 pixels) ──
          Image.file(
            endroit.image,
            width: double.infinity,
            height: 250,
            fit: BoxFit.cover,
          ),
          const SizedBox(height: 16),

          // ── Nom de l'endroit sous la photo ──
          Text(
            endroit.nom,
            style: Theme.of(context).textTheme.headlineSmall,
          ),

          // ── Adresse affichée UNIQUEMENT si elle n'est pas nulle ──
          // La collection "..." permet d'insérer plusieurs widgets
          // de manière conditionnelle dans une Column.
          if (endroit.adresse != null) ...[
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                endroit.adresse!, // "!" garantit la non-nullité ici
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],

          // ── Carte Google Maps UNIQUEMENT si localisation disponible ──
          // Le getter aLocalisation du modèle décide de l'affichage.
          if (endroit.aLocalisation) ...[
            const SizedBox(height: 16),
            // Expanded : la carte occupe tout l'espace restant à l'écran
            Expanded(
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: LatLng(endroit.latitude!, endroit.longitude!),
                  zoom: 14, // Niveau de zoom initial de la caméra
                ),
                markers: {
                  Marker(
                    markerId: const MarkerId('endroit'),
                    position: LatLng(endroit.latitude!, endroit.longitude!),
                    infoWindow: InfoWindow(title: endroit.nom),
                  ),
                },
                zoomControlsEnabled: true,
                myLocationButtonEnabled: false,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
