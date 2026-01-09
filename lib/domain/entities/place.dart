import 'package:equatable/equatable.dart';

enum PlaceCategory {
  restaurant,
  cafe,
  bar,
  hotel,
  attraction,
  park,
  museum,
  shop,
  event,
  accommodation,
  entertainment,
  nature,
  cultural,
  other,
}

class Place extends Equatable {
  final String id;
  final String name;
  final String? description;
  final double latitude;
  final double longitude;
  final String? address;
  final PlaceCategory category;
  final List<String> amenities; // WiFi, parking, etc.
  final double? averageRating; // Aggregated from user ratings
  final int? reviewCount;
  final Map<String, dynamic>? pricing; // Entry fees, average spend
  final List<String> photos; // Place photos
  final String? website;
  final String? phoneNumber;
  final Map<String, dynamic>? operatingHours;
  final List<String> tags;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Place({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.category,
    this.description,
    this.address,
    this.amenities = const [],
    this.averageRating,
    this.reviewCount,
    this.pricing,
    this.photos = const [],
    this.website,
    this.phoneNumber,
    this.operatingHours,
    this.tags = const [],
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    latitude,
    longitude,
    address,
    category,
    amenities,
    averageRating,
    reviewCount,
    pricing,
    photos,
    website,
    phoneNumber,
    operatingHours,
    tags,
    createdAt,
    updatedAt,
  ];

  Place copyWith({
    String? id,
    String? name,
    String? description,
    double? latitude,
    double? longitude,
    String? address,
    PlaceCategory? category,
    List<String>? amenities,
    double? averageRating,
    int? reviewCount,
    Map<String, dynamic>? pricing,
    List<String>? photos,
    String? website,
    String? phoneNumber,
    Map<String, dynamic>? operatingHours,
    List<String>? tags,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Place(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      category: category ?? this.category,
      amenities: amenities ?? this.amenities,
      averageRating: averageRating ?? this.averageRating,
      reviewCount: reviewCount ?? this.reviewCount,
      pricing: pricing ?? this.pricing,
      photos: photos ?? this.photos,
      website: website ?? this.website,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      operatingHours: operatingHours ?? this.operatingHours,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Helper method to get formatted address
  String get formattedAddress => address ?? '${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}';

  // Helper method to check if place is open (if operating hours available)
  bool? isOpenNow() {
    if (operatingHours == null) return null;

    // This would need more complex logic based on your operating hours format
    // For now, return null as placeholder
    return null;
  }

  /// Convert Place to JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'category': category.name, // Convert enum to string
      'amenities': amenities,
      'averageRating': averageRating,
      'reviewCount': reviewCount,
      'pricing': pricing,
      'photos': photos,
      'website': website,
      'phoneNumber': phoneNumber,
      'operatingHours': operatingHours,
      'tags': tags,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}