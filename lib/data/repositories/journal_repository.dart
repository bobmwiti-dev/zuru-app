import '../../domain/entities/journal_entry.dart';
import '../../domain/entities/place.dart';
import '../../domain/entities/mood.dart';

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
  // TODO: Implement with Firebase Firestore or local database
  // For now, using in-memory storage for demo purposes

  final Map<String, JournalEntry> _entries = {};

  @override
  Future<JournalEntry> createEntry(JournalEntry entry) async {
    // Mock implementation
    await Future.delayed(const Duration(milliseconds: 500));
    _entries[entry.id] = entry;
    return entry;
  }

  @override
  Future<JournalEntry?> getEntry(String id) async {
    // Mock implementation
    await Future.delayed(const Duration(milliseconds: 200));
    return _entries[id];
  }

  @override
  Future<List<JournalEntry>> getEntries({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
    int? offset,
  }) async {
    // Mock implementation
    await Future.delayed(const Duration(milliseconds: 300));

    var entries = _entries.values
        .where((entry) => entry.userId == userId)
        .toList();

    // Filter by date range
    if (startDate != null) {
      entries = entries.where((entry) => entry.createdAt.isAfter(startDate)).toList();
    }
    if (endDate != null) {
      entries = entries.where((entry) => entry.createdAt.isBefore(endDate)).toList();
    }

    // Sort by creation date (newest first)
    entries.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    // Apply pagination
    final startIndex = offset ?? 0;
    final endIndex = limit != null ? startIndex + limit : entries.length;

    return entries.sublist(
      startIndex,
      endIndex > entries.length ? entries.length : endIndex,
    );
  }

  @override
  Future<JournalEntry> updateEntry(JournalEntry entry) async {
    // Mock implementation
    await Future.delayed(const Duration(milliseconds: 400));
    _entries[entry.id] = entry;
    return entry;
  }

  @override
  Future<void> deleteEntry(String id) async {
    // Mock implementation
    await Future.delayed(const Duration(milliseconds: 300));
    _entries.remove(id);
  }

  @override
  Future<List<JournalEntry>> searchEntries({
    required String userId,
    required String query,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    // Mock implementation
    await Future.delayed(const Duration(milliseconds: 400));

    final entries = await getEntries(
      userId: userId,
      startDate: startDate,
      endDate: endDate,
    );

    final lowercaseQuery = query.toLowerCase();
    return entries.where((entry) {
      return entry.title.toLowerCase().contains(lowercaseQuery) ||
             (entry.description?.toLowerCase().contains(lowercaseQuery) ?? false) ||
             entry.tags.any((tag) => tag.toLowerCase().contains(lowercaseQuery));
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
  // TODO: Implement with Google Places API or similar
  // For now, using mock data

  final List<Place> _mockPlaces = [
    // Mock places would be here
  ];

  @override
  Future<List<Place>> searchPlaces(String query, {int limit = 20}) async {
    // Mock implementation
    await Future.delayed(const Duration(milliseconds: 500));

    // Return mock places that match query
    return _mockPlaces
        .where((place) => place.name.toLowerCase().contains(query.toLowerCase()))
        .take(limit)
        .toList();
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
    // Mock implementation
    await Future.delayed(const Duration(milliseconds: 400));
    return _mockPlaces; // Would filter by distance and category
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