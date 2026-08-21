// ═══════════════════════════════════════════════════════════════════
// 6. lib/widgets/endroits_list.dart
// ───────────────────────────────────────────────────────────────────
// Liste déroulante des endroits favoris.
// Reçoit la liste en paramètre et n'a pas de gestion d'état propre :
// StatelessWidget suffit.
// ═══════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import '../modele/endroit.dart';
import '../vue/endroit_detail.dart';

class EndroitsList extends StatelessWidget {
  const EndroitsList({super.key, required this.endroits});

  /// La liste des endroits à afficher,
  /// fournie par le provider Riverpod via l'interface principale.
  final List<Endroit> endroits;

  @override
  Widget build(BuildContext context) {
    // ── CAS 1 : liste vide → message d'accueil centré ──
    if (endroits.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // Centrage vertical
          children: [
            Icon(Icons.map_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Aucun endroit pour le moment.',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            Text(
              'Appuyez sur + pour ajouter un endroit favori !',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    // ── CAS 2 : liste non vide → ListView.builder ──
    // builder construit chaque élément À LA DEMANDE (performance optimale
    // même avec une longue liste : seuls les éléments visibles sont créés).
    return ListView.builder(
      itemCount: endroits.length,
      itemBuilder: (ctx, index) {
        final endroit = endroits[index];
        return ListTile(
          leading: CircleAvatar(
            radius: 26,
            backgroundImage: FileImage(endroit.image), // Vignette de la photo
          ),
          title: Text(
            endroit.nom,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          // Sous-titre : l'adresse si disponible, sinon les coordonnées GPS
          subtitle: Text(
            endroit.adresse ?? 'Localisation non renseignée',
          ),
          // Appui sur un élément → navigation vers la page de détails
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (ctx) => EndroitDetail(endroit: endroit),
              ),
            );
          },
        );
      },
    );
  }
}
