import '../models/destination_model.dart';
import '../services/destination_service.dart';
import 'destination_repository.dart';
import 'query_options.dart';

class MockDestinationRepository implements DestinationRepository {
  const MockDestinationRepository();

  @override
  Future<List<Destination>> fetchDestinations({
    DestinationQueryOptions? options,
  }) async {
    List<Destination> merged;
    try {
      final serviceDestinations = await DestinationService.getDestinations();
      merged = _mergeUniqueDestinations(serviceDestinations, _sampleDestinations);
    } catch (_) {
      merged = _mergeUniqueDestinations(_fallbackDestinations, _sampleDestinations);
    }

    return _applyOptions(merged, options);
  }
}

List<Destination> _applyOptions(
  List<Destination> list,
  DestinationQueryOptions? options,
) {
  if (options == null) {
    return list;
  }

  Iterable<Destination> filtered = list;

  if (options.search != null && options.search!.trim().isNotEmpty) {
    final term = options.search!.toLowerCase();
    filtered = filtered.where((d) =>
        d.name.toLowerCase().contains(term) ||
        d.location.toLowerCase().contains(term) ||
        d.description.toLowerCase().contains(term));
  }

  if (options.category != null && options.category!.trim().isNotEmpty) {
    final category = options.category!.toLowerCase();
    filtered = filtered.where((d) => d.category.toLowerCase() == category);
  }

  final sorted = filtered.toList(growable: false);
  if (options.sortBy != null) {
    switch (options.sortBy) {
      case 'rating':
        sorted.sort((a, b) => b.rating.compareTo(a.rating));
      case 'price':
        sorted.sort((a, b) => a.price.compareTo(b.price));
      case 'name':
        sorted.sort((a, b) => a.name.compareTo(b.name));
      default:
        break;
    }

    if (options.sortDirection?.toLowerCase() == 'desc' &&
        options.sortBy == 'price') {
      sorted.sort((a, b) => b.price.compareTo(a.price));
    }
  }

  if (options.page != null && options.pageSize != null) {
    final start = (options.page! - 1) * options.pageSize!;
    if (start >= sorted.length || start < 0) {
      return const [];
    }
    final end = (start + options.pageSize!).clamp(0, sorted.length);
    return sorted.sublist(start, end);
  }

  return sorted;
}

List<Destination> _mergeUniqueDestinations(
  List<Destination> base,
  List<Destination> extras,
) {
  final merged = <String, Destination>{
    for (final destination in base) destination.id: destination,
  };

  for (final destination in extras) {
    merged.putIfAbsent(destination.id, () => destination);
  }

  return merged.values.toList(growable: false);
}

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
    description:
        'Whitewashed houses, blue domes and stunning sunsets over the caldera.',
    activities: ['Sightseeing', 'Sunset Viewing', 'Photography'],
    latitude: 36.3932,
    longitude: 25.4615,
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
    description:
        'Ancient Incan citadel set high in the Andes Mountains, a bucket-list trek.',
    activities: ['Hiking', 'Guided Tours', 'Photography'],
    latitude: -13.1631,
    longitude: -72.545,
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
    description:
        'Lush green terraces, local culture, yoga retreats and hidden waterfalls.',
    activities: ['Trekking', 'Cultural Tours', 'Yoga Retreats'],
    latitude: -8.5069,
    longitude: 115.2625,
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
    description:
        'Historic temples, traditional tea houses and serene bamboo groves.',
    activities: ['Temple Visits', 'Tea Ceremonies', 'Walking Tours'],
    latitude: 35.0116,
    longitude: 135.7681,
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
    description:
        'Ski slopes, alpine villages and breathtaking Matterhorn views.',
    activities: ['Skiing', 'Hiking', 'Cable Car Rides'],
    latitude: 46.0207,
    longitude: 7.7491,
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
    description:
        'Iconic skyline, museums, Broadway shows and vibrant neighborhoods.',
    activities: ['City Tours', 'Museums', 'Food Tours'],
    latitude: 40.7128,
    longitude: -74.006,
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
    description:
        'Flat-topped mountain with cable car access and panoramic city views.',
    activities: ['Cable Car', 'Hiking', 'Panoramic Viewing'],
    latitude: -33.9628,
    longitude: 18.4098,
  ),
];

final List<Destination> _fallbackDestinations = [
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
    latitude: -8.4095,
    longitude: 115.1889,
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
    latitude: 35.6762,
    longitude: 139.6503,
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
    latitude: 46.6863,
    longitude: 7.8632,
  ),
];
