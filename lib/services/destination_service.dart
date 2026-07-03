// services/destination_service.dart
import '../models/destination_model.dart';

// services/destination_service.dart - Update with booking info
class DestinationService {
  static Future<List<Destination>> getDestinations() async {
    await Future.delayed(const Duration(seconds: 1));

    return [
      Destination(
        id: '1',
        name: 'Bali Paradise',
        description: 'Beautiful tropical island with stunning beaches and rich culture. Experience the perfect blend of traditional temples, vibrant ceremonies, and modern beach clubs.',
        location: 'Bali, Indonesia',
        rating: 4.8,
        price: 1299.99,
        images: ['https://picsum.photos/400/300?random=1'],
        activities: ['Beach', 'Surfing', 'Temples', 'Yoga', 'Diving'],
        isFeatured: true,
        category: 'Beach',
        availableSpots: 15,
        discount: 0.1, // 10% discount
      ),
      Destination(
        id: '2',
        name: 'Tokyo Adventure',
        description: 'Experience the perfect blend of tradition and modernity in this bustling metropolis. From ancient temples to cutting-edge technology.',
        location: 'Tokyo, Japan',
        rating: 4.7,
        price: 1899.99,
        images: ['https://picsum.photos/400/300?random=2'],
        activities: ['City Tour', 'Shopping', 'Temples', 'Sushi Making'],
        isFeatured: true,
        category: 'City',
        availableSpots: 25,
      ),
      // ... include all other destinations with availableSpots and discount
    ];
  }
}