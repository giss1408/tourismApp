// screens/home_screen.dart - UPDATE WITH TRANSLATIONS
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/destination_model.dart';
import '../services/image_prefetch_service.dart';
import '../services/analytics_service.dart';
import '../utils/responsive_layout.dart';
import '../widgets/destination_card.dart';
import '../widgets/featured_destinations.dart';
import '../widgets/loading_destination_card.dart';
import '../widgets/optimized_network_image.dart';
import '../widgets/search_widget.dart';
import '../widgets/category_chips.dart';
import '../providers/destination_provider.dart';
import '../providers/personalization_provider.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DestinationProvider? _destinationProvider;
  bool _hasTrackedListViewed = false;

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
    final provider = _destinationProvider;
    if (!mounted || provider == null) {
      return;
    }

    if (!_hasTrackedListViewed && provider.destinations.isNotEmpty) {
      _hasTrackedListViewed = true;
      context.read<AnalyticsService>().trackEvent(
        'destination_list_viewed',
        properties: <String, Object?>{
          'destination_count': provider.destinations.length,
          'featured_count': provider.featuredDestinations.length,
        },
      );
    }

    ImagePrefetchService.prefetchDestinations(
      context,
      provider.destinations,
    );
  }

  @override
  Widget build(BuildContext context) {
    final destinations = context.select<DestinationProvider, List<Destination>>(
      (provider) => provider.destinations,
    );
    final featuredDestinations =
        context.select<DestinationProvider, List<Destination>>(
      (provider) => provider.featuredDestinations,
    );
    final isLoading = context.select<DestinationProvider, bool>(
      (provider) => provider.isLoading,
    );
    final personalizationProvider = context.watch<PersonalizationProvider>();
    final size = MediaQuery.of(context).size;
    final localizations = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final heroHeight = (size.height * 0.21).clamp(170.0, 220.0);
    final personalized = personalizationProvider.recommendations(
      destinations,
      limit: 6,
    );

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => context.read<DestinationProvider>().loadDestinations(),
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
        slivers: [
          // Compact hero header
          SliverAppBar(
            expandedHeight: heroHeight,
            floating: false,
            pinned: true,
            elevation: 0,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              background: _HomeHero(localizations: localizations),
            ),
          ),

          // Search Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: SearchWidget(hintText: localizations.whereDoYouWantToGo),
            ),
          ),

          const SliverToBoxAdapter(
            child: SizedBox(height: 10),
          ),

          // Quick Categories Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    localizations.exploreByCategory,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    localizations.findPerfectDestination,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Category Chips
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: CategoryChips(),
            ),
          ),

          // Special Offers Banner
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      colorScheme.secondary,
                      colorScheme.tertiary,
                      colorScheme.primary,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.primary.withOpacity(0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.local_offer,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '🔥 ${localizations.specialOffers}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            localizations.getUpToDiscount,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 14,
                              height: 1.4,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              localizations.bookNowSaveBig,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.arrow_forward,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      onPressed: () {
                        context.read<AnalyticsService>().trackEvent(
                          'special_offers_opened',
                          properties: <String, Object?>{
                            'destination_count': destinations.length,
                          },
                        );
                        _showSpecialOffers(context, destinations);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Featured Destinations Section
          if (personalized.isNotEmpty)
            const SliverToBoxAdapter(
              child: SizedBox(height: 2),
            ),

          if (personalized.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'For You',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Based on your recently viewed places, categories, and budget.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          if (personalized.isNotEmpty)
            SliverToBoxAdapter(
              child: FeaturedDestinations(
                destinations: personalized,
              ),
            ),

          if (featuredDestinations.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '🌟 ${localizations.featuredDestinations}',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      localizations.mostPopularPlaces,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          if (isLoading)
            const SliverToBoxAdapter(
              child: _LoadingFeaturedDestinations(),
            )
          else if (featuredDestinations.isNotEmpty)
            SliverToBoxAdapter(
              child: FeaturedDestinations(
                destinations: featuredDestinations,
              ),
            ),

          // All Destinations Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '🌍 ${localizations.allDestinations}',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    localizations.exploreAllAmazingPlaces,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // All Destinations Grid
          if (!isLoading)
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: ResponsiveLayout.destinationGridCount(context),
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.75,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final destination = destinations[index];
                    return DestinationCard(
                      key: ValueKey<String>('destination-${destination.id}'),
                      destination: destination,
                    );
                  },
                  childCount: destinations.length,
                ),
              ),
            ),

          if (isLoading)
            const SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              sliver: _LoadingDestinationsGrid(),
            ),

          const SliverToBoxAdapter(
            child: SizedBox(height: 30),
          ),
        ],
      ),
      ),
    );
  }

  void _showSpecialOffers(BuildContext context, List<Destination> destinations) {
    final localizations = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final discountedDestinations = destinations
        .where((destination) => destination.discount > 0)
        .toList();

    if (discountedDestinations.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(localizations.noDestinationsFound),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.orange.shade400,
                    Colors.red.shade400,
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(25),
                  topRight: Radius.circular(25),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.local_offer, color: Colors.white, size: 30),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      localizations.specialOffers,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            // Content
            Expanded(
              child: discountedDestinations.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.offline_bolt, size: 64, color: Colors.grey),
                          const SizedBox(height: 16),
                          Text(
                            localizations.noDestinationsFound,
                            style: const TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: discountedDestinations.length,
                      itemBuilder: (context, index) {
                        final destination = discountedDestinations[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: OptimizedNetworkImage(
                                imageUrl: destination.images.first,
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                              ),
                            ),
                            title: Text(destination.name),
                            subtitle: Text(
                              '${(destination.discount * 100).toInt()}% ${localizations.discount} - ${localizations.save} \$${(destination.price * destination.discount).toStringAsFixed(0)}',
                              style: TextStyle(color: colorScheme.tertiary),
                            ),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '\$${destination.discountedPrice.toInt()}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                                Text(
                                  '\$${destination.price.toInt()}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                              ],
                            ),
                            onTap: () {
                              Navigator.pop(context);
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
}

class _LoadingFeaturedDestinations extends StatelessWidget {
  const _LoadingFeaturedDestinations();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 280,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: 3,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          return Container(
            width: ResponsiveLayout.featuredCardWidth(context),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(20),
            ),
          );
        },
      ),
    );
  }
}

class _LoadingDestinationsGrid extends StatelessWidget {
  const _LoadingDestinationsGrid();

  @override
  Widget build(BuildContext context) {
    return SliverGrid(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: ResponsiveLayout.destinationGridCount(context),
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.75,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) => const LoadingDestinationCard(),
        childCount: 6,
      ),
    );
  }
}

class _HomeHero extends StatelessWidget {
  final AppLocalizations localizations;

  const _HomeHero({required this.localizations});

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    final brightness = Theme.of(context).brightness;

    return Container(
      decoration: BoxDecoration(
        gradient: AppTheme.heroGradient(brightness),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            top: -54,
            right: -30,
            child: Container(
              width: 170,
              height: 170,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -65,
            left: -40,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(20, top + 14, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  '${localizations.exploreThe} ${localizations.beautifulWorld}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    height: 1.05,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  localizations.discoverAmazingPlaces,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    _HeroPill(
                      icon: Icons.auto_awesome,
                      label: localizations.featuredDestinations,
                    ),
                    _HeroPill(
                      icon: Icons.sell,
                      label: localizations.specialOffers,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroPill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _HeroPill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.18),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withOpacity(0.22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 14),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}