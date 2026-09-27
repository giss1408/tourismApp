import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/destination_model.dart';
import '../services/image_prefetch_service.dart';
import '../services/analytics_service.dart';
import '../utils/responsive_layout.dart';
import '../widgets/destination_card.dart';
import '../widgets/featured_destinations.dart';
import '../widgets/search_widget.dart';
import '../widgets/category_chips.dart';
import '../providers/destination_provider.dart';
import '../providers/personalization_provider.dart';
import '../l10n/app_localizations.dart';
import 'home/home_hero.dart';
import 'home/home_loading.dart';
import 'home/home_sections.dart';
import 'travel_info_screen.dart';

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
              background: HomeHero(localizations: localizations),
            ),
          ),

          // Search Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: SearchWidget(hintText: localizations.whereDoYouWantToGo),
            ),
          ),

          // Practical information for the trip
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: TravelInfoCard(),
            ),
          ),

          const SliverToBoxAdapter(
            child: SizedBox(height: 10),
          ),

          SliverToBoxAdapter(
            child: SectionHeading(
              title: localizations.exploreByCategory,
              subtitle: localizations.findPerfectDestination,
            ),
          ),
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: CategoryChips(),
            ),
          ),
          SliverToBoxAdapter(child: SpecialOffersBanner(destinations: destinations)),

          if (personalized.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: SectionHeading(
                title: localizations.translate('forYou'),
                subtitle: localizations.translate('forYouSubtitle'),
              ),
            ),
            SliverToBoxAdapter(child: FeaturedDestinations(destinations: personalized)),
          ],

          if (featuredDestinations.isNotEmpty)
            SliverToBoxAdapter(
              child: SectionHeading(
                title: localizations.featuredDestinations,
                subtitle: localizations.mostPopularPlaces,
              ),
            ),
          if (isLoading)
            const SliverToBoxAdapter(child: LoadingFeaturedDestinations())
          else if (featuredDestinations.isNotEmpty)
            SliverToBoxAdapter(
              child: FeaturedDestinations(destinations: featuredDestinations),
            ),

          SliverToBoxAdapter(
            child: SectionHeading(
              title: localizations.allDestinations,
              subtitle: localizations.exploreAllAmazingPlaces,
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
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
                  childAspectRatio: ResponsiveLayout.destinationCardAspectRatio(
                      ResponsiveLayout.destinationGridCount(context)),
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
              sliver: LoadingDestinationsGrid(),
            ),

          const SliverToBoxAdapter(
            child: SizedBox(height: 30),
          ),
        ],
      ),
      ),
    );
  }
}
