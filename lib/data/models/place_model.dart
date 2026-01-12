import 'package:json_annotation/json_annotation.dart';
import 'package:zuru_app/domain/entities/place.dart';

part 'place_model.g.dart';

@JsonSerializable()
class PlaceModel extends Place {
  const PlaceModel({
    required super.id,
    required super.name,
    required super.latitude,
    required super.longitude,
    required super.category,
    super.description,
    super.address,
    super.amenities,
    super.averageRating,
    super.reviewCount,
    super.pricing,
    super.photos,
    super.website,
    super.phoneNumber,
    super.operatingHours,
    super.tags,
    super.createdAt,
    super.updatedAt,
  });

  factory PlaceModel.fromJson(Map<String, dynamic> json) =>
      _$PlaceModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$PlaceModelToJson(this);

  factory PlaceModel.fromEntity(Place place) {
    return PlaceModel(
      id: place.id,
      name: place.name,
      description: place.description,
      latitude: place.latitude,
      longitude: place.longitude,
      address: place.address,
      category: place.category,
      amenities: place.amenities,
      averageRating: place.averageRating,
      reviewCount: place.reviewCount,
      pricing: place.pricing,
      photos: place.photos,
      website: place.website,
      phoneNumber: place.phoneNumber,
      operatingHours: place.operatingHours,
      tags: place.tags,
      createdAt: place.createdAt,
      updatedAt: place.updatedAt,
    );
  }

  Place toEntity() {
    return Place(
      id: id,
      name: name,
      description: description,
      latitude: latitude,
      longitude: longitude,
      address: address,
      category: category,
      amenities: amenities,
      averageRating: averageRating,
      reviewCount: reviewCount,
      pricing: pricing,
      photos: photos,
      website: website,
      phoneNumber: phoneNumber,
      operatingHours: operatingHours,
      tags: tags,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}