// screens/destinations_screen.dart - COMPLETE FILE
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/destination_model.dart';
import '../providers/destination_provider.dart';
import '../widgets/destination_card.dart';
import '../widgets/search_widget.dart';

class DestinationsScreen extends StatefulWidget {
  const DestinationsScreen({super.key});

  @override
  State<DestinationsScreen> createState() => _DestinationsScreenState();
}

class _DestinationsScreenState extends State<DestinationsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All';

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
    final destinationProvider = context.watch<DestinationProvider>();

    List<Destination> filteredDestinations = _selectedCategory == 'All'
        ? destinationProvider.destinations
        : destinationProvider.getDestinationsByCategory(_selectedCategory);

    if (_searchController.text.isNotEmpty) {
      filteredDestinations = destinationProvider.searchDestinations(_searchController.text);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Explore Destinations'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search Bar — add top offset so it's never covered by a transparent AppBar
            Padding(
              padding: EdgeInsets.fromLTRB(
                16,
                MediaQuery.of(context).padding.top + kToolbarHeight + 8,
                16,
                0,
              ),
              child: const SearchWidget(),
            ),
            
            // Category Filter
            SizedBox(
              height: 60,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _buildCategoryChip('All', Icons.all_inclusive),
                  _buildCategoryChip('Beach', Icons.beach_access),
                  _buildCategoryChip('Mountain', Icons.landscape),
                  _buildCategoryChip('City', Icons.location_city),
                  _buildCategoryChip('Historical', Icons.castle),
                  _buildCategoryChip('Adventure', Icons.hiking),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Results Count
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Text(
                    '${filteredDestinations.length} destinations found',
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
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.search_off, size: 64, color: Colors.grey),
                              SizedBox(height: 16),
                              Text(
                                'No destinations found',
                                style: TextStyle(fontSize: 18, color: Colors.grey),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Try adjusting your search or filters',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        )
                      : GridView.builder(
                          padding: const EdgeInsets.all(16),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 0.75,
                          ),
                          itemCount: filteredDestinations.length,
                          itemBuilder: (context, index) {
                            return DestinationCard(destination: filteredDestinations[index]);
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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}