import 'dart:math';

import '../../domain/entities/journal_entry.dart';
import '../../domain/entities/place.dart';
import '../../domain/entities/mood.dart';
import '../../data/models/journal_entry_model.dart';
import '../../data/models/place_model.dart';
import '../../data/models/mood_model.dart';
import '../../data/datasources/remote/firestore/journal_firestore_datasource.dart';

/// Abstract journal repository
abstract class JournalRepository {
  /// Create a new journal entry
  Future<JournalEntry> createEntry(JournalEntry entry);

  /// Get journal entry by ID
  Future<JournalEntry?> getEntry(String id);

  /// Get all journal entries for a user
  Future<List<JournalEntry>> getEntries({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
    int? offset,
  });

  /// Update journal entry
  Future<JournalEntry> updateEntry(JournalEntry entry);

  /// Delete journal entry
  Future<void> deleteEntry(String id);

  /// Search journal entries
  Future<List<JournalEntry>> searchEntries({
    required String userId,
    required String query,
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Get entries by mood
  Future<List<JournalEntry>> getEntriesByMood({
    required String userId,
    required MoodType mood,
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Get entries by place
  Future<List<JournalEntry>> getEntriesByPlace({
    required String userId,
    required String placeId,
  });

  /// Get entries by tags
  Future<List<JournalEntry>> getEntriesByTags({
    required String userId,
    required List<String> tags,
  });

  /// Get recent entries
  Future<List<JournalEntry>> getRecentEntries({
    required String userId,
    int limit = 10,
  });

  /// Get entries count
  Future<int> getEntriesCount({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
  });
}

/// Journal repository implementation
class JournalRepositoryImpl implements JournalRepository {
  final FirestoreDataSource _firestoreDataSource;

  JournalRepositoryImpl(this._firestoreDataSource);

  @override
  Future<JournalEntry> createEntry(JournalEntry entry) async {
    final entryData = {
      'id': entry.id,
      'userId': entry.userId,
      'title': entry.title,
      'description': entry.description,
      'photos': entry.photos,
      'videos': entry.videos,
      'rating': entry.rating,
      'tags': entry.tags,
      'mood':
          entry.mood != null
              ? MoodModel.fromEntity(entry.mood!).toJson()
              : null,
      'place': PlaceModel.fromEntity(entry.place).toJson(),
      'privacyLevel': entry.privacyLevel.name,
      'reflection': entry.reflection,
      'metadata': entry.metadata,
      'companionIds': entry.companionIds,
      'cost': entry.cost,
      'weather': entry.weather,
      'temperature': entry.temperature,
    };

    final docRef = await _firestoreDataSource.createJournalEntry(entryData);
    return entry.copyWith(id: docRef.id);
  }

  @override
  Future<JournalEntry?> getEntry(String id) async {
    final docSnapshot = await _firestoreDataSource.getJournalEntry(id);
    if (!docSnapshot.exists || docSnapshot.data() == null) {
      return null;
    }

    final data = docSnapshot.data()!;
    return JournalEntryModel.fromJson(data).toEntity();
  }

  @override
  Future<List<JournalEntry>> getEntries({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
    int? offset,
  }) async {
    final querySnapshot = await _firestoreDataSource.getUserJournalEntries(
      userId,
      startDate: startDate,
      endDate: endDate,
      limit: limit,
    );

    final entries =
        querySnapshot.docs.map((doc) {
          return JournalEntryModel.fromJson(doc.data()).toEntity();
        }).toList();

    // Apply offset if specified
    if (offset != null && offset > 0 && entries.length > offset) {
      return entries.sublist(offset);
    }

    return entries;
  }

  @override
  Future<JournalEntry> updateEntry(JournalEntry entry) async {
    final updates = {
      'title': entry.title,
      'description': entry.description,
      'photos': entry.photos,
      'videos': entry.videos,
      'rating': entry.rating,
      'tags': entry.tags,
      'mood':
          entry.mood != null
              ? MoodModel.fromEntity(entry.mood!).toJson()
              : null,
      'place': PlaceModel.fromEntity(entry.place).toJson(),
      'privacyLevel': entry.privacyLevel.name,
      'reflection': entry.reflection,
      'metadata': entry.metadata,
      'companionIds': entry.companionIds,
      'cost': entry.cost,
      'weather': entry.weather,
      'temperature': entry.temperature,
    };

    await _firestoreDataSource.updateJournalEntry(entry.id, updates);
    return entry;
  }

  @override
  Future<void> deleteEntry(String id) async {
    await _firestoreDataSource.deleteJournalEntry(id);
  }

  @override
  Future<List<JournalEntry>> searchEntries({
    required String userId,
    required String query,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    // Use Firestore search functionality
    final querySnapshot = await _firestoreDataSource.searchJournalEntries(
      userId,
      query,
    );

    return querySnapshot.docs.map((doc) {
      return JournalEntryModel.fromJson(doc.data()).toEntity();
    }).toList();
  }

  @override
  Future<List<JournalEntry>> getEntriesByMood({
    required String userId,
    required MoodType mood,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    // Mock implementation
    await Future.delayed(const Duration(milliseconds: 300));

    final entries = await getEntries(
      userId: userId,
      startDate: startDate,
      endDate: endDate,
    );

    return entries.where((entry) => entry.mood?.type == mood).toList();
  }

  @override
  Future<List<JournalEntry>> getEntriesByPlace({
    required String userId,
    required String placeId,
  }) async {
    // Mock implementation
    await Future.delayed(const Duration(milliseconds: 300));

    final entries = await getEntries(userId: userId);
    return entries.where((entry) => entry.place.id == placeId).toList();
  }

  @override
  Future<List<JournalEntry>> getEntriesByTags({
    required String userId,
    required List<String> tags,
  }) async {
    // Mock implementation
    await Future.delayed(const Duration(milliseconds: 300));

    final entries = await getEntries(userId: userId);
    return entries.where((entry) {
      return tags.any((tag) => entry.tags.contains(tag));
    }).toList();
  }

  @override
  Future<List<JournalEntry>> getRecentEntries({
    required String userId,
    int limit = 10,
  }) async {
    return getEntries(userId: userId, limit: limit);
  }

  @override
  Future<int> getEntriesCount({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    // Mock implementation
    await Future.delayed(const Duration(milliseconds: 200));

    final entries = await getEntries(
      userId: userId,
      startDate: startDate,
      endDate: endDate,
    );

    return entries.length;
  }
}

/// Location repository
abstract class LocationRepository {
  /// Search places by query
  Future<List<Place>> searchPlaces(String query, {int limit = 20});

  /// Get place details by ID
  Future<Place?> getPlaceDetails(String placeId);

  /// Get nearby places
  Future<List<Place>> getNearbyPlaces({
    required double latitude,
    required double longitude,
    double radiusKm = 5.0,
    String? category,
  });

  /// Get places by category
  Future<List<Place>> getPlacesByCategory({
    required String category,
    double? latitude,
    double? longitude,
    int limit = 20,
  });

  /// Save place to favorites
  Future<void> saveFavoritePlace(String userId, String placeId);

  /// Remove place from favorites
  Future<void> removeFavoritePlace(String userId, String placeId);

  /// Get user's favorite places
  Future<List<Place>> getFavoritePlaces(String userId);

  /// Check if place is favorited
  Future<bool> isPlaceFavorited(String userId, String placeId);
}

/// Location repository implementation
class LocationRepositoryImpl implements LocationRepository {
  // Implementation with geocoding integration and realistic mock data
  // For production, integrate with Google Places API:
  // 1. Add google_places_api package to pubspec.yaml
  // 2. Get API key from Google Cloud Console
  // 3. Implement actual API calls in each method

  final List<Place> _mockPlaces = [
    Place(
      id: 'place_1',
      name: 'Java House Westlands',
      address: 'Westlands Square, Nairobi, Kenya',
      latitude: -1.2630,
      longitude: 36.8065,
      category: PlaceCategory.restaurant,
      averageRating: 4.2,
      pricing: {'level': 2, 'currency': 'KES'},
      photos: [
        'https://images.unsplash.com/photo-1559496417-e7f25cb247f3?w=400',
      ],
      description: 'Popular coffee shop chain in Nairobi',
    ),
    Place(
      id: 'place_2',
      name: 'Nairobi National Park',
      address: 'Nairobi, Kenya',
      latitude: -1.3689,
      longitude: 36.8581,
      category: PlaceCategory.park,
      averageRating: 4.5,
      pricing: {'level': 1, 'entryFee': 500, 'currency': 'KES'},
      photos: [
        'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=400',
      ],
      description: 'Kenya\'s first national park',
    ),
    Place(
      id: 'place_3',
      name: 'Koinange Street',
      address: 'Central Business District, Nairobi, Kenya',
      latitude: -1.2833,
      longitude: 36.8167,
      category: PlaceCategory.shop,
      averageRating: 3.8,
      pricing: {'level': 1, 'currency': 'KES'},
      photos: [
        'https://images.unsplash.com/photo-1449824913935-59a10b8d2000?w=400',
      ],
      description: 'Historic street market in Nairobi CBD',
    ),
    Place(
      id: 'place_4',
      name: 'Giraffe Centre',
      address: 'Karen, Nairobi, Kenya',
      latitude: -1.3733,
      longitude: 36.7167,
      category: PlaceCategory.attraction,
      averageRating: 4.3,
      pricing: {'level': 2, 'entryFee': 1000, 'currency': 'KES'},
      photos: [
        'https://images.unsplash.com/photo-1551632436-cbf8dd35adfa?w=400',
      ],
      description:
          'Wildlife conservation center famous for Rothschild giraffes',
    ),
    Place(
      id: 'place_5',
      name: 'Carnivore Restaurant',
      address: 'Langata Road, Nairobi, Kenya',
      latitude: -1.3333,
      longitude: 36.7833,
      category: PlaceCategory.restaurant,
      averageRating: 4.4,
      pricing: {'level': 3, 'currency': 'KES'},
      photos: [
        'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=400',
      ],
      description: 'Famous restaurant serving African game meat',
    ),
    Place(
      id: 'place_6',
      name: 'University of Nairobi',
      address: 'University Way, Nairobi, Kenya',
      latitude: -1.2798,
      longitude: 36.8167,
      category: PlaceCategory.cultural,
      averageRating: 4.1,
      pricing: {'level': 1, 'currency': 'KES'},
      photos: [
        'https://images.unsplash.com/photo-1565688534245-05d6b5be184a?w=400',
      ],
      description: 'Kenya\'s oldest university',
    ),
  ];

  @override
  Future<List<Place>> searchPlaces(String query, {int limit = 20}) async {
    // Simulate API call delay
    await Future.delayed(const Duration(milliseconds: 500));

    if (query.isEmpty) {
      return _mockPlaces.take(limit).toList();
    }

    // Search by name, address, or description
    final results =
        _mockPlaces.where((place) {
          final searchTerm = query.toLowerCase();
          return place.name.toLowerCase().contains(searchTerm) ||
              (place.address?.toLowerCase().contains(searchTerm) ?? false) ||
              (place.description?.toLowerCase().contains(searchTerm) ?? false);
        }).toList();

    // Sort by relevance (name matches first, then address, then description)
    results.sort((a, b) {
      final aNameMatch = a.name.toLowerCase().contains(query.toLowerCase());
      final bNameMatch = b.name.toLowerCase().contains(query.toLowerCase());

      if (aNameMatch && !bNameMatch) return -1;
      if (!aNameMatch && bNameMatch) return 1;

      // If both match names or both don't, sort by averageRating
      final aRating = a.averageRating ?? 0.0;
      final bRating = b.averageRating ?? 0.0;
      return bRating.compareTo(aRating);
    });

    return results.take(limit).toList();
  }

  @override
  Future<Place?> getPlaceDetails(String placeId) async {
    // Mock implementation
    await Future.delayed(const Duration(milliseconds: 300));
    return _mockPlaces.cast<Place?>().firstWhere(
      (place) => place?.id == placeId,
      orElse: () => null,
    );
  }

  @override
  Future<List<Place>> getNearbyPlaces({
    required double latitude,
    required double longitude,
    double radiusKm = 5.0,
    String? category,
  }) async {
    // Simulate API call delay
    await Future.delayed(const Duration(milliseconds: 400));

    // Filter places by distance and category
    final nearbyPlaces =
        _mockPlaces.where((place) {
          // Calculate distance using Haversine formula
          final distance = _calculateDistance(
            latitude,
            longitude,
            place.latitude,
            place.longitude,
          );

          // Check if within radius
          final withinRadius = distance <= radiusKm;

          // Check category filter if provided
          final categoryMatch =
              category == null ||
              place.category.name.toLowerCase() == category.toLowerCase();

          return withinRadius && categoryMatch;
        }).toList();

    // Sort by distance (closest first)
    nearbyPlaces.sort((a, b) {
      final distanceA = _calculateDistance(
        latitude,
        longitude,
        a.latitude,
        a.longitude,
      );
      final distanceB = _calculateDistance(
        latitude,
        longitude,
        b.latitude,
        b.longitude,
      );
      return distanceA.compareTo(distanceB);
    });

    return nearbyPlaces;
  }

  /// Calculate distance between two points using Haversine formula
  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double earthRadius = 6371; // Earth's radius in kilometers

    final double dLat = _degreesToRadians(lat2 - lat1);
    final double dLon = _degreesToRadians(lon2 - lon1);

    final double a =
        (sin(dLat / 2) * sin(dLat / 2)) +
        cos(_degreesToRadians(lat1)) *
            cos(_degreesToRadians(lat2)) *
            (sin(dLon / 2) * sin(dLon / 2));

    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * pi / 180;
  }

  @override
  Future<List<Place>> getPlacesByCategory({
    required String category,
    double? latitude,
    double? longitude,
    int limit = 20,
  }) async {
    // Mock implementation
    await Future.delayed(const Duration(milliseconds: 400));
    return _mockPlaces
        .where((place) => place.category.toString().split('.').last == category)
        .take(limit)
        .toList();
  }

  @override
  Future<void> saveFavoritePlace(String userId, String placeId) async {
    // Mock implementation
    await Future.delayed(const Duration(milliseconds: 200));
  }

  @override
  Future<void> removeFavoritePlace(String userId, String placeId) async {
    // Mock implementation
    await Future.delayed(const Duration(milliseconds: 200));
  }

  @override
  Future<List<Place>> getFavoritePlaces(String userId) async {
    // Mock implementation
    await Future.delayed(const Duration(milliseconds: 300));
    return []; // Would return user's favorite places
  }

  @override
  Future<bool> isPlaceFavorited(String userId, String placeId) async {
    // Mock implementation
    await Future.delayed(const Duration(milliseconds: 200));
    return false; // Would check if place is favorited
  }
}
