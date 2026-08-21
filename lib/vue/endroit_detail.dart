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
          // ── Photo avec coins arrondis et ombre légère ──
          Stack(
            children: [
              Container(
                height: 300,
                width: double.infinity,
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                  child: Image.file(
                    endroit.image,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // ── Nom de l'endroit ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              endroit.nom,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
          ),

          // ── Adresse dans une carte élégante ──
          if (endroit.adresse != null) ...[
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Card(
                elevation: 0,
                color: Theme.of(context).colorScheme.secondaryContainer.withValues(alpha: 0.4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.location_on, size: 20),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          endroit.adresse!,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ),
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
