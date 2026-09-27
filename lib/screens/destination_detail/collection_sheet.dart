import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../providers/favorites_provider.dart';

/// Adds or removes [destinationId] from the traveller's collections.
Future<void> showSaveToCollectionSheet(
  BuildContext context,
  String destinationId,
  FavoritesProvider favoritesProvider,
) async {
  final controller = TextEditingController();

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) {
      final t = AppLocalizations.of(context);
      final collectionNames = favoritesProvider.collectionNames;

      return Padding(
        padding: EdgeInsets.fromLTRB(
          16,
          4,
          16,
          MediaQuery.of(context).viewInsets.bottom + 12,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              t.translate('saveToCollectionsTitle'),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (collectionNames.isEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text(t.translate('noCollectionsYet')),
              )
            else
              ...collectionNames.map(
                (name) {
                  final selected = favoritesProvider
                      .collectionsForDestination(destinationId)
                      .contains(name);
                  return CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    value: selected,
                    title: Text(name),
                    onChanged: (value) async {
                      if (value == true) {
                        await favoritesProvider.addToCollection(name, destinationId);
                      } else {
                        await favoritesProvider.removeFromCollection(name, destinationId);
                      }
                    },
                  );
                },
              ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      hintText: t.translate('newCollectionName'),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () async {
                    final name = controller.text.trim();
                    if (name.isEmpty) return;
                    await favoritesProvider.createCollection(name);
                    await favoritesProvider.addToCollection(name, destinationId);
                    if (context.mounted) {
                      Navigator.pop(context);
                    }
                  },
                  child: Text(t.translate('create')),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
        ),
      );
    },
  );
}
