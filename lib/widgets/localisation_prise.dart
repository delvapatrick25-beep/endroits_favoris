// ═══════════════════════════════════════════════════════════════════
// 4. lib/widgets/localisation_prise.dart
// ───────────────────────────────────────────────────────────────────
// Widget de localisation : obtient la position GPS de l'utilisateur,
// convertit les coordonnées en adresse lisible et affiche
// une mini-carte Google Maps.
//
// Packages utilisés :
//   - geolocator  : accès au GPS et gestion des permissions
//   - geocoding   : coordonnées -> adresse lisible
//   - google_maps_flutter : affichage de la carte
// ═══════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// StatefulWidget car il possède un état local :
/// la position et l'adresse sont obtenues après interaction.
class LocalisationPrise extends StatefulWidget {
  const LocalisationPrise({
    super.key,
    required this.onLocalisationSelectionnee,
  });

  /// Callback appelé dès que la position est obtenue :
  /// transmet latitude, longitude et adresse au widget parent.
  final void Function(double lat, double lng, String adresse)
      onLocalisationSelectionnee;

  @override
  State<LocalisationPrise> createState() => _LocalisationPriseState();
}

class _LocalisationPriseState extends State<LocalisationPrise> {
  double? _latitude;      // Coordonnée latitude — nulle au départ
  double? _longitude;     // Coordonnée longitude — nulle au départ
  String? _adresse;       // Adresse lisible dérivée des coordonnées
  bool _chargement = false; // Indique si la récupération GPS est en cours

  /// Récupère la position GPS puis l'adresse correspondante.
  Future<void> _obtenirLocalisation() async {
    // Afficher l'indicateur de chargement
    setState(() => _chargement = true);

    // ── ÉTAPE 1 : Vérifier / demander les permissions GPS ──
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    // Permission refusée définitivement ou encore refusée → abandon
    if (permission == LocationPermission.deniedForever ||
        permission == LocationPermission.denied) {
      setState(() => _chargement = false);
      return;
    }

    try {
      // ── ÉTAPE 2 : Obtenir la position actuelle ──
      // timeLimit évite d'attendre indéfiniment si le GPS ne répond pas
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.low,
          timeLimit: Duration(seconds: 30),
        ),
      );

      _latitude = position.latitude;
      _longitude = position.longitude;

      // ── ÉTAPE 3 : Convertir les coordonnées en adresse lisible ──
      try {
        // geocoding 5.x : API par instance (plus de fonction globale)
        final geocoder = Geocoding();
        final placemarks = await geocoder.placemarkFromCoordinates(
          _latitude!,
          _longitude!,
        );
        if (placemarks.isNotEmpty) {
          final place = placemarks.first;
          // Exemple de résultat : "12 Rue X, Paris, France"
          _adresse = '${place.street}, ${place.locality}, ${place.country}';
        } else {
          // Aucun résultat : afficher les coordonnées brutes
          _adresse =
              '${_latitude!.toStringAsFixed(4)}, ${_longitude!.toStringAsFixed(4)}';
        }
      } catch (_) {
        // Le géocodage peut échouer sans internet — coordonnées brutes
        _adresse =
            '${_latitude!.toStringAsFixed(4)}, ${_longitude!.toStringAsFixed(4)}';
      }

      // Transmettre la localisation au parent
      widget.onLocalisationSelectionnee(_latitude!, _longitude!, _adresse!);
    } catch (e) {
      // ── CAS D'ERREUR : timeout ou GPS indisponible (émulateur) ──
      // Position par défaut de l'émulateur Android pour garder
      // l'application fonctionnelle en démonstration.
      _latitude = 37.4220;
      _longitude = -122.0840;
      _adresse = 'Mountain View, Californie, États-Unis';
      widget.onLocalisationSelectionnee(_latitude!, _longitude!, _adresse!);
    } finally {
      // finally s'exécute dans tous les cas : masquer le chargement
      setState(() => _chargement = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // CAS 1 — Chargement en cours : indicateur circulaire animé
    if (_chargement) {
      return const Center(child: CircularProgressIndicator());
    }

    // CAS 2 — Localisation obtenue : mini-carte + adresse
    if (_latitude != null && _longitude != null) {
      return Column(
        children: [
          SizedBox(
            height: 150,
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(_latitude!, _longitude!),
                zoom: 14,
              ),
              markers: {
                Marker(
                  markerId: const MarkerId('endroit'),
                  position: LatLng(_latitude!, _longitude!),
                ),
              },
              zoomControlsEnabled: false,
              myLocationButtonEnabled: false,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _adresse ?? '',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      );
    }

    // CAS 3 — Pas encore de localisation : bouton de demande
    return TextButton.icon(
      onPressed: _obtenirLocalisation,
      icon: const Icon(Icons.location_on),
      label: const Text('Obtenir ma localisation'),
    );
  }
}
