import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../models/destination_model.dart';
import '../../services/analytics_service.dart';
import '../../utils/money.dart';
import '../../widgets/optimized_network_image.dart';
import '../destination_detail_screen.dart';

/// Title and subtitle introducing a home screen section.
class SectionHeading extends StatelessWidget {
  final String title;
  final String subtitle;
  final EdgeInsets padding;

  const SectionHeading({
    super.key,
    required this.title,
    required this.subtitle,
    this.padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(subtitle,
              style: TextStyle(fontSize: 14, color: Theme.of(context).hintColor)),
        ],
      ),
    );
  }
}

/// Promotes the discounted destinations; hidden when there are none.
class SpecialOffersBanner extends StatelessWidget {
  final List<Destination> destinations;

  const SpecialOffersBanner({super.key, required this.destinations});

  @override
  Widget build(BuildContext context) {
    final offers = destinations.where((d) => d.discount > 0).toList();
    if (offers.isEmpty) return const SizedBox.shrink();
    final t = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    final bestDiscount =
        offers.map((d) => (d.discount * 100).round()).reduce((a, b) => a > b ? a : b);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Material(
        borderRadius: BorderRadius.circular(20),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            context.read<AnalyticsService>().trackEvent(
              'special_offers_opened',
              properties: <String, Object?>{'offer_count': offers.length},
            );
            showSpecialOffersSheet(context, offers);
          },
          child: Ink(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [colors.secondary, colors.primary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.white24,
                  child: Icon(Icons.local_offer, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(t.specialOffers,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(
                        t.translate('offersUpTo').replaceAll('{percent}', '$bestDiscount'),
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward, color: Colors.white),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

void showSpecialOffersSheet(BuildContext context, List<Destination> offers) {
  final t = AppLocalizations.of(context);
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (sheetContext) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.7,
      maxChildSize: 0.9,
      builder: (context, controller) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: Row(
              children: [
                Icon(Icons.local_offer, color: Theme.of(context).colorScheme.secondary),
                const SizedBox(width: 10),
                Text(t.specialOffers,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              controller: controller,
              padding: const EdgeInsets.all(16),
              itemCount: offers.length,
              itemBuilder: (context, index) {
                final destination = offers[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: destination.images.isEmpty
                          ? const SizedBox(width: 60, height: 60, child: Icon(Icons.image))
                          : OptimizedNetworkImage(
                              imageUrl: destination.images.first,
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                            ),
                    ),
                    title: Text(destination.name),
                    subtitle: Text(t
                        .translate('savePercent')
                        .replaceAll('{percent}', '${(destination.discount * 100).round()}')),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(Money.eur(context, destination.discountedPrice),
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary)),
                        Text(Money.eur(context, destination.price),
                            style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context).hintColor,
                                decoration: TextDecoration.lineThrough)),
                      ],
                    ),
                    onTap: () {
                      Navigator.pop(sheetContext);
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) =>
                            DestinationDetailScreen(destinationId: destination.id),
                      ));
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    ),
  );
}
