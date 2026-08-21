// ═══════════════════════════════════════════════════════════════════
// 8. lib/vue/endroits_interface.dart
// ───────────────────────────────────────────────────────────────────
// Écran principal : affiche la liste des endroits préférés et le
// bouton d'ajout.
//
// ConsumerWidget suffit : pas d'état local ici, uniquement la
// lecture du provider Riverpod.
// ═══════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/endroits_provider.dart';
import '../widgets/endroits_list.dart';
import 'ajout_endroit.dart';

class EndroitsInterface extends ConsumerWidget {
  const EndroitsInterface({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ref.watch = ÉCOUTE du provider : à chaque ajout/suppression,
    // l'interface est automatiquement reconstruite avec la liste à jour.
    final endroits = ref.watch(endroitsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes endroits préférés'),
        actions: [
          // Bouton "+" dans l'AppBar : ouvre le formulaire d'ajout
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const AjoutEndroit(),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8),
        // La liste reçoit les données issues du provider Riverpod
        child: EndroitsList(endroits: endroits),
      ),
    );
  }
}
