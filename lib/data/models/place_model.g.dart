// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'place_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PlaceModel _$PlaceModelFromJson(Map<String, dynamic> json) => PlaceModel(
  id: json['id'] as String,
  name: json['name'] as String,
  latitude: (json['latitude'] as num).toDouble(),
  longitude: (json['longitude'] as num).toDouble(),
  category: $enumDecode(_$PlaceCategoryEnumMap, json['category']),
  description: json['description'] as String?,
  address: json['address'] as String?,
  amenities:
      (json['amenities'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  averageRating: (json['averageRating'] as num?)?.toDouble(),
  reviewCount: (json['reviewCount'] as num?)?.toInt(),
  pricing: json['pricing'] as Map<String, dynamic>?,
  photos:
      (json['photos'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  website: json['website'] as String?,
  phoneNumber: json['phoneNumber'] as String?,
  operatingHours: json['operatingHours'] as Map<String, dynamic>?,
  tags:
      (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  createdAt:
      json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
  updatedAt:
      json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$PlaceModelToJson(PlaceModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'address': instance.address,
      'category': _$PlaceCategoryEnumMap[instance.category]!,
      'amenities': instance.amenities,
      'averageRating': instance.averageRating,
      'reviewCount': instance.reviewCount,
      'pricing': instance.pricing,
      'photos': instance.photos,
      'website': instance.website,
      'phoneNumber': instance.phoneNumber,
      'operatingHours': instance.operatingHours,
      'tags': instance.tags,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

const _$PlaceCategoryEnumMap = {
  PlaceCategory.restaurant: 'restaurant',
  PlaceCategory.cafe: 'cafe',
  PlaceCategory.bar: 'bar',
  PlaceCategory.hotel: 'hotel',
  PlaceCategory.attraction: 'attraction',
  PlaceCategory.park: 'park',
  PlaceCategory.museum: 'museum',
  PlaceCategory.shop: 'shop',
  PlaceCategory.event: 'event',
  PlaceCategory.accommodation: 'accommodation',
  PlaceCategory.entertainment: 'entertainment',
  PlaceCategory.nature: 'nature',
  PlaceCategory.cultural: 'cultural',
  PlaceCategory.other: 'other',
};
