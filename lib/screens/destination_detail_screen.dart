import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../models/destination_model.dart';
import '../providers/destination_provider.dart';
import '../providers/favorites_provider.dart';
import '../providers/personalization_provider.dart';
import '../services/analytics_service.dart';
import '../widgets/optimized_network_image.dart';
import 'destination_detail/detail_header.dart';
import 'destination_detail/guides_section.dart';
import 'destination_detail/reviews_section.dart';
import 'destination_detail/section_title.dart';

class DestinationDetailScreen extends StatefulWidget {
  final String destinationId;

  const DestinationDetailScreen({super.key, required this.destinationId});

  @override
  State<DestinationDetailScreen> createState() => _DestinationDetailScreenState();
}

class _DestinationDetailScreenState extends State<DestinationDetailScreen> {
  final Destination _missingDestination = Destination(
    id: '0',
    name: 'Destination not found',
    description: '',
    location: '',
    rating: 0,
    price: 0,
    images: const <String>[],
    activities: const <String>[],
    category: '',
  );

  DestinationProvider? _destinationProvider;
  bool _hasTrackedOpen = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final provider = context.read<DestinationProvider>();
    if (!identical(_destinationProvider, provider)) {
      _destinationProvider?.removeListener(_onDestinationProviderChanged);
      _destinationProvider = provider;
      _destinationProvider?.addListener(_onDestinationProviderChanged);
      _onDestinationProviderChanged();
    }
  }

  @override
  void dispose() {
    _destinationProvider?.removeListener(_onDestinationProviderChanged);
    super.dispose();
  }

  void _onDestinationProviderChanged() {
    if (!mounted || _hasTrackedOpen) {
      return;
    }

    final provider = _destinationProvider;
    if (provider == null) {
      return;
    }

    final destination = _findDestination(provider);
    if (destination == null) {
      return;
    }

    _hasTrackedOpen = true;
    context.read<AnalyticsService>().trackEvent(
      'destination_opened',
      properties: <String, Object?>{
        'destination_id': destination.id,
        'category': destination.category,
        'price': destination.price,
        'rating': destination.rating,
      },
    );
    context.read<PersonalizationProvider>().trackView(destination);
  }

  Destination? _findDestination(DestinationProvider provider) {
    for (final destination in provider.destinations) {
      if (destination.id == widget.destinationId) {
        return destination;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final destination = context.select<DestinationProvider, Destination>(
      (provider) => _findDestination(provider) ?? _missingDestination,
    );
    final isFavorite = context.select<FavoritesProvider, bool>(
      (provider) => provider.isFavorite(destination.id),
    );
    final t = AppLocalizations.of(context);
    final found = destination.id != _missingDestination.id;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  if (destination.images.isNotEmpty)
                    OptimizedNetworkImage(
                      imageUrl: destination.images.first,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    )
                  else
                    ColoredBox(color: Theme.of(context).colorScheme.primaryContainer),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black.withOpacity(0.3)],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            leading: _CircleButton(
              icon: Icons.arrow_back,
              tooltip: MaterialLocalizations.of(context).backButtonTooltip,
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              if (found)
                _CircleButton(
                  icon: isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? Colors.red : Colors.black,
                  tooltip: t.translate(isFavorite ? 'favorited' : 'addFavorite'),
                  onPressed: () =>
                      context.read<FavoritesProvider>().toggleFavorite(destination.id),
                ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: !found
                  ? Text(t.translate('destinationNotFound'))
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        DetailTitleRow(destination: destination),
                        const SizedBox(height: 10),
                        DetailActionChips(destination: destination),
                        const SizedBox(height: 24),
                        DetailPriceCard(destination: destination),
                        const SizedBox(height: 24),
                        DetailSectionTitle(t.aboutThisDestination),
                        const SizedBox(height: 12),
                        Text(
                          destination.description,
                          style: TextStyle(
                              fontSize: 16, height: 1.6, color: Theme.of(context).hintColor),
                        ),
                        if (destination.activities.isNotEmpty) ...[
                          const SizedBox(height: 24),
                          DetailSectionTitle(t.popularActivities),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: destination.activities
                                .map((activity) => Chip(label: Text(activity)))
                                .toList(),
                          ),
                        ],
                        if (destination.images.length > 1) ...[
                          const SizedBox(height: 24),
                          DetailSectionTitle(t.gallery),
                          const SizedBox(height: 12),
                          _Gallery(images: destination.images),
                        ],
                        const SizedBox(height: 24),
                        GuidesSection(
                          destinationId: destination.id,
                          destinationName: destination.name,
                        ),
                        ReviewsSection(destinationId: destination.id),
                        // Room for the floating booking button.
                        const SizedBox(height: 80),
                      ],
                    ),
            ),
          ),
        ],
      ),
      floatingActionButton: found
          ? FloatingActionButton.extended(
              onPressed: () => showBookingDialog(context, destination),
              icon: const Icon(Icons.book_online),
              label: Text(t.bookNow, style: const TextStyle(fontWeight: FontWeight.bold)),
            )
          : null,
    );
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback onPressed;

  const _CircleButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.color = Colors.black,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      icon: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color),
      ),
      onPressed: onPressed,
    );
  }
}

class _Gallery extends StatelessWidget {
  final List<String> images;

  const _Gallery({required this.images});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: images.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) => ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: OptimizedNetworkImage(
            imageUrl: images[index],
            fit: BoxFit.cover,
            width: 160,
            height: 120,
          ),
        ),
      ),
    );
  }
}
