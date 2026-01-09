import 'package:flutter/foundation.dart';

/// Base exception class for the application
/// All custom exceptions should extend this class
abstract class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalException;
  final StackTrace? stackTrace;

  const AppException({
    required this.message,
    this.code,
    this.originalException,
    this.stackTrace,
  });

  @override
  String toString() {
    return 'AppException: $message${code != null ? ' (Code: $code)' : ''}';
  }

  /// Get a user-friendly error message
  String get userFriendlyMessage => message;

  /// Get error type for UI handling
  String get errorType;
}

/// Network-related exceptions
class NetworkException extends AppException {
  const NetworkException({
    required super.message,
    super.code,
    super.originalException,
    super.stackTrace,
  });

  @override
  String get errorType => 'network';

  @override
  String get userFriendlyMessage {
    if (message.contains('timeout')) {
      return 'Connection timed out. Please check your internet connection.';
    } else if (message.contains('no internet')) {
      return 'No internet connection. Please check your network settings.';
    } else if (message.contains('host unreachable')) {
      return 'Unable to connect to server. Please try again later.';
    }
    return 'Network error occurred. Please check your connection and try again.';
  }
}

/// Authentication-related exceptions
class AuthenticationException extends AppException {
  const AuthenticationException({
    required super.message,
    super.code,
    super.originalException,
    super.stackTrace,
  });

  @override
  String get errorType => 'authentication';

  @override
  String get userFriendlyMessage {
    if (message.contains('invalid credentials')) {
      return 'Invalid email or password. Please check and try again.';
    } else if (message.contains('user not found')) {
      return 'Account not found. Please sign up or check your email.';
    } else if (message.contains('weak password')) {
      return 'Password is too weak. Please use at least 6 characters.';
    } else if (message.contains('email already in use')) {
      return 'This email is already registered. Please sign in instead.';
    } else if (message.contains('invalid email')) {
      return 'Please enter a valid email address.';
    }
    return 'Authentication failed. Please try again.';
  }
}

/// Permission-related exceptions
class PermissionException extends AppException {
  const PermissionException({
    required super.message,
    super.code,
    super.originalException,
    super.stackTrace,
  });

  @override
  String get errorType => 'permission';

  @override
  String get userFriendlyMessage {
    if (message.contains('camera')) {
      return 'Camera permission is required to capture photos.';
    } else if (message.contains('location')) {
      return 'Location permission is required to tag your memories with places.';
    } else if (message.contains('storage') || message.contains('gallery')) {
      return 'Storage permission is required to save and access photos.';
    } else if (message.contains('microphone')) {
      return 'Microphone permission is required to record audio.';
    }
    return 'Permission denied. Please grant the required permissions in settings.';
  }
}

/// Validation-related exceptions
class ValidationException extends AppException {
  const ValidationException({
    required super.message,
    super.code,
    super.originalException,
    super.stackTrace,
  });

  @override
  String get errorType => 'validation';

  @override
  String get userFriendlyMessage {
    if (message.contains('required')) {
      return 'This field is required. Please fill it in.';
    } else if (message.contains('email')) {
      return 'Please enter a valid email address.';
    } else if (message.contains('password')) {
      return 'Password must be at least 6 characters long.';
    } else if (message.contains('length')) {
      return 'Input exceeds maximum length limit.';
    }
    return message;
  }
}

/// Data-related exceptions (database, cache, etc.)
class DataException extends AppException {
  const DataException({
    required super.message,
    super.code,
    super.originalException,
    super.stackTrace,
  });

  @override
  String get errorType => 'data';

  @override
  String get userFriendlyMessage {
    if (message.contains('not found')) {
      return 'The requested item could not be found.';
    } else if (message.contains('already exists')) {
      return 'This item already exists.';
    } else if (message.contains('storage full')) {
      return 'Storage is full. Please free up space and try again.';
    }
    return 'Data error occurred. Please try again.';
  }
}

/// Server-related exceptions
class ServerException extends AppException {
  const ServerException({
    required super.message,
    super.code,
    super.originalException,
    super.stackTrace,
  });

  @override
  String get errorType => 'server';

  @override
  String get userFriendlyMessage {
    if (message.contains('500') || message.contains('internal server')) {
      return 'Server error occurred. Please try again later.';
    } else if (message.contains('503') || message.contains('maintenance')) {
      return 'Service is temporarily unavailable. Please try again later.';
    } else if (message.contains('429') || message.contains('too many requests')) {
      return 'Too many requests. Please wait a moment and try again.';
    }
    return 'Server error occurred. Please try again later.';
  }
}

/// Unknown or unexpected exceptions
class UnknownException extends AppException {
  const UnknownException({
    required super.message,
    super.code,
    super.originalException,
    super.stackTrace,
  });

  @override
  String get errorType => 'unknown';

  @override
  String get userFriendlyMessage {
    return 'An unexpected error occurred. Please try again or contact support if the problem persists.';
  }
}

/// Utility class for exception handling and conversion
class ExceptionHandler {
  /// Convert any exception to an AppException
  static AppException handleException(dynamic exception, {StackTrace? stackTrace}) {
    // Handle specific exception types
    if (exception is AppException) {
      return exception;
    }

    // Handle common Flutter/Dart exceptions
    if (exception is FormatException) {
      return ValidationException(
        message: 'Invalid data format',
        originalException: exception,
        stackTrace: stackTrace,
      );
    }

    if (exception is ArgumentError) {
      return ValidationException(
        message: 'Invalid argument provided',
        originalException: exception,
        stackTrace: stackTrace,
      );
    }

    if (exception is StateError) {
      return DataException(
        message: 'Application state error',
        originalException: exception,
        stackTrace: stackTrace,
      );
    }

    // Handle network-related exceptions
    final exceptionString = exception.toString().toLowerCase();
    if (exceptionString.contains('socket') ||
        exceptionString.contains('connection') ||
        exceptionString.contains('network') ||
        exceptionString.contains('timeout')) {
      return NetworkException(
        message: 'Network connection error',
        originalException: exception,
        stackTrace: stackTrace,
      );
    }

    // Default to unknown exception
    return UnknownException(
      message: exception.toString(),
      originalException: exception,
      stackTrace: stackTrace,
    );
  }

  /// Convert exception to user-friendly message
  static String getUserFriendlyMessage(dynamic exception) {
    final appException = handleException(exception);
    return appException.userFriendlyMessage;
  }

  /// Get error type for UI handling
  static String getErrorType(dynamic exception) {
    final appException = handleException(exception);
    return appException.errorType;
  }

  /// Log exception (would integrate with logging system)
  static void logException(dynamic exception, {StackTrace? stackTrace, String? context}) {
    final appException = handleException(exception, stackTrace: stackTrace);

    // Here you would integrate with your logging system
    // For now, just print to console
    debugPrint('Exception logged: ${appException.toString()}');
    if (context != null) {
      debugPrint('Context: $context');
    }
    if (stackTrace != null) {
      debugPrint('Stack trace: $stackTrace');
    }
  }

  /// Check if exception is recoverable (user can retry)
  static bool isRecoverable(dynamic exception) {
    final errorType = getErrorType(exception);
    return ['network', 'server', 'unknown'].contains(errorType);
  }

  /// Check if exception requires user action (like granting permissions)
  static bool requiresUserAction(dynamic exception) {
    final errorType = getErrorType(exception);
    return ['permission', 'authentication'].contains(errorType);
  }
}