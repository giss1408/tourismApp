import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/destination_model.dart';
import '../providers/destination_provider.dart';
import '../providers/favorites_provider.dart';
import '../widgets/destination_card.dart';
import '../widgets/search_widget.dart';
import '../l10n/app_localizations.dart';

class _CategoryOption {
  final String name;
  final IconData icon;

  const _CategoryOption(this.name, this.icon);
}

enum _SortOption {
  recommended,
  priceLowToHigh,
  priceHighToLow,
  ratingHighToLow,
  nameAToZ,
}

class DestinationsScreen extends StatefulWidget {
  const DestinationsScreen({super.key});

  @override
  State<DestinationsScreen> createState() => _DestinationsScreenState();
}

class _DestinationsScreenState extends State<DestinationsScreen> {
  static const List<_CategoryOption> _categories = [
    _CategoryOption('All', Icons.all_inclusive),
    _CategoryOption('Beach', Icons.beach_access),
    _CategoryOption('Mountain', Icons.landscape),
    _CategoryOption('City', Icons.location_city),
    _CategoryOption('Historical', Icons.castle),
    _CategoryOption('Adventure', Icons.hiking),
  ];

  String _selectedCategory = 'All';
  String _searchQuery = '';
  _SortOption _sortOption = _SortOption.recommended;
  bool _dealsOnly = false;
  bool _favoritesOnly = false;
  double _minRating = 0;
  double? _maxBudget;

  @override
  void initState() {
    super.initState();
    // Ensure destinations are loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<DestinationProvider>();
      if (provider.destinations.isEmpty) {
        provider.loadDestinations();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final destinationProvider = context.watch<DestinationProvider>();
    final favoritesProvider = context.watch<FavoritesProvider>();
    final allDestinations = destinationProvider.destinations;

    List<Destination> filteredDestinations = _selectedCategory == 'All'
      ? allDestinations
        : destinationProvider.getDestinationsByCategory(_selectedCategory);

    if (_searchQuery.trim().isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filteredDestinations = filteredDestinations.where((destination) {
        return destination.name.toLowerCase().contains(query) ||
            destination.location.toLowerCase().contains(query) ||
            destination.description.toLowerCase().contains(query);
      }).toList();
    }

    if (_dealsOnly) {
      filteredDestinations =
          filteredDestinations.where((destination) => destination.discount > 0).toList();
    }

    if (_favoritesOnly) {
      filteredDestinations = filteredDestinations
          .where((destination) => favoritesProvider.isFavorite(destination.id))
          .toList();
    }

    if (_minRating > 0) {
      filteredDestinations = filteredDestinations
          .where((destination) => destination.rating >= _minRating)
          .toList();
    }

    if (_maxBudget != null) {
      filteredDestinations = filteredDestinations
          .where((destination) => destination.discountedPrice <= _maxBudget!)
          .toList();
    }

    filteredDestinations = _applySort(filteredDestinations);

    final maxPrice = allDestinations.isEmpty
        ? 0.0
        : allDestinations
            .map((destination) => destination.discountedPrice)
            .reduce((a, b) => a > b ? a : b);

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.exploreDestinations),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: SearchWidget(
                hintText: localizations.searchDestinations,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
                onFilterTap: () => _openFilterSheet(maxPrice),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
              child: Row(
                children: [
                  Text(
                    'Sort',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: DropdownButtonFormField<_SortOption>(
                      value: _sortOption,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: _SortOption.recommended,
                          child: Text('Recommended'),
                        ),
                        DropdownMenuItem(
                          value: _SortOption.priceLowToHigh,
                          child: Text('Price: Low to High'),
                        ),
                        DropdownMenuItem(
                          value: _SortOption.priceHighToLow,
                          child: Text('Price: High to Low'),
                        ),
                        DropdownMenuItem(
                          value: _SortOption.ratingHighToLow,
                          child: Text('Rating: High to Low'),
                        ),
                        DropdownMenuItem(
                          value: _SortOption.nameAToZ,
                          child: Text('Name: A to Z'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() {
                          _sortOption = value;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
            
            // Category Filter
            SizedBox(
              height: 60,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: _categories
                    .map((category) => _buildCategoryChip(category.name, category.icon))
                    .toList(),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Results Count
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Text(
                    '${filteredDestinations.length} ${localizations.destinationsFound}',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Destinations Grid
            Expanded(
              child: destinationProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : filteredDestinations.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.search_off, size: 64, color: Colors.grey),
                              const SizedBox(height: 16),
                              Text(
                                localizations.noDestinationsFound,
                                style: const TextStyle(fontSize: 18, color: Colors.grey),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                localizations.tryAdjustingSearch,
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        )
                      : LayoutBuilder(
                          builder: (context, constraints) {
                            final width = constraints.maxWidth;
                            final crossAxisCount =
                                width >= 1100 ? 4 : (width >= 700 ? 3 : 2);

                            return RefreshIndicator(
                              onRefresh: () => context
                                  .read<DestinationProvider>()
                                  .loadDestinations(),
                              child: GridView.builder(
                                padding: const EdgeInsets.all(16),
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: crossAxisCount,
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 16,
                                  childAspectRatio: width >= 700 ? 0.82 : 0.76,
                                ),
                                itemCount: filteredDestinations.length,
                                itemBuilder: (context, index) {
                                  return DestinationCard(
                                    destination: filteredDestinations[index],
                                  );
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

  List<Destination> _applySort(List<Destination> destinations) {
    final sorted = List<Destination>.from(destinations);

    switch (_sortOption) {
      case _SortOption.priceLowToHigh:
        sorted.sort((a, b) => a.discountedPrice.compareTo(b.discountedPrice));
        break;
      case _SortOption.priceHighToLow:
        sorted.sort((a, b) => b.discountedPrice.compareTo(a.discountedPrice));
        break;
      case _SortOption.ratingHighToLow:
        sorted.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case _SortOption.nameAToZ:
        sorted.sort((a, b) => a.name.compareTo(b.name));
        break;
      case _SortOption.recommended:
        sorted.sort((a, b) {
          final aScore = (a.rating * 2) + (a.isFeatured ? 2 : 0) + (a.discount * 10);
          final bScore = (b.rating * 2) + (b.isFeatured ? 2 : 0) + (b.discount * 10);
          return bScore.compareTo(aScore);
        });
        break;
    }

    return sorted;
  }

  Future<void> _openFilterSheet(double maxPrice) async {
    bool dealsOnly = _dealsOnly;
    bool favoritesOnly = _favoritesOnly;
    double minRating = _minRating;
    double budget = (_maxBudget ?? maxPrice).clamp(0, maxPrice == 0 ? 1 : maxPrice);

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        final currency = maxPrice > 0 ? '\$${budget.toStringAsFixed(0)}' : 'Any';

        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                20,
                4,
                20,
                MediaQuery.of(context).viewInsets.bottom + 18,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Advanced Filters',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 14),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    value: dealsOnly,
                    onChanged: (value) => setModalState(() => dealsOnly = value),
                    title: const Text('Deals only'),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    value: favoritesOnly,
                    onChanged: (value) => setModalState(() => favoritesOnly = value),
                    title: const Text('Favorites only'),
                  ),
                  const SizedBox(height: 10),
                  Text('Minimum rating: ${minRating.toStringAsFixed(1)}'),
                  Slider(
                    value: minRating,
                    min: 0,
                    max: 5,
                    divisions: 10,
                    label: minRating.toStringAsFixed(1),
                    onChanged: (value) => setModalState(() => minRating = value),
                  ),
                  if (maxPrice > 0) ...[
                    Text('Max budget: $currency'),
                    Slider(
                      value: budget,
                      min: 0,
                      max: maxPrice,
                      divisions: 20,
                      label: budget.toStringAsFixed(0),
                      onChanged: (value) => setModalState(() => budget = value),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setState(() {
                              _dealsOnly = false;
                              _favoritesOnly = false;
                              _minRating = 0;
                              _maxBudget = null;
                            });
                            Navigator.pop(context);
                          },
                          child: const Text('Reset'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _dealsOnly = dealsOnly;
                              _favoritesOnly = favoritesOnly;
                              _minRating = minRating;
                              _maxBudget = maxPrice > 0 ? budget : null;
                            });
                            Navigator.pop(context);
                          },
                          child: const Text('Apply'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCategoryChip(String category, IconData icon) {
    final isSelected = _selectedCategory == category;
    
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: FilterChip(
        label: Text(category),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedCategory = selected ? category : 'All';
          });
        },
        avatar: Icon(icon, size: 16),
        backgroundColor: Colors.grey[200],
        selectedColor: Colors.blue.shade100,
        checkmarkColor: Colors.blue,
        labelStyle: TextStyle(
          color: isSelected ? Colors.blue : Colors.black87,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

}