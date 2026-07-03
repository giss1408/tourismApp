import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/destination_model.dart';
import '../providers/destination_provider.dart';
import '../widgets/destination_card.dart';
import '../widgets/search_widget.dart';
import '../l10n/app_localizations.dart';

class _CategoryOption {
  final String name;
  final IconData icon;

  const _CategoryOption(this.name, this.icon);
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

    List<Destination> filteredDestinations = _selectedCategory == 'All'
        ? destinationProvider.destinations
        : destinationProvider.getDestinationsByCategory(_selectedCategory);

    if (_searchQuery.trim().isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filteredDestinations = filteredDestinations.where((destination) {
        return destination.name.toLowerCase().contains(query) ||
            destination.location.toLowerCase().contains(query) ||
            destination.description.toLowerCase().contains(query);
      }).toList();
    }

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

                            return GridView.builder(
                              padding: const EdgeInsets.all(16),
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: crossAxisCount,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                                childAspectRatio: width >= 700 ? 0.78 : 0.75,
                              ),
                              itemCount: filteredDestinations.length,
                              itemBuilder: (context, index) {
                                return DestinationCard(
                                  destination: filteredDestinations[index],
                                );
                              },
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
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