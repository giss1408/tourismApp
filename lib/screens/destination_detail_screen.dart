// screens/destination_detail_screen.dart - COMPLETE FIXED VERSION
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../l10n/app_localizations.dart';
import '../models/destination_model.dart';
import '../providers/destination_provider.dart';
import '../providers/favorites_provider.dart';
import '../providers/personalization_provider.dart';
import '../services/analytics_service.dart';
import '../services/destination_info_request_service.dart';
import '../widgets/booking_dialog.dart';
import '../widgets/optimized_network_image.dart';

class DestinationDetailScreen extends StatefulWidget {
  final String destinationId;

  const DestinationDetailScreen({super.key, required this.destinationId});

  @override
  State<DestinationDetailScreen> createState() => _DestinationDetailScreenState();
}

class _DestinationDetailScreenState extends State<DestinationDetailScreen> {
  static const String _infoEmailAddress = 'travel-info@exploreworld.app';
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
    final inCollections = context.select<FavoritesProvider, List<String>>(
      (provider) => provider.collectionsForDestination(destination.id),
    );
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                  OptimizedNetworkImage(
                    imageUrl: destination.images.isNotEmpty
                        ? destination.images.first
                        : 'https://picsum.photos/400/300?random=travel',
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.3),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            leading: IconButton(
              icon: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back, color: Colors.black),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite ? Colors.red : Colors.black,
                  ),
                ),
                onPressed: () async {
                  await context.read<FavoritesProvider>().toggleFavorite(destination.id);
                },
              ),
            ],
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Location
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              destination.name,
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.location_on, 
                                    color: Colors.grey, size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  destination.location,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Rating
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.star, 
                                color: Colors.amber, size: 20),
                            const SizedBox(width: 4),
                            Text(
                              destination.rating.toString(),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ActionChip(
                        avatar: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          size: 18,
                          color: isFavorite ? Colors.red : null,
                        ),
                        label: Text(isFavorite ? 'Favorited' : 'Add Favorite'),
                        onPressed: () async {
                          await context.read<FavoritesProvider>().toggleFavorite(
                            destination.id,
                          );
                        },
                      ),
                      ActionChip(
                        avatar: const Icon(Icons.collections_bookmark, size: 18),
                        label: Text(
                          inCollections.isEmpty
                              ? 'Save to collection'
                              : 'Collections (${inCollections.length})',
                        ),
                        onPressed: () {
                          _showSaveToCollectionSheet(
                            context,
                            destination.id,
                            context.read<FavoritesProvider>(),
                          );
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Price and Book Button
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Starting from',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '\$${destination.discountedPrice.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                            if (destination.discount > 0)
                              Text(
                                'Save ${(destination.discount * 100).toInt()}%',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.green,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                          ],
                        ),
                        const Spacer(),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            OutlinedButton.icon(
                              onPressed: () {
                                _requestDestinationInfo(destination);
                              },
                              icon: const Icon(Icons.email_outlined),
                              label: Text(localizations.requestInfo),
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) =>
                                      BookingDialog(destination: destination),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue.shade600,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 32,
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Book Now',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Description
                  const _DetailSectionTitle('About this destination'),
                  const SizedBox(height: 12),
                  Text(
                    destination.description,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.6,
                      color: Colors.grey,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Activities
                  const _DetailSectionTitle('Popular Activities'),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: destination.activities.map((activity) {
                      return Chip(
                        label: Text(activity),
                        backgroundColor: Colors.blue.shade100,
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 24),

                  // Gallery (if multiple images)
                  if (destination.images.length > 1) ...[
                    const _DetailSectionTitle('Gallery'),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 120,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: destination.images.length,
                        itemBuilder: (context, index) {
                          return Container(
                            width: 160,
                            margin: const EdgeInsets.only(right: 12),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: OptimizedNetworkImage(
                                imageUrl: destination.images[index],
                                fit: BoxFit.cover,
                                width: 160,
                                height: 120,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // What's Included - FIXED: Changed Icons.guide to Icons.person
                  const _DetailSectionTitle("What's Included"),
                  const SizedBox(height: 12),
                  _buildIncludedItem(Icons.hotel, 'Accommodation'),
                  _buildIncludedItem(Icons.restaurant, 'Meals'),
                  _buildIncludedItem(Icons.directions_car, 'Transportation'),
                  _buildIncludedItem(Icons.person, 'Tour Guide'), // FIXED ICON

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),

      // Floating Book Button
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => BookingDialog(destination: destination),
          );
        },
        backgroundColor: Colors.blue.shade600,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.book_online),
        label: const Text(
          'Book Now',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildIncludedItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.green, size: 20),
          const SizedBox(width: 12),
          Text(
            text,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  Future<void> _requestDestinationInfo(Destination destination) async {
    final formResult = await _showInfoRequestSheet();
    if (formResult == null || !mounted) {
      return;
    }

    final localizations = AppLocalizations.of(context);
    final requestData = DestinationInfoRequestData(
      questionType: formResult.questionType,
      preferredContact: formResult.preferredContact,
    );
    final subject = DestinationInfoRequestService.buildSubject(
      localizations,
      destination,
    );
    final body = DestinationInfoRequestService.buildBody(
      localizations,
      destination,
      requestData,
    );

    final mailUri = Uri(
      scheme: 'mailto',
      path: _infoEmailAddress,
      queryParameters: <String, String>{
        'subject': subject,
        'body': body,
      },
    );

    final launched = await launchUrl(mailUri);

    if (!mounted) {
      return;
    }

    if (launched) {
      context.read<AnalyticsService>().trackEvent(
        'destination_info_requested',
        properties: DestinationInfoRequestService.analyticsPayload(
          destination,
          requestData,
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(localizations.infoEmailOpened),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(localizations.emailAppUnavailable),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<_InfoRequestFormResult?> _showInfoRequestSheet() {
    final localizations = AppLocalizations.of(context);
    final questionTypes =
        DestinationInfoRequestService.localizedQuestionTypes(localizations);
    String selectedQuestionType = questionTypes.first;
    final contactController = TextEditingController();

    return showModalBottomSheet<_InfoRequestFormResult>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                16,
                8,
                16,
                MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    localizations.requestDestinationInfo,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: selectedQuestionType,
                    decoration: InputDecoration(
                      labelText: localizations.questionType,
                      border: const OutlineInputBorder(),
                    ),
                    items: questionTypes
                        .map(
                          (questionType) => DropdownMenuItem<String>(
                            value: questionType,
                            child: Text(questionType),
                          ),
                        )
                        .toList(growable: false),
                    onChanged: (value) {
                      if (value == null) {
                        return;
                      }
                      setModalState(() {
                        selectedQuestionType = value;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: contactController,
                    decoration: InputDecoration(
                      labelText: localizations.preferredContact,
                      hintText: localizations.emailOrPhoneNumber,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        final preferredContact = contactController.text.trim();
                        if (preferredContact.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(localizations.pleaseEnterPreferredContact),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                          return;
                        }

                        Navigator.of(sheetContext).pop(
                          _InfoRequestFormResult(
                            questionType: selectedQuestionType,
                            preferredContact: preferredContact,
                          ),
                        );
                      },
                      child: Text(localizations.continueAction),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _showSaveToCollectionSheet(
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
              const Text(
                'Save to collections',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              if (collectionNames.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(bottom: 10),
                  child: Text('No collections yet. Create one below.'),
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
                      decoration: const InputDecoration(
                        hintText: 'New collection name',
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
                    child: const Text('Create'),
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
}

class _DetailSectionTitle extends StatelessWidget {
  final String title;

  const _DetailSectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

class _InfoRequestFormResult {
  final String questionType;
  final String preferredContact;

  const _InfoRequestFormResult({
    required this.questionType,
    required this.preferredContact,
  });
}