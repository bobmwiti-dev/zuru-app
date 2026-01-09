import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:geolocator/geolocator.dart';

import '../../core/logging/logger.dart';
import '../../core/cache/cache_manager.dart';
import '../../core/analytics/app_analytics.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/journal_repository.dart';
import '../../data/repositories/analytics_repository.dart';
import '../../data/datasources/local/shared_preferences_datasource.dart';
import '../../services/location_service.dart';
import '../../services/media_service.dart';
import '../../services/notification_service.dart';
import '../../services/connectivity_service.dart';
import '../../domain/usecases/create_journal_entry.dart';

/// Core service providers

/// Logger provider
final loggerProvider = Provider<Logger>((ref) {
  return LoggerFactory.createLogger();
});

/// Shared preferences provider
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(
    'SharedPreferences must be initialized in main.dart',
  );
});

/// Connectivity provider
final connectivityProvider = Provider<Connectivity>((ref) {
  return Connectivity();
});

/// Geolocator provider
final geolocatorProvider = Provider<GeolocatorPlatform>((ref) {
  return GeolocatorPlatform.instance;
});

/// Data source providers

/// Local data sources
final sharedPreferencesDataSourceProvider =
    Provider<SharedPreferencesDataSource>((ref) {
      final sharedPrefs = ref.watch(sharedPreferencesProvider);
      final logger = ref.watch(loggerProvider);
      return SharedPreferencesDataSource(sharedPrefs, logger);
    });

// TODO: Add Firebase data sources when Firebase packages are installed

/// Repository providers
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl();
});

final journalRepositoryProvider = Provider<JournalRepository>((ref) {
  return JournalRepositoryImpl();
});

final locationRepositoryProvider = Provider<LocationRepository>((ref) {
  return LocationRepositoryImpl();
});

final analyticsRepositoryProvider = Provider<AnalyticsRepository>((ref) {
  return AnalyticsRepositoryImpl();
});

/// Service providers
final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  final connectivity = ref.watch(connectivityProvider);
  final logger = ref.watch(loggerProvider);
  return ConnectivityService(connectivity, logger);
});

final locationServiceProvider = Provider<LocationService>((ref) {
  final geolocator = ref.watch(geolocatorProvider);
  final logger = ref.watch(loggerProvider);
  return LocationService(geolocator, logger);
});

final mediaServiceProvider = Provider<MediaService>((ref) {
  final logger = ref.watch(loggerProvider);
  return MediaService(logger);
});

final notificationServiceProvider = Provider<NotificationService>((ref) {
  final logger = ref.watch(loggerProvider);
  return NotificationService(logger);
});

/// Cache and analytics providers
final cacheManagerProvider = Provider<CacheManager>((ref) {
  final sharedPrefs = ref.watch(sharedPreferencesProvider);
  final logger = ref.watch(loggerProvider);
  return CacheManager(sharedPrefs, logger);
});

final appAnalyticsProvider = Provider<AppAnalytics>((ref) {
  final analyticsRepo = ref.watch(analyticsRepositoryProvider);
  final logger = ref.watch(loggerProvider);
  // TODO: Pass current user ID getter when auth is properly implemented
  return AppAnalytics(analyticsRepo, logger);
});

/// Use case providers
final createJournalEntryUseCaseProvider = Provider<CreateJournalEntry>((ref) {
  return CreateJournalEntryImpl();
});

final getJournalEntriesUseCaseProvider = Provider<GetJournalEntries>((ref) {
  return GetJournalEntriesImpl();
});

final signInUseCaseProvider = Provider<SignIn>((ref) {
  return SignInImpl();
});

final signOutUseCaseProvider = Provider<SignOut>((ref) {
  return SignOutImpl();
});

final getMoodTrendsUseCaseProvider = Provider<GetMoodTrends>((ref) {
  return GetMoodTrendsImpl();
});

/// Provider overrides for testing
final testOverrides = <Override>[];

/// Initialize all providers with test overrides if needed
ProviderContainer createProviderContainer({
  List<Override> overrides = const [],
}) {
  return ProviderContainer(overrides: overrides);
}

/// Get a service instance from the container
T getService<T>(ProviderContainer container, Provider<T> provider) {
  return container.read(provider);
}

/// Dispose of all services (call in app dispose)
void disposeServices(ProviderContainer container) {
  // Dispose of any services that need cleanup
  // For example:
  // container.read(notificationServiceProvider).dispose();
  // container.read(connectivityServiceProvider).dispose();
}

/// Service locator class for easy access in non-widget code
class ServiceLocator {
  static ProviderContainer? _container;

  static void initialize(ProviderContainer container) {
    _container = container;
  }

  static T get<T>(Provider<T> provider) {
    if (_container == null) {
      throw StateError(
        'ServiceLocator not initialized. Call initialize() first.',
      );
    }
    return _container!.read(provider);
  }

  static void dispose() {
    if (_container != null) {
      disposeServices(_container!);
      _container = null;
    }
  }
}

/// Extension methods for easy service access
extension ProviderContainerExtensions on ProviderContainer {
  /// Get auth repository
  AuthRepository get authRepository => read(authRepositoryProvider);

  /// Get journal repository
  JournalRepository get journalRepository => read(journalRepositoryProvider);

  /// Get location service
  LocationService get locationService => read(locationServiceProvider);

  /// Get media service
  MediaService get mediaService => read(mediaServiceProvider);

  /// Get notification service
  NotificationService get notificationService =>
      read(notificationServiceProvider);

  /// Get cache manager
  CacheManager get cacheManager => read(cacheManagerProvider);

  /// Get app analytics
  AppAnalytics get appAnalytics => read(appAnalyticsProvider);

  /// Get logger
  Logger get logger => read(loggerProvider);
}
