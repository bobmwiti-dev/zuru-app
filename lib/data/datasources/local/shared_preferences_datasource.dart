import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/logging/logger.dart';

/// Local data source using SharedPreferences
class SharedPreferencesDataSource {
  final SharedPreferences _prefs;
  final Logger _logger;

  SharedPreferencesDataSource(this._prefs, this._logger);

  /// Store string value
  Future<void> setString(String key, String value) async {
    try {
      await _prefs.setString(key, value);
      _logger.debug('Stored string for key: $key');
    } catch (e) {
      _logger.error('Failed to store string for key: $key', e);
      rethrow;
    }
  }

  /// Get string value
  String? getString(String key) {
    try {
      return _prefs.getString(key);
    } catch (e) {
      _logger.error('Failed to get string for key: $key', e);
      return null;
    }
  }

  /// Store int value
  Future<void> setInt(String key, int value) async {
    try {
      await _prefs.setInt(key, value);
      _logger.debug('Stored int for key: $key');
    } catch (e) {
      _logger.error('Failed to store int for key: $key', e);
      rethrow;
    }
  }

  /// Get int value
  int? getInt(String key) {
    try {
      return _prefs.getInt(key);
    } catch (e) {
      _logger.error('Failed to get int for key: $key', e);
      return null;
    }
  }

  /// Store bool value
  Future<void> setBool(String key, bool value) async {
    try {
      await _prefs.setBool(key, value);
      _logger.debug('Stored bool for key: $key');
    } catch (e) {
      _logger.error('Failed to store bool for key: $key', e);
      rethrow;
    }
  }

  /// Get bool value
  bool? getBool(String key) {
    try {
      return _prefs.getBool(key);
    } catch (e) {
      _logger.error('Failed to get bool for key: $key', e);
      return null;
    }
  }

  /// Store double value
  Future<void> setDouble(String key, double value) async {
    try {
      await _prefs.setDouble(key, value);
      _logger.debug('Stored double for key: $key');
    } catch (e) {
      _logger.error('Failed to store double for key: $key', e);
      rethrow;
    }
  }

  /// Get double value
  double? getDouble(String key) {
    try {
      return _prefs.getDouble(key);
    } catch (e) {
      _logger.error('Failed to get double for key: $key', e);
      return null;
    }
  }

  /// Store list of strings
  Future<void> setStringList(String key, List<String> value) async {
    try {
      await _prefs.setStringList(key, value);
      _logger.debug('Stored string list for key: $key');
    } catch (e) {
      _logger.error('Failed to store string list for key: $key', e);
      rethrow;
    }
  }

  /// Get list of strings
  List<String>? getStringList(String key) {
    try {
      return _prefs.getStringList(key);
    } catch (e) {
      _logger.error('Failed to get string list for key: $key', e);
      return null;
    }
  }

  /// Store JSON object
  Future<void> setJson(String key, Map<String, dynamic> value) async {
    try {
      final jsonString = json.encode(value);
      await setString(key, jsonString);
      _logger.debug('Stored JSON for key: $key');
    } catch (e) {
      _logger.error('Failed to store JSON for key: $key', e);
      rethrow;
    }
  }

  /// Get JSON object
  Map<String, dynamic>? getJson(String key) {
    try {
      final jsonString = getString(key);
      if (jsonString == null) return null;
      return json.decode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      _logger.error('Failed to get JSON for key: $key', e);
      return null;
    }
  }

  /// Store object with JSON encoding
  Future<void> setObject<T>(String key, T object, Map<String, dynamic> Function(T) toJson) async {
    try {
      final jsonMap = toJson(object);
      await setJson(key, jsonMap);
      _logger.debug('Stored object for key: $key');
    } catch (e) {
      _logger.error('Failed to store object for key: $key', e);
      rethrow;
    }
  }

  /// Get object with JSON decoding
  T? getObject<T>(String key, T Function(Map<String, dynamic>) fromJson) {
    try {
      final jsonMap = getJson(key);
      if (jsonMap == null) return null;
      return fromJson(jsonMap);
    } catch (e) {
      _logger.error('Failed to get object for key: $key', e);
      return null;
    }
  }

  /// Check if key exists
  bool containsKey(String key) {
    return _prefs.containsKey(key);
  }

  /// Remove key
  Future<void> remove(String key) async {
    try {
      await _prefs.remove(key);
      _logger.debug('Removed key: $key');
    } catch (e) {
      _logger.error('Failed to remove key: $key', e);
      rethrow;
    }
  }

  /// Clear all data
  Future<void> clear() async {
    try {
      await _prefs.clear();
      _logger.info('Cleared all shared preferences');
    } catch (e) {
      _logger.error('Failed to clear shared preferences', e);
      rethrow;
    }
  }

  /// Get all keys
  Set<String> getKeys() {
    return _prefs.getKeys();
  }

  /// Get cache size in bytes (rough estimate)
  int getCacheSize() {
    int size = 0;
    for (final key in getKeys()) {
      final value = _prefs.getString(key) ?? '';
      size += key.length + value.length;
    }
    return size * 2; // Rough estimate: 2 bytes per character
  }
}

/// Shared preferences keys constants
class SharedPreferencesKeys {
  static const String authToken = 'auth_token';
  static const String refreshToken = 'refresh_token';
  static const String userId = 'user_id';
  static const String userProfile = 'user_profile';
  static const String appSettings = 'app_settings';
  static const String userPreferences = 'user_preferences';
  static const String onboardingCompleted = 'onboarding_completed';
  static const String lastSyncTime = 'last_sync_time';
  static const String offlineMode = 'offline_mode';
  static const String analyticsConsent = 'analytics_consent';
  static const String crashReportingConsent = 'crash_reporting_consent';
}