import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../logging/logger.dart';

/// Cache manager for storing temporary data
class CacheManager {
  final SharedPreferences _prefs;
  final Logger _logger;
  final String _cachePrefix = 'cache_';

  CacheManager(this._prefs, this._logger);

  /// Store data in cache with expiration
  Future<void> set(String key, dynamic value, {Duration? ttl}) async {
    try {
      final cacheKey = '$_cachePrefix$key';
      final cacheData = CacheData(
        value: value,
        timestamp: DateTime.now(),
        ttl: ttl,
      );

      final jsonString = json.encode(cacheData.toJson());
      await _prefs.setString(cacheKey, jsonString);

      _logger.debug('Cached data for key: $key');
    } catch (e) {
      _logger.error('Failed to cache data for key: $key', e);
    }
  }

  /// Get data from cache
  T? get<T>(String key) {
    try {
      final cacheKey = '$_cachePrefix$key';
      final jsonString = _prefs.getString(cacheKey);

      if (jsonString == null) {
        return null;
      }

      final cacheData = CacheData.fromJson(json.decode(jsonString));

      // Check if cache has expired
      if (cacheData.isExpired) {
        // Remove expired cache
        remove(key);
        return null;
      }

      return cacheData.value as T;
    } catch (e) {
      _logger.error('Failed to get cached data for key: $key', e);
      return null;
    }
  }

  /// Check if cache contains key
  bool contains(String key) {
    final cacheKey = '$_cachePrefix$key';
    return _prefs.containsKey(cacheKey);
  }

  /// Remove data from cache
  Future<void> remove(String key) async {
    try {
      final cacheKey = '$_cachePrefix$key';
      await _prefs.remove(cacheKey);
      _logger.debug('Removed cache for key: $key');
    } catch (e) {
      _logger.error('Failed to remove cache for key: $key', e);
    }
  }

  /// Clear all cache
  Future<void> clear() async {
    try {
      final keys = _prefs.getKeys().where((key) => key.startsWith(_cachePrefix));
      for (final key in keys) {
        await _prefs.remove(key);
      }
      _logger.info('Cleared all cache');
    } catch (e) {
      _logger.error('Failed to clear cache', e);
    }
  }

  /// Get cache size in bytes
  int getCacheSize() {
    int size = 0;
    final keys = _prefs.getKeys().where((key) => key.startsWith(_cachePrefix));

    for (final key in keys) {
      final value = _prefs.getString(key);
      if (value != null) {
        size += value.length * 2; // Rough estimate: 2 bytes per character
      }
    }

    return size;
  }

  /// Clean expired cache entries
  Future<void> cleanExpired() async {
    try {
      final keys = _prefs.getKeys().where((key) => key.startsWith(_cachePrefix)).toList();

      for (final key in keys) {
        try {
          final jsonString = _prefs.getString(key);
          if (jsonString != null) {
            final cacheData = CacheData.fromJson(json.decode(jsonString));
            if (cacheData.isExpired) {
              await _prefs.remove(key);
            }
          }
        } catch (e) {
          // Remove corrupted cache entries
          await _prefs.remove(key);
        }
      }

      _logger.debug('Cleaned expired cache entries');
    } catch (e) {
      _logger.error('Failed to clean expired cache', e);
    }
  }
}

/// Cache data model
class CacheData {
  final dynamic value;
  final DateTime timestamp;
  final Duration? ttl;

  CacheData({
    required this.value,
    required this.timestamp,
    this.ttl,
  });

  factory CacheData.fromJson(Map<String, dynamic> json) {
    return CacheData(
      value: json['value'],
      timestamp: DateTime.parse(json['timestamp']),
      ttl: json['ttl'] != null ? Duration(seconds: json['ttl']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'value': value,
      'timestamp': timestamp.toIso8601String(),
      'ttl': ttl?.inSeconds,
    };
  }

  bool get isExpired {
    if (ttl == null) return false;
    final now = DateTime.now();
    final expirationTime = timestamp.add(ttl!);
    return now.isAfter(expirationTime);
  }
}

/// Cache keys constants
class CacheKeys {
  static const String userProfile = 'user_profile';
  static const String memoriesList = 'memories_list';
  static const String locationData = 'location_data';
  static const String weatherData = 'weather_data';
  static const String aiInsights = 'ai_insights';
  static const String friendsList = 'friends_list';
}