import '../../models/destination_model.dart';

class DestinationDto {
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
  final int availableSpots;
  final double discount;
  final double? latitude;
  final double? longitude;

  const DestinationDto({
    required this.id,
    required this.name,
    required this.description,
    required this.location,
    required this.rating,
    required this.price,
    required this.images,
    required this.activities,
    required this.isFeatured,
    required this.category,
    required this.availableSpots,
    required this.discount,
    required this.latitude,
    required this.longitude,
  });

  factory DestinationDto.fromJson(Map<String, dynamic> json) {
    return DestinationDto(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      location: (json['location'] ?? '').toString(),
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      price: (json['price'] as num?)?.toDouble() ?? 0,
      images: List<String>.from(json['images'] ?? const []),
      activities: List<String>.from(json['activities'] ?? const []),
      isFeatured: json['isFeatured'] == true,
      category: (json['category'] ?? 'General').toString(),
      availableSpots: (json['availableSpots'] as num?)?.toInt() ?? 0,
      discount: (json['discount'] as num?)?.toDouble() ?? 0,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
    );
  }

  Destination toDomain() {
    return Destination(
      id: id,
      name: name,
      description: description,
      location: location,
      rating: rating,
      price: price,
      images: images,
      activities: activities,
      isFeatured: isFeatured,
      category: category,
      availableSpots: availableSpots,
      discount: discount,
      latitude: latitude,
      longitude: longitude,
    );
  }
}
