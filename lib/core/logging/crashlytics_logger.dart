import 'package:flutter/foundation.dart';

import 'logger.dart';

/// Crash reporting service (simplified without Firebase)
class CrashlyticsLogger implements Logger {
  final Logger? _fallbackLogger;

  CrashlyticsLogger({
    Logger? fallbackLogger,
  }) : _fallbackLogger = fallbackLogger;

  /// Initialize crash reporting (simplified)
  Future<void> initialize() async {
    _logToFallback('Crash reporting initialized (simplified)');

    // Record Flutter errors
    FlutterError.onError = (FlutterErrorDetails details) {
      _logToFallback('Flutter error recorded: ${details.exception}');
    };

    // Record uncaught errors
    PlatformDispatcher.instance.onError = (error, stack) {
      _logToFallback('Uncaught error recorded: $error');
      return true;
    };
  }

  @override
  void debug(String message, [dynamic error, StackTrace? stackTrace]) {
    _logToFallback('DEBUG: $message', error, stackTrace);
  }

  @override
  void info(String message, [dynamic error, StackTrace? stackTrace]) {
    _logToFallback('INFO: $message', error, stackTrace);
  }

  @override
  void warning(String message, [dynamic error, StackTrace? stackTrace]) {
    _logToFallback('WARNING: $message', error, stackTrace);
  }

  @override
  void error(String message, [dynamic error, StackTrace? stackTrace]) {
    _logToFallback('ERROR: $message', error, stackTrace);
  }

  @override
  void fatal(String message, [dynamic error, StackTrace? stackTrace]) {
    _logToFallback('FATAL: $message', error, stackTrace);
  }

  /// Record a non-fatal error (simplified)
  void recordError(dynamic exception, StackTrace? stackTrace, {
    String? reason,
    Iterable<Object> information = const [],
    bool? printDetails,
  }) {
    _logToFallback('Error recorded: $exception', exception, stackTrace);
  }

  /// Record a fatal error (simplified)
  void recordFatalError(dynamic exception, StackTrace? stackTrace) {
    _logToFallback('Fatal error recorded: $exception', exception, stackTrace);
  }

  /// Set user identifier (simplified)
  Future<void> setUserIdentifier(String identifier) async {
    _logToFallback('User identifier set: $identifier');
  }

  /// Set custom key-value pair (simplified)
  Future<void> setCustomKey(String key, Object value) async {
    _logToFallback('Custom key set: $key = $value');
  }

  /// Set multiple custom keys (simplified)
  Future<void> setCustomKeys(Map<String, Object> keys) async {
    _logToFallback('Custom keys set: $keys');
  }

  /// Log breadcrumb for debugging crash context (simplified)
  Future<void> logBreadcrumb(String message, {Map<String, Object>? data}) async {
    _logToFallback('Breadcrumb logged: $message');
  }

  /// Delete unreported crash reports (simplified)
  Future<void> deleteUnreportedCrashReports() async {
    _logToFallback('Unreported crash reports deleted');
  }

  /// Check if crash reporting is enabled (simplified)
  Future<bool> isCrashlyticsCollectionEnabled() async {
    return false; // Simplified - always return false since Firebase not used
  }

  /// Enable or disable crash reporting (simplified)
  Future<void> setCrashlyticsCollectionEnabled(bool enabled) async {
    _logToFallback('Crash reporting ${enabled ? 'enabled' : 'disabled'}');
  }

  /// Helper method to log to fallback logger
  void _logToFallback(String message, [dynamic error, StackTrace? stackTrace]) {
    if (_fallbackLogger != null) {
      _fallbackLogger.debug(message, error, stackTrace);
    } else {
      debugPrint(message);
      if (error != null) debugPrint('Error: $error');
      if (stackTrace != null) debugPrint('StackTrace: $stackTrace');
    }
  }
}