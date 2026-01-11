import '../../domain/entities/mood.dart';
import '../../domain/entities/journal_entry.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

/// Abstract analytics repository
abstract class AnalyticsRepository {
  /// Log user action
  Future<void> logUserAction({
    required String userId,
    required String action,
    Map<String, dynamic>? parameters,
  });

  /// Log screen view
  Future<void> logScreenView({
    required String userId,
    required String screenName,
    Map<String, dynamic>? parameters,
  });

  /// Log mood tracking
  Future<void> logMoodTracking({required String userId, required Mood mood});

  /// Log journal entry creation
  Future<void> logJournalEntry({
    required String userId,
    required JournalEntry entry,
  });

  /// Log search query
  Future<void> logSearch({
    required String userId,
    required String query,
    required String searchType,
    int resultCount = 0,
  });

  /// Log error
  Future<void> logError({
    required String userId,
    required String errorMessage,
    String? errorCode,
    Map<String, dynamic>? context,
  });

  /// Log app lifecycle event
  Future<void> logAppLifecycle({
    required String userId,
    required String event,
    Map<String, dynamic>? parameters,
  });

  /// Get user engagement metrics
  Future<Map<String, dynamic>> getUserEngagementMetrics(String userId);

  /// Get mood analytics data
  Future<Map<String, dynamic>> getMoodAnalytics(
    String userId, {
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Get journal analytics data
  Future<Map<String, dynamic>> getJournalAnalytics(
    String userId, {
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Get location analytics data
  Future<Map<String, dynamic>> getLocationAnalytics(
    String userId, {
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Set user properties for analytics
  Future<void> setUserProperties({
    required String userId,
    Map<String, String>? properties,
  });

  /// Reset analytics data for a user
  Future<void> resetAnalyticsData(String userId);
}

/// Analytics repository implementation
class AnalyticsRepositoryImpl implements AnalyticsRepository {
  final FirebaseAnalytics _analytics;

  AnalyticsRepositoryImpl(this._analytics);

  @override
  Future<void> logUserAction({
    required String userId,
    required String action,
    Map<String, dynamic>? parameters,
  }) async {
    await _analytics.setUserId(id: userId);

    // Convert parameters to Map<String, Object> and filter out null values
    final Map<String, Object>? validParameters = parameters != null
        ? Map.fromEntries(
            parameters.entries
                .where((entry) => entry.value != null)
                .map((entry) => MapEntry(entry.key, entry.value as Object)),
          )
        : null;

    await _analytics.logEvent(name: action, parameters: validParameters);
  }

  @override
  Future<void> logScreenView({
    required String userId,
    required String screenName,
    Map<String, dynamic>? parameters,
  }) async {
    await _analytics.setUserId(id: userId);

    // Convert parameters to Map<String, Object> and filter out null values
    final Map<String, Object>? validParameters = parameters != null
        ? Map.fromEntries(
            parameters.entries
                .where((entry) => entry.value != null)
                .map((entry) => MapEntry(entry.key, entry.value as Object)),
          )
        : null;

    await _analytics.logScreenView(
      screenName: screenName,
      screenClass: screenName,
      parameters: validParameters,
    );
  }

  @override
  Future<void> logMoodTracking({
    required String userId,
    required Mood mood,
  }) async {
    await _analytics.setUserId(id: userId);
    await _analytics.logEvent(
      name: AnalyticsEvents.moodLogged,
      parameters: {AnalyticsParameters.moodType: mood.type.name},
    );
  }

  @override
  Future<void> logJournalEntry({
    required String userId,
    required JournalEntry entry,
  }) async {
    await _analytics.setUserId(id: userId);
    await _analytics.logEvent(
      name: AnalyticsEvents.journalCreated,
      parameters: {AnalyticsParameters.entryId: entry.id},
    );
  }

  @override
  Future<void> logSearch({
    required String userId,
    required String query,
    required String searchType,
    int resultCount = 0,
  }) async {
    await _analytics.setUserId(id: userId);
    await _analytics.logSearch(
      searchTerm: query,
      parameters: {
        'search_type': searchType,
        AnalyticsParameters.resultCount: resultCount,
      },
    );
  }

  @override
  Future<void> logError({
    required String userId,
    required String errorMessage,
    String? errorCode,
    Map<String, dynamic>? context,
  }) async {
    await _analytics.setUserId(id: userId);

    // Build parameters map, filtering out null values
    final Map<String, Object> parameters = {
      'error_message': errorMessage,
    };

    if (errorCode != null) {
      parameters[AnalyticsParameters.errorCode] = errorCode;
    }

    if (context != null) {
      parameters['error_context'] = context;
    }

    await _analytics.logEvent(
      name: 'error_occurred',
      parameters: parameters,
    );
  }

  @override
  Future<void> logAppLifecycle({
    required String userId,
    required String event,
    Map<String, dynamic>? parameters,
  }) async {
    await _analytics.setUserId(id: userId);
    await _analytics.logEvent(
      name: 'app_lifecycle',
      parameters: {'lifecycle_event': event, ...?parameters},
    );
  }

  @override
  Future<Map<String, dynamic>> getUserEngagementMetrics(String userId) async {
    // Firebase Analytics doesn't provide historical data retrieval
    // In a production app, you would use Firebase Analytics data export to BigQuery
    // or integrate with another analytics service for historical data analysis
    // For now, returning mock data
    await Future.delayed(const Duration(milliseconds: 300));

    return {
      'totalScreenViews': 25,
      'totalJournalEntries': 12,
      'totalMoodTrackings': 8,
      'totalSearches': 5,
      'engagementScore': 6.2,
    };
  }

  @override
  Future<Map<String, dynamic>> getMoodAnalytics(
    String userId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    // Firebase Analytics doesn't provide historical data retrieval
    // In a production app, you would use Firebase Analytics data export to BigQuery
    // or integrate with another analytics service for historical data analysis
    // For now, returning mock data
    await Future.delayed(const Duration(milliseconds: 400));

    return {
      'totalMoodTrackings': 15,
      'moodDistribution': {'good': 8, 'excellent': 4, 'neutral': 3},
      'mostCommonMood': 'good',
      'averageMoodScore': 4.1,
    };
  }

  @override
  Future<Map<String, dynamic>> getJournalAnalytics(
    String userId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    // Firebase Analytics doesn't provide historical data retrieval
    // In a production app, you would use Firebase Analytics data export to BigQuery
    // or integrate with another analytics service for historical data analysis
    // For now, returning mock data
    await Future.delayed(const Duration(milliseconds: 400));

    return {
      'totalEntries': 24,
      'entriesThisWeek': 3,
      'entriesThisMonth': 12,
      'averageEntriesPerWeek': 2.8,
    };
  }

  @override
  Future<Map<String, dynamic>> getLocationAnalytics(
    String userId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    // Firebase Analytics doesn't provide historical data retrieval
    // In a production app, you would use Firebase Analytics data export to BigQuery
    // or integrate with another analytics service for historical data analysis
    // For now, returning mock data
    await Future.delayed(const Duration(milliseconds: 400));

    return {
      'uniquePlacesVisited': 8,
      'mostVisitedCategory': 'restaurant',
      'averageDistanceTraveled': 22.3, // km
      'locationInsights': [],
    };
  }

  @override
  Future<void> setUserProperties({
    required String userId,
    Map<String, String>? properties,
  }) async {
    await _analytics.setUserId(id: userId);

    if (properties != null) {
      for (final entry in properties.entries) {
        await _analytics.setUserProperty(name: entry.key, value: entry.value);
      }
    }
  }

  @override
  Future<void> resetAnalyticsData(String userId) async {
    await _analytics.resetAnalyticsData();
    await _analytics.setUserId(id: null);
  }
}

/// Analytics events constants
class AnalyticsEvents {
  // User actions
  static const String journalCreated = 'journal_created';
  static const String journalEdited = 'journal_edited';
  static const String journalDeleted = 'journal_deleted';
  static const String photoAdded = 'photo_added';
  static const String videoAdded = 'video_added';
  static const String locationTagged = 'location_tagged';
  static const String moodLogged = 'mood_logged';

  // Navigation
  static const String screenView = 'screen_view';
  static const String tabChanged = 'tab_changed';

  // Social features
  static const String friendAdded = 'friend_added';
  static const String memoryShared = 'memory_shared';
  static const String commentAdded = 'comment_added';

  // Search and discovery
  static const String searchPerformed = 'search_performed';
  static const String placeDiscovered = 'place_discovered';
  static const String filterApplied = 'filter_applied';

  // App lifecycle
  static const String appOpened = 'app_opened';
  static const String appClosed = 'app_closed';
  static const String sessionStarted = 'session_started';
  static const String sessionEnded = 'session_ended';
}

/// Analytics parameters constants
class AnalyticsParameters {
  static const String screenName = 'screen_name';
  static const String entryId = 'entry_id';
  static const String placeId = 'place_id';
  static const String moodType = 'mood_type';
  static const String searchQuery = 'search_query';
  static const String resultCount = 'result_count';
  static const String duration = 'duration';
  static const String errorCode = 'error_code';
}
