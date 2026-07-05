// models/destination_model.dart - Add booking-related fields
class Destination {
  final String id;
  final String name;
  final String description;
  final String location;
  final double rating;
  final double price;
  final List<String> images;
  final List<String> activities;
  final bool isFeatured;
  final String category;
  final int availableSpots; // New field
  final double discount; // New field for special offers
  final double? latitude;
  final double? longitude;

  Destination({
    required this.id,
    required this.name,
    required this.description,
    required this.location,
    required this.rating,
    required this.price,
    required this.images,
    required this.activities,
    this.isFeatured = false,
    required this.category,
    this.availableSpots = 50, // Default value
    this.discount = 0.0, // Default no discount
    this.latitude,
    this.longitude,
  });

  // Calculate discounted price
  double get discountedPrice => discount > 0 ? price * (1 - discount) : price;

  factory Destination.fromJson(Map<String, dynamic> json) {
    return Destination(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      location: json['location'],
      rating: json['rating'].toDouble(),
      price: json['price'].toDouble(),
      images: List<String>.from(json['images']),
      activities: List<String>.from(json['activities']),
      isFeatured: json['isFeatured'],
      category: json['category'],
      availableSpots: json['availableSpots'] ?? 50,
      discount: json['discount']?.toDouble() ?? 0.0,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'location': location,
      'rating': rating,
      'price': price,
      'images': images,
      'activities': activities,
      'isFeatured': isFeatured,
      'category': category,
      'availableSpots': availableSpots,
      'discount': discount,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}