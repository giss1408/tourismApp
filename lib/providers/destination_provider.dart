// providers/destination_provider.dart
import 'package:flutter/foundation.dart';
import '../models/destination_model.dart';
import '../services/destination_service.dart';

class DestinationProvider with ChangeNotifier {
  List<Destination> _destinations = [];
  List<Destination> _featuredDestinations = [];
  bool _isLoading = false;
  String _error = '';

  List<Destination> get destinations => _destinations;
  List<Destination> get featuredDestinations => _featuredDestinations;
  bool get isLoading => _isLoading;
  String get error => _error;

  DestinationProvider() {
    loadDestinations();
  }

  // Add or merge these sample destinations into your existing sample list / loadDestinations()
  final List<Destination> _sampleDestinations = [
    Destination(
      id: 'dest_101',
      name: 'Santorini Cliffs',
      location: 'Santorini, Greece',
      images: [
        'https://picsum.photos/id/1018/800/600',
        'https://picsum.photos/id/1015/800/600',
      ],
      rating: 4.8,
      price: 249.0,
      category: 'Beach',
      description: 'Whitewashed houses, blue domes and stunning sunsets over the caldera.',
      activities: ['Sightseeing', 'Sunset Viewing', 'Photography'],
    ),
    Destination(
      id: 'dest_102',
      name: 'Machu Picchu',
      location: 'Cusco Region, Peru',
      images: [
        'https://picsum.photos/id/1025/800/600',
        'https://picsum.photos/id/1024/800/600',
      ],
      rating: 4.9,
      price: 399.0,
      category: 'Historical',
      description: 'Ancient Incan citadel set high in the Andes Mountains, a bucket-list trek.',
      activities: ['Hiking', 'Guided Tours', 'Photography'],
    ),
    Destination(
      id: 'dest_103',
      name: 'Bali Rice Terraces',
      location: 'Ubud, Indonesia',
      images: [
        'https://picsum.photos/id/1036/800/600',
        'https://picsum.photos/id/1035/800/600',
      ],
      rating: 4.6,
      price: 129.0,
      category: 'Adventure',
      description: 'Lush green terraces, local culture, yoga retreats and hidden waterfalls.',
      activities: ['Trekking', 'Cultural Tours', 'Yoga Retreats'],
    ),
    Destination(
      id: 'dest_104',
      name: 'Kyoto Temples',
      location: 'Kyoto, Japan',
      images: [
        'https://picsum.photos/id/1043/800/600',
        'https://picsum.photos/id/1041/800/600',
      ],
      rating: 4.7,
      price: 179.0,
      category: 'Historical',
      description: 'Historic temples, traditional tea houses and serene bamboo groves.',
      activities: ['Temple Visits', 'Tea Ceremonies', 'Walking Tours'],
    ),
    Destination(
      id: 'dest_105',
      name: 'Swiss Alps Retreat',
      location: 'Zermatt, Switzerland',
      images: [
        'https://picsum.photos/id/1056/800/600',
        'https://picsum.photos/id/1054/800/600',
      ],
      rating: 4.9,
      price: 499.0,
      category: 'Mountain',
      description: 'Ski slopes, alpine villages and breathtaking Matterhorn views.',
      activities: ['Skiing', 'Hiking', 'Cable Car Rides'],
    ),
    Destination(
      id: 'dest_106',
      name: 'New York City',
      location: 'New York, USA',
      images: [
        'https://picsum.photos/id/1069/800/600',
        'https://picsum.photos/id/1070/800/600',
      ],
      rating: 4.5,
      price: 199.0,
      category: 'City',
      description: 'Iconic skyline, museums, Broadway shows and vibrant neighborhoods.',
      activities: ['City Tours', 'Museums', 'Food Tours'],
    ),
    Destination(
      id: 'dest_107',
      name: 'Table Mountain',
      location: 'Cape Town, South Africa',
      images: [
        'https://picsum.photos/id/1080/800/600',
        'https://picsum.photos/id/1082/800/600',
      ],
      rating: 4.7,
      price: 149.0,
      category: 'Adventure',
      description: 'Flat-topped mountain with cable car access and panoramic city views.',
      activities: ['Cable Car', 'Hiking', 'Panoramic Viewing'],
    ),
  ];

  Future<void> loadDestinations() async {
    _isLoading = true;
    notifyListeners();

    try {
      _destinations = await DestinationService.getDestinations();
      _featuredDestinations = _destinations.where((d) => d.isFeatured).toList();
      _error = '';
    } catch (e) {
      _error = 'Failed to load destinations: $e';
      // Fallback data in case of error
      _destinations = _getFallbackDestinations();
      _featuredDestinations = _destinations.where((d) => d.isFeatured).toList();
    } finally {
      _isLoading = false;
      notifyListeners();
    }

    // Example usage: merge into provider list on load
    _destinations.addAll(_sampleDestinations);
    notifyListeners();
  }

  List<Destination> _getFallbackDestinations() {
    return [
      Destination(
        id: '1',
        name: 'Bali Paradise',
        description: 'Beautiful tropical island with stunning beaches and rich culture',
        location: 'Bali, Indonesia',
        rating: 4.8,
        price: 299.99,
        images: ['https://picsum.photos/400/300?random=1'],
        activities: ['Beach', 'Surfing', 'Temples'],
        isFeatured: true,
        category: 'Beach',
      ),
      Destination(
        id: '2',
        name: 'Tokyo Adventure',
        description: 'Experience the perfect blend of tradition and modernity',
        location: 'Tokyo, Japan',
        rating: 4.7,
        price: 599.99,
        images: ['https://picsum.photos/400/300?random=2'],
        activities: ['City Tour', 'Shopping', 'Temples'],
        isFeatured: true,
        category: 'City',
      ),
      Destination(
        id: '3',
        name: 'Swiss Alps',
        description: 'Breathtaking mountain views and outdoor activities',
        location: 'Interlaken, Switzerland',
        rating: 4.9,
        price: 799.99,
        images: ['https://picsum.photos/400/300?random=3'],
        activities: ['Hiking', 'Skiing', 'Sightseeing'],
        isFeatured: false,
        category: 'Mountain',
      ),
    ];
  }

  List<Destination> getDestinationsByCategory(String category) {
    if (category == 'All') return _destinations;
    return _destinations.where((d) => d.category == category).toList();
  }

  List<Destination> searchDestinations(String query) {
    if (query.isEmpty) return _destinations;
    return _destinations.where((destination) =>
        destination.name.toLowerCase().contains(query.toLowerCase()) ||
        destination.location.toLowerCase().contains(query.toLowerCase()) ||
        destination.description.toLowerCase().contains(query.toLowerCase())).toList();
  }
}