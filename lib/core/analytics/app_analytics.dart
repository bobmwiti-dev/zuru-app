import 'package:flutter/foundation.dart';

import '../../data/repositories/analytics_repository.dart';
import '../logging/logger.dart';

/// App analytics service for tracking user behavior and app performance
class AppAnalytics {
  final AnalyticsRepository _repository;
  final Logger _logger;
  final String Function()? _getCurrentUserId;

  AppAnalytics(this._repository, this._logger, [this._getCurrentUserId]);

  /// Initialize analytics service
  Future<void> initialize() async {
    _logger.info('Analytics initialized successfully');
  }

  /// Track screen view
  Future<void> trackScreenView(String screenName, {String? screenClass}) async {
    try {
      final userId = _getCurrentUserId?.call() ?? 'anonymous';
      await _repository.logScreenView(
        userId: userId,
        screenName: screenName,
        parameters: {'screen_class': screenClass ?? screenName},
      );

      _logger.debug('Screen view tracked: $screenName');
    } catch (e, stackTrace) {
      _logger.error('Failed to track screen view', e, stackTrace);
    }
  }

  /// Track user action
  Future<void> trackUserAction(
    String action, {
    Map<String, dynamic>? parameters,
  }) async {
    try {
      final userId = _getCurrentUserId?.call() ?? 'anonymous';
      await _repository.logUserAction(
        userId: userId,
        action: action,
        parameters: parameters,
      );
      _logger.debug('User action tracked: $action');
    } catch (e, stackTrace) {
      _logger.error('Failed to track user action', e, stackTrace);
    }
  }

  /// Track memory creation
  Future<void> trackMemoryCreated({
    required String memoryId,
    required String mood,
    required bool hasPhoto,
    required bool hasLocation,
    required int characterCount,
  }) async {
    // Note: We don't have a specific entry object here, so we'll use logUserAction
    await trackUserAction(
      'memory_created',
      parameters: {
        'memory_id': memoryId,
        'mood': mood,
        'has_photo': hasPhoto,
        'has_location': hasLocation,
        'character_count': characterCount,
      },
    );
  }

  /// Track memory viewed
  Future<void> trackMemoryViewed({
    required String memoryId,
    required String source, // 'feed', 'search', 'friend', 'notification'
  }) async {
    await trackEvent(
      AnalyticsEvent.memoryViewed,
      parameters: {'memory_id': memoryId, 'source': source},
    );
  }

  /// Track memory shared
  Future<void> trackMemoryShared({
    required String memoryId,
    required String platform, // 'whatsapp', 'facebook', 'twitter', etc.
    required String privacyLevel, // 'public', 'friends', 'link'
  }) async {
    await trackEvent(
      AnalyticsEvent.memoryShared,
      parameters: {
        'memory_id': memoryId,
        'platform': platform,
        'privacy_level': privacyLevel,
      },
    );
  }

  /// Track social interaction
  Future<void> trackSocialInteraction({
    required String
    interactionType, // 'friend_request', 'accept_request', 'message'
    required String targetUserId,
  }) async {
    await trackEvent(
      AnalyticsEvent.socialInteraction,
      parameters: {
        'interaction_type': interactionType,
        'target_user_id': targetUserId,
      },
    );
  }

  /// Track search performed
  Future<void> trackSearch({
    required String searchQuery,
    required String searchType, // 'memories', 'users', 'locations'
    required int resultCount,
  }) async {
    try {
      final userId = _getCurrentUserId?.call() ?? 'anonymous';
      await _repository.logSearch(
        userId: userId,
        query: searchQuery,
        searchType: searchType,
        resultCount: resultCount,
      );
      _logger.debug('Search tracked: $searchQuery');
    } catch (e, stackTrace) {
      _logger.error('Failed to track search', e, stackTrace);
    }
  }

  /// Track mood logged
  Future<void> trackMoodLogged({
    required String mood,
    required int intensity,
    required bool hasNote,
  }) async {
    await trackEvent(
      AnalyticsEvent.moodLogged,
      parameters: {'mood': mood, 'intensity': intensity, 'has_note': hasNote},
    );
  }

  /// Track AI insight viewed
  Future<void> trackAIInsightViewed({
    required String
    insightType, // 'mood_pattern', 'location_recommendation', 'personalized_suggestion'
    required String insightId,
  }) async {
    await trackEvent(
      AnalyticsEvent.aiInsightViewed,
      parameters: {'insight_type': insightType, 'insight_id': insightId},
    );
  }

  /// Track app performance
  Future<void> trackPerformance({
    required String metric,
    required double value,
    required String unit, // 'ms', 'MB', 'count'
  }) async {
    await trackEvent(
      AnalyticsEvent.performanceMetric,
      parameters: {'metric': metric, 'value': value, 'unit': unit},
    );
  }

  /// Track error occurred
  Future<void> trackError({
    required String errorType,
    required String errorMessage,
    required bool isFatal,
  }) async {
    await trackEvent(
      AnalyticsEvent.errorOccurred,
      parameters: {
        'error_type': errorType,
        'error_message': errorMessage,
        'is_fatal': isFatal,
      },
    );
  }

  /// Track user engagement
  Future<void> trackEngagement({
    required String feature,
    required String action,
    required Duration duration,
  }) async {
    await trackEvent(
      AnalyticsEvent.userEngagement,
      parameters: {
        'feature': feature,
        'action': action,
        'duration_seconds': duration.inSeconds,
      },
    );
  }

  /// Set user properties for analytics
  Future<void> setUserProperties({
    String? userId,
    String? userType, // 'free', 'premium'
    int? memoryCount,
    int? friendCount,
    String? preferredMood,
    String? appLanguage,
  }) async {
    if (userId == null) {
      _logger.warning('Cannot set user properties: userId is null');
      return;
    }

    final properties = <String, String>{};

    if (userType != null) properties['user_type'] = userType;
    if (memoryCount != null) {
      properties['memory_count'] = memoryCount.toString();
    }
    if (friendCount != null) {
      properties['friend_count'] = friendCount.toString();
    }
    if (preferredMood != null) properties['preferred_mood'] = preferredMood;
    if (appLanguage != null) properties['app_language'] = appLanguage;

    await _repository.setUserProperties(
      userId: userId,
      properties: properties.isNotEmpty ? properties : null,
    );

    _logger.debug('User properties set for user $userId');
  }

  /// Track custom event
  Future<void> trackEvent(
    String eventName, {
    Map<String, dynamic>? parameters,
  }) async {
    try {
      final userId = _getCurrentUserId?.call() ?? 'anonymous';
      await _repository.logUserAction(
        userId: userId,
        action: eventName,
        parameters: parameters,
      );
      _logger.debug('Event tracked: $eventName, parameters: $parameters');
    } catch (e, stackTrace) {
      _logger.error('Failed to track event: $eventName', e, stackTrace);
    }
  }

  /// Track app lifecycle events
  Future<void> trackAppLifecycle(String event) async {
    await trackEvent(
      'app_lifecycle',
      parameters: {
        'event': event, // 'foreground', 'background', 'launch', 'terminate'
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  /// Track feature usage
  Future<void> trackFeatureUsage({
    required String featureName,
    required String action,
    Map<String, dynamic>? metadata,
  }) async {
    await trackEvent(
      AnalyticsEvent.featureUsed,
      parameters: {
        'feature': featureName,
        'action': action,
        'metadata': metadata ?? {},
      },
    );
  }

  /// Reset analytics data (for privacy/GDPR compliance)
  Future<void> resetAnalyticsData() async {
    try {
      // Reset Firebase Analytics data for the current user
      await _repository.resetAnalyticsData(
        _getCurrentUserId?.call() ?? 'anonymous',
      );
      _logger.info('Analytics data reset successfully');
    } catch (e) {
      _logger.error('Failed to reset analytics data', e);
      rethrow;
    }
  }
}

/// Analytics event constants
class AnalyticsEvent {
  // User actions
  static const String screenView = 'screen_view';
  static const String userAction = 'user_action';

  // Memory events
  static const String memoryCreated = 'memory_created';
  static const String memoryViewed = 'memory_viewed';
  static const String memoryEdited = 'memory_edited';
  static const String memoryDeleted = 'memory_deleted';
  static const String memoryShared = 'memory_shared';

  // Social events
  static const String socialInteraction = 'social_interaction';
  static const String friendRequestSent = 'friend_request_sent';
  static const String friendRequestAccepted = 'friend_request_accepted';

  // Search and discovery
  static const String searchPerformed = 'search_performed';
  static const String locationDiscovered = 'location_discovered';
  static const String friendDiscovered = 'friend_discovered';

  // Mood and wellness
  static const String moodLogged = 'mood_logged';
  static const String moodTrendViewed = 'mood_trend_viewed';

  // AI features
  static const String aiInsightViewed = 'ai_insight_viewed';
  static const String aiRecommendationUsed = 'ai_recommendation_used';

  // Technical events
  static const String performanceMetric = 'performance_metric';
  static const String errorOccurred = 'error_occurred';
  static const String featureUsed = 'feature_used';
  static const String userEngagement = 'user_engagement';

  // Business metrics
  static const String subscriptionStarted = 'subscription_started';
  static const String subscriptionCancelled = 'subscription_cancelled';
  static const String inAppPurchase = 'in_app_purchase';
}

/// Analytics utilities
class AnalyticsUtils {
  /// Format duration for analytics
  static int formatDuration(Duration duration) {
    return duration.inSeconds;
  }

  /// Get platform-specific event parameters
  static Map<String, dynamic> getPlatformParameters() {
    return {
      'platform': defaultTargetPlatform.toString().split('.').last,
      'is_web': kIsWeb,
    };
  }

  /// Check if event should be tracked based on privacy settings
  static bool shouldTrackEvent(String eventName, {bool respectPrivacy = true}) {
    if (!respectPrivacy) return true;

    // Define events that should always be tracked (non-personal)
    const alwaysTrackEvents = [
      AnalyticsEvent.screenView,
      AnalyticsEvent.performanceMetric,
      AnalyticsEvent.errorOccurred,
    ];

    return alwaysTrackEvents.contains(eventName);
  }
}

/// Analytics privacy manager
class AnalyticsPrivacyManager {
  /// Check if user has consented to analytics
  static Future<bool> hasAnalyticsConsent() async {
    // Implementation would check shared preferences
    // For now, return true
    return true;
  }

  /// Set analytics consent
  static Future<void> setAnalyticsConsent(bool consent) async {
    // Implementation would save to shared preferences
    // This affects whether personal events are tracked
  }

  /// Get privacy-friendly event parameters
  static Map<String, dynamic> getPrivacySafeParameters(
    Map<String, dynamic> parameters,
  ) {
    // Remove or anonymize personal information
    final safeParams = Map<String, dynamic>.from(parameters);

    // Remove potentially sensitive data
    safeParams.removeWhere((key, value) {
      return key.contains('email') ||
          key.contains('phone') ||
          key.contains('name') ||
          key.contains('location') &&
              value is String &&
              value.length > 100; // Detailed addresses
    });

    return safeParams;
  }
}
