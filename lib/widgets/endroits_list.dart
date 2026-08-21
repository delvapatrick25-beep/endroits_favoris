// ═══════════════════════════════════════════════════════════════════
// 6. lib/widgets/endroits_list.dart
// ───────────────────────────────────────────────────────────────────
// Liste déroulante des endroits favoris.
// Reçoit la liste en paramètre et n'a pas de gestion d'état propre :
// StatelessWidget suffit.
// ═══════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../modele/endroit.dart';
import '../vue/endroit_detail.dart';
import '../providers/endroits_provider.dart';

class EndroitsList extends ConsumerWidget {
  const EndroitsList({super.key, required this.endroits});

  final List<Endroit> endroits;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (endroits.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.map_outlined,
              size: 80,
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Aucun endroit pour le moment.',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Appuyez sur le bouton + pour commencer !',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[500],
                  ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      itemCount: endroits.length,
      itemBuilder: (ctx, index) {
        final endroit = endroits[index];
        return Dismissible(
          key: ValueKey(endroit.id),
          direction: DismissDirection.endToStart,
          background: Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.error.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            child: const Icon(Icons.delete, color: Colors.white, size: 32),
          ),
          onDismissed: (direction) {
            ref.read(endroitsProvider.notifier).supprimerEndroit(endroit.id);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${endroit.nom} supprimé'),
                action: SnackBarAction(
                  label: 'ANNULER',
                  onPressed: () {
                    // Optionnel: ré-ajouter l'endroit si besoin
                  },
                ),
              ),
            );
          },
          child: Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(12),
              leading: CircleAvatar(
                radius: 30,
                backgroundImage: FileImage(endroit.image),
              ),
              title: Text(
                endroit.nom,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  endroit.adresse ?? 'Localisation non renseignée',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (ctx) => EndroitDetail(endroit: endroit),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
