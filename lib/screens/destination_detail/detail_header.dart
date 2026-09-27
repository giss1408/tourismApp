import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../models/destination_model.dart';
import '../../providers/favorites_provider.dart';
import '../../utils/money.dart';
import '../../widgets/booking_dialog.dart';
import 'collection_sheet.dart';
import 'info_request_sheet.dart';

/// Name, location and rating.
class DetailTitleRow extends StatelessWidget {
  final Destination destination;

  const DetailTitleRow({super.key, required this.destination});

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).hintColor;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(destination.name,
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.location_on, color: muted, size: 16),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(destination.location,
                        style: TextStyle(fontSize: 16, color: muted)),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (destination.rating > 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 20),
                const SizedBox(width: 4),
                Text(destination.rating.toStringAsFixed(1),
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
      ],
    );
  }
}

/// Favourite and collection shortcuts.
class DetailActionChips extends StatelessWidget {
  final Destination destination;

  const DetailActionChips({super.key, required this.destination});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final favorites = context.watch<FavoritesProvider>();
    final isFavorite = favorites.isFavorite(destination.id);
    final collections = favorites.collectionsForDestination(destination.id);
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        ActionChip(
          avatar: Icon(isFavorite ? Icons.favorite : Icons.favorite_border,
              size: 18, color: isFavorite ? Colors.red : null),
          label: Text(t.translate(isFavorite ? 'favorited' : 'addFavorite')),
          onPressed: () => favorites.toggleFavorite(destination.id),
        ),
        ActionChip(
          avatar: const Icon(Icons.collections_bookmark, size: 18),
          label: Text(collections.isEmpty
              ? t.translate('saveToCollection')
              : t.translate('collectionsCount')
                  .replaceAll('{count}', '${collections.length}')),
          onPressed: () =>
              showSaveToCollectionSheet(context, destination.id, favorites),
        ),
      ],
    );
  }
}

Future<void> showBookingDialog(BuildContext context, Destination destination) =>
    showDialog(
      context: context,
      builder: (_) => BookingDialog(destination: destination),
    );

/// Price in euros and CFA francs, with the info and booking actions.
class DetailPriceCard extends StatelessWidget {
  final Destination destination;

  const DetailPriceCard({super.key, required this.destination});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.primaryContainer.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(t.startingFrom,
                    style: TextStyle(fontSize: 14, color: Theme.of(context).hintColor)),
                const SizedBox(height: 4),
                Text(Money.eur(context, destination.discountedPrice),
                    style: TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold, color: colors.primary)),
                Text(Money.xof(context, destination.discountedPrice),
                    style: TextStyle(fontSize: 13, color: Theme.of(context).hintColor)),
                if (destination.discount > 0)
                  Text(
                    t.translate('savePercent').replaceAll(
                        '{percent}', '${(destination.discount * 100).round()}'),
                    style: TextStyle(
                        fontSize: 12, color: colors.primary, fontWeight: FontWeight.w500),
                  ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              OutlinedButton.icon(
                onPressed: () => requestDestinationInfo(context, destination),
                icon: const Icon(Icons.email_outlined),
                label: Text(t.requestInfo),
              ),
              const SizedBox(height: 8),
              FilledButton(
                onPressed: () => showBookingDialog(context, destination),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                ),
                child: Text(t.bookNow,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
