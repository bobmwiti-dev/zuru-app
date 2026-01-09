import 'package:flutter/foundation.dart';

/// Logger interface for consistent logging across the app
abstract class Logger {
  /// Log debug message
  void debug(String message, [dynamic error, StackTrace? stackTrace]);

  /// Log info message
  void info(String message, [dynamic error, StackTrace? stackTrace]);

  /// Log warning message
  void warning(String message, [dynamic error, StackTrace? stackTrace]);

  /// Log error message
  void error(String message, [dynamic error, StackTrace? stackTrace]);

  /// Log fatal error message
  void fatal(String message, [dynamic error, StackTrace? stackTrace]);
}

/// Console logger implementation
class ConsoleLogger implements Logger {
  final String name;
  final bool enableColors;

  ConsoleLogger({
    this.name = 'ZuruApp',
    this.enableColors = true,
  });

  @override
  void debug(String message, [dynamic error, StackTrace? stackTrace]) {
    _log('DEBUG', message, error, stackTrace, _debugColor);
  }

  @override
  void info(String message, [dynamic error, StackTrace? stackTrace]) {
    _log('INFO', message, error, stackTrace, _infoColor);
  }

  @override
  void warning(String message, [dynamic error, StackTrace? stackTrace]) {
    _log('WARNING', message, error, stackTrace, _warningColor);
  }

  @override
  void error(String message, [dynamic error, StackTrace? stackTrace]) {
    _log('ERROR', message, error, stackTrace, _errorColor);
  }

  @override
  void fatal(String message, [dynamic error, StackTrace? stackTrace]) {
    _log('FATAL', message, error, stackTrace, _fatalColor);
  }

  void _log(String level, String message, dynamic error, StackTrace? stackTrace, String color) {
    final timestamp = DateTime.now().toIso8601String();
    final prefix = '[$timestamp] [$name] [$level]';

    if (kDebugMode) {
      final coloredMessage = enableColors ? '$color$message\x1B[0m' : message;
      debugPrint('$prefix $coloredMessage');

      if (error != null) {
        debugPrint('$prefix Error: $error');
      }

      if (stackTrace != null) {
        debugPrint('$prefix StackTrace: $stackTrace');
      }
    } else {
      // In release mode, only log errors and above
      if (level == 'ERROR' || level == 'FATAL') {
        debugPrint('$prefix $message');
        if (error != null) {
          debugPrint('$prefix Error: $error');
        }
      }
    }
  }

  // ANSI color codes
  static const String _debugColor = '\x1B[36m'; // Cyan
  static const String _infoColor = '\x1B[32m'; // Green
  static const String _warningColor = '\x1B[33m'; // Yellow
  static const String _errorColor = '\x1B[31m'; // Red
  static const String _fatalColor = '\x1B[35m'; // Magenta
}

/// No-op logger for testing or when logging is disabled
class NoOpLogger implements Logger {
  @override
  void debug(String message, [dynamic error, StackTrace? stackTrace]) {}

  @override
  void info(String message, [dynamic error, StackTrace? stackTrace]) {}

  @override
  void warning(String message, [dynamic error, StackTrace? stackTrace]) {}

  @override
  void error(String message, [dynamic error, StackTrace? stackTrace]) {}

  @override
  void fatal(String message, [dynamic error, StackTrace? stackTrace]) {}
}

/// Logger factory
class LoggerFactory {
  static Logger createLogger({
    String name = 'ZuruApp',
    bool enableColors = true,
    bool enableLogging = true,
  }) {
    if (!enableLogging) {
      return NoOpLogger();
    }

    return ConsoleLogger(
      name: name,
      enableColors: enableColors && kDebugMode,
    );
  }
}