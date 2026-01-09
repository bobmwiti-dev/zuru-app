import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Environment configuration for the app
/// Manages different settings for dev, staging, and production
class Environment {
  static late EnvironmentConfig _config;

  /// Current environment configuration
  static EnvironmentConfig get config => _config;

  /// Initialize environment configuration
  static Future<void> initialize([String? environment]) async {
    const env = String.fromEnvironment('ENVIRONMENT', defaultValue: 'dev');
    final configName = environment ?? env;

    try {
      // Load configuration from assets
      final configString = await rootBundle.loadString('assets/config/$configName.json');
      final configJson = json.decode(configString) as Map<String, dynamic>;

      _config = EnvironmentConfig.fromJson(configJson);
    } catch (e) {
      // Fallback to development configuration
      _config = _getDevelopmentConfig();
      debugPrint('Failed to load config for $configName, using development defaults: $e');
    }
  }

  /// Get development configuration as fallback
  static EnvironmentConfig _getDevelopmentConfig() {
    return const EnvironmentConfig(
      environment: 'dev',
      apiBaseUrl: 'https://api.zuru.dev',
      firebaseConfig: FirebaseConfig(
        apiKey: 'dev-api-key',
        authDomain: 'zuru-dev.firebaseapp.com',
        projectId: 'zuru-dev',
        storageBucket: 'zuru-dev.appspot.com',
        messagingSenderId: '123456789',
        appId: '1:123456789:web:abcdef123456',
      ),
      featureFlags: FeatureFlags(
        enableAnalytics: false,
        enableCrashReporting: false,
        enablePushNotifications: true,
        enableOfflineMode: true,
        enableSocialFeatures: true,
        enableAIInsights: false,
      ),
      appConfig: AppConfig(
        appName: 'Zuru Dev',
        version: '1.0.0-dev',
        buildNumber: '1',
        supportEmail: 'dev@zuru.app',
      ),
    );
  }

  /// Check if current environment is development
  static bool get isDevelopment => _config.environment == 'dev';

  /// Check if current environment is staging
  static bool get isStaging => _config.environment == 'staging';

  /// Check if current environment is production
  static bool get isProduction => _config.environment == 'prod';

  /// Get current environment name
  static String get environmentName => _config.environment;
}

/// Main environment configuration
class EnvironmentConfig {
  final String environment;
  final String apiBaseUrl;
  final FirebaseConfig firebaseConfig;
  final FeatureFlags featureFlags;
  final AppConfig appConfig;

  const EnvironmentConfig({
    required this.environment,
    required this.apiBaseUrl,
    required this.firebaseConfig,
    required this.featureFlags,
    required this.appConfig,
  });

  factory EnvironmentConfig.fromJson(Map<String, dynamic> json) {
    return EnvironmentConfig(
      environment: json['environment'] as String,
      apiBaseUrl: json['apiBaseUrl'] as String,
      firebaseConfig: FirebaseConfig.fromJson(json['firebase'] as Map<String, dynamic>),
      featureFlags: FeatureFlags.fromJson(json['features'] as Map<String, dynamic>),
      appConfig: AppConfig.fromJson(json['app'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'environment': environment,
      'apiBaseUrl': apiBaseUrl,
      'firebase': firebaseConfig.toJson(),
      'features': featureFlags.toJson(),
      'app': appConfig.toJson(),
    };
  }
}

/// Firebase configuration
class FirebaseConfig {
  final String apiKey;
  final String authDomain;
  final String projectId;
  final String storageBucket;
  final String messagingSenderId;
  final String appId;

  const FirebaseConfig({
    required this.apiKey,
    required this.authDomain,
    required this.projectId,
    required this.storageBucket,
    required this.messagingSenderId,
    required this.appId,
  });

  factory FirebaseConfig.fromJson(Map<String, dynamic> json) {
    return FirebaseConfig(
      apiKey: json['apiKey'] as String,
      authDomain: json['authDomain'] as String,
      projectId: json['projectId'] as String,
      storageBucket: json['storageBucket'] as String,
      messagingSenderId: json['messagingSenderId'] as String,
      appId: json['appId'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'apiKey': apiKey,
      'authDomain': authDomain,
      'projectId': projectId,
      'storageBucket': storageBucket,
      'messagingSenderId': messagingSenderId,
      'appId': appId,
    };
  }
}

/// Feature flags for enabling/disabling features
class FeatureFlags {
  final bool enableAnalytics;
  final bool enableCrashReporting;
  final bool enablePushNotifications;
  final bool enableOfflineMode;
  final bool enableSocialFeatures;
  final bool enableAIInsights;
  final bool enablePublicSharing;
  final bool enableAdvancedPrivacy;

  const FeatureFlags({
    required this.enableAnalytics,
    required this.enableCrashReporting,
    required this.enablePushNotifications,
    required this.enableOfflineMode,
    required this.enableSocialFeatures,
    required this.enableAIInsights,
    this.enablePublicSharing = true,
    this.enableAdvancedPrivacy = true,
  });

  factory FeatureFlags.fromJson(Map<String, dynamic> json) {
    return FeatureFlags(
      enableAnalytics: json['analytics'] as bool? ?? false,
      enableCrashReporting: json['crashReporting'] as bool? ?? false,
      enablePushNotifications: json['pushNotifications'] as bool? ?? true,
      enableOfflineMode: json['offlineMode'] as bool? ?? true,
      enableSocialFeatures: json['socialFeatures'] as bool? ?? true,
      enableAIInsights: json['aiInsights'] as bool? ?? false,
      enablePublicSharing: json['publicSharing'] as bool? ?? true,
      enableAdvancedPrivacy: json['advancedPrivacy'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'analytics': enableAnalytics,
      'crashReporting': enableCrashReporting,
      'pushNotifications': enablePushNotifications,
      'offlineMode': enableOfflineMode,
      'socialFeatures': enableSocialFeatures,
      'aiInsights': enableAIInsights,
      'publicSharing': enablePublicSharing,
      'advancedPrivacy': enableAdvancedPrivacy,
    };
  }
}

/// App configuration
class AppConfig {
  final String appName;
  final String version;
  final String buildNumber;
  final String supportEmail;
  final String? privacyPolicyUrl;
  final String? termsOfServiceUrl;

  const AppConfig({
    required this.appName,
    required this.version,
    required this.buildNumber,
    required this.supportEmail,
    this.privacyPolicyUrl,
    this.termsOfServiceUrl,
  });

  factory AppConfig.fromJson(Map<String, dynamic> json) {
    return AppConfig(
      appName: json['name'] as String,
      version: json['version'] as String,
      buildNumber: json['buildNumber'] as String,
      supportEmail: json['supportEmail'] as String,
      privacyPolicyUrl: json['privacyPolicyUrl'] as String?,
      termsOfServiceUrl: json['termsOfServiceUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': appName,
      'version': version,
      'buildNumber': buildNumber,
      'supportEmail': supportEmail,
      'privacyPolicyUrl': privacyPolicyUrl,
      'termsOfServiceUrl': termsOfServiceUrl,
    };
  }

  /// Get full version string
  String get fullVersion => '$version+$buildNumber';
}

/// Environment variables and constants
class EnvironmentConstants {
  // API endpoints
  static String get apiBaseUrl => Environment.config.apiBaseUrl;
  static String get memoriesEndpoint => '$apiBaseUrl/memories';
  static String get usersEndpoint => '$apiBaseUrl/users';
  static String get analyticsEndpoint => '$apiBaseUrl/analytics';

  // Firebase config
  static FirebaseConfig get firebaseConfig => Environment.config.firebaseConfig;

  // Feature flags
  static FeatureFlags get features => Environment.config.featureFlags;

  // App config
  static AppConfig get app => Environment.config.appConfig;

  // Timeouts
  static const Duration apiTimeout = Duration(seconds: 30);
  static const Duration imageUploadTimeout = Duration(minutes: 5);
  static const Duration locationTimeout = Duration(seconds: 10);

  // Cache settings
  static const Duration memoryCacheDuration = Duration(hours: 1);
  static const Duration locationCacheDuration = Duration(minutes: 30);
  static const int maxCacheSize = 100; // MB

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // Image settings
  static const int maxImageSize = 10 * 1024 * 1024; // 10MB
  static const double imageCompressionQuality = 0.8;
  static const int maxImageWidth = 2048;
  static const int maxImageHeight = 2048;

  // Location settings
  static const double defaultLocationAccuracy = 100.0; // meters
  static const int locationUpdateInterval = 30000; // milliseconds

  // Social features
  static const int maxFriendsLimit = 500;
  static const int maxMemorySharesPerDay = 50;
  static const int maxCommentsPerMemory = 100;

  // AI features
  static const int maxInsightsPerRequest = 10;
  static const Duration insightCacheDuration = Duration(hours: 6);
}

/// Environment utilities
class EnvironmentUtils {
  /// Get flavor name for the current environment
  static String getFlavorName() {
    switch (Environment.environmentName) {
      case 'dev':
        return 'Development';
      case 'staging':
        return 'Staging';
      case 'prod':
        return 'Production';
      default:
        return 'Unknown';
    }
  }

  /// Check if we should enable debug features
  static bool get enableDebugFeatures {
    return Environment.isDevelopment || Environment.isStaging;
  }

  /// Check if we should enable analytics
  static bool get enableAnalytics {
    return EnvironmentConstants.features.enableAnalytics && !kDebugMode;
  }

  /// Check if we should enable crash reporting
  static bool get enableCrashReporting {
    return EnvironmentConstants.features.enableCrashReporting && !kDebugMode;
  }

  /// Get user agent string
  static String get userAgent {
    final app = EnvironmentConstants.app;
    return '${app.appName}/${app.fullVersion} (${Environment.environmentName})';
  }
}

/// Configuration validation
class ConfigValidator {
  static void validateConfig() {
    final config = Environment.config;

    // Validate required fields
    assert(config.apiBaseUrl.isNotEmpty, 'API base URL cannot be empty');
    assert(config.firebaseConfig.projectId.isNotEmpty, 'Firebase project ID cannot be empty');

    // Validate feature flags make sense
    if (config.featureFlags.enableAIInsights && !config.featureFlags.enableAnalytics) {
      debugPrint('Warning: AI insights enabled but analytics disabled');
    }

    if (config.featureFlags.enableSocialFeatures && !config.featureFlags.enablePushNotifications) {
      debugPrint('Warning: Social features enabled but push notifications disabled');
    }
  }
}