import '../../core/exceptions/app_exception.dart';

/// Error Mapper - Converts technical exceptions to user-friendly messages
class ErrorMapper {
  /// Map any exception to a user-friendly message
  static String mapError(dynamic error) {
    if (error is AppException) {
      return _mapAppException(error);
    }

    // Handle common platform exceptions
    if (error is Exception) {
      return _mapCommonExceptions(error);
    }

    // Handle strings
    if (error is String) {
      return error;
    }

    // Handle unknown errors
    return 'An unexpected error occurred. Please try again.';
  }

  /// Map AppException to user-friendly message
  static String _mapAppException(AppException exception) {
    // For AppExceptions, the message is already user-friendly
    // But we can customize based on exception type if needed

    if (exception is AuthenticationException) {
      return _mapAuthException(exception);
    }

    if (exception is NetworkException) {
      return _mapNetworkException(exception);
    }

    if (exception is PermissionException) {
      return _mapPermissionException(exception);
    }

    if (exception is DataException) {
      return _mapMediaException(exception);
    }

    return exception.message;
  }

  /// Map authentication exceptions
  static String _mapAuthException(AuthenticationException exception) {
    switch (exception.code) {
      case 'user-not-found':
        return 'No account found with this email. Please sign up or check your email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again or reset your password.';
      case 'email-already-in-use':
        return 'An account with this email already exists. Please sign in instead.';
      case 'weak-password':
        return 'Password must be at least 6 characters long.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'user-disabled':
        return 'This account has been disabled. Please contact support.';
      case 'too-many-requests':
        return 'Too many failed attempts. Please wait a few minutes and try again.';
      case 'network-error':
        return 'Network connection failed. Please check your internet and try again.';
      case 'google_signin_cancelled':
        return 'Login cancelled.';
      case 'google_signin_failed':
        return 'Couldn\'t log you in with Google. Please try again.';
      case 'google_signin_no_user':
        return 'Couldn\'t complete Google login. Please try again.';
      case 'apple_signin_cancelled':
        return 'Login cancelled.';
      case 'apple_signin_failed':
        return 'Couldn\'t log you in with Apple. Please try again.';
      case 'apple_signin_no_user':
        return 'Couldn\'t complete Apple login. Please try again.';
      default:
        return exception.message;
    }
  }

  /// Map network exceptions
  static String _mapNetworkException(NetworkException exception) {
    switch (exception.code) {
      case 'no-connection':
        return 'No internet connection. Please check your network and try again.';
      case 'timeout':
        return 'Request timed out. Please check your connection and try again.';
      case 'server-error':
        return 'Server temporarily unavailable. Please try again in a few moments.';
      case 'bad-request':
        return 'Invalid request. Please check your input and try again.';
      case 'unauthorized':
        return 'Session expired. Please sign in again.';
      case 'forbidden':
        return 'You don\'t have permission to perform this action.';
      case 'not-found':
        return 'The requested item could not be found.';
      default:
        return exception.message;
    }
  }

  /// Map permission exceptions
  static String _mapPermissionException(PermissionException exception) {
    switch (exception.code) {
      case 'camera-denied':
        return 'Camera access is needed to capture photos for your memories.';
      case 'location-denied':
        return 'Location access helps us tag your memories with places you visit.';
      case 'storage-denied':
        return 'Storage access is needed to save your photos and memories.';
      case 'notification-denied':
        return 'Notifications help you stay on track with your journaling goals.';
      default:
        return exception.message;
    }
  }

  /// Map media exceptions
  static String _mapMediaException(DataException exception) {
    switch (exception.code) {
      case 'image-pick-failed':
        return 'Could not select the image. Please try again or choose a different image.';
      case 'video-pick-failed':
        return 'Could not select the video. Please try again or choose a different video.';
      case 'compression-failed':
        return 'Could not process the media file. Please try with a different file.';
      case 'upload-failed':
        return 'Could not upload the file. Please check your connection and try again.';
      case 'invalid-format':
        return 'This file format is not supported. Please choose a different file.';
      case 'file-too-large':
        return 'File is too large. Please choose a smaller file or compress it first.';
      default:
        return exception.message;
    }
  }

  /// Map common exceptions that might occur in Flutter
  static String _mapCommonExceptions(Exception exception) {
    final errorString = exception.toString().toLowerCase();

    // Network related
    if (errorString.contains('socketexception') ||
        errorString.contains('connection refused') ||
        errorString.contains('connection reset')) {
      return 'Network connection failed. Please check your internet and try again.';
    }

    // Timeout related
    if (errorString.contains('timeout') ||
        errorString.contains('deadline exceeded')) {
      return 'Request timed out. Please try again.';
    }

    // Permission related
    if (errorString.contains('permission') ||
        errorString.contains('denied')) {
      return 'Permission required for this action. Please grant the necessary permissions.';
    }

    // File system related
    if (errorString.contains('filenotfound') ||
        errorString.contains('pathnotfound')) {
      return 'File not found. Please check the file and try again.';
    }

    // Memory related
    if (errorString.contains('outofmemory') ||
        errorString.contains('memory')) {
      return 'Not enough memory. Please close other apps and try again.';
    }

    // Generic fallback
    return 'Something went wrong. Please try again.';
  }

  /// Get error severity level for UI styling
  static ErrorSeverity getErrorSeverity(dynamic error) {
    if (error is AppException) {
      if (error is AuthenticationException) {
        return ErrorSeverity.warning;
      }
      if (error is NetworkException) {
        return ErrorSeverity.info;
      }
      if (error is PermissionException) {
        return ErrorSeverity.warning;
      }
      if (error is DataException) {
        return ErrorSeverity.warning;
      }
      return ErrorSeverity.error;
    }

    // Check for specific error types
    if (error is Exception) {
      final errorString = error.toString().toLowerCase();
      if (errorString.contains('permission') ||
          errorString.contains('denied')) {
        return ErrorSeverity.warning;
      }
      if (errorString.contains('network') ||
          errorString.contains('connection') ||
          errorString.contains('timeout')) {
        return ErrorSeverity.info;
      }
    }

    return ErrorSeverity.error;
  }

  /// Get appropriate icon for error type
  static String getErrorIcon(dynamic error) {
    final severity = getErrorSeverity(error);

    switch (severity) {
      case ErrorSeverity.info:
        return 'info';
      case ErrorSeverity.warning:
        return 'warning';
      case ErrorSeverity.error:
        return 'error';
    }
  }

  /// Get appropriate color for error type
  static ErrorColor getErrorColor(dynamic error) {
    final severity = getErrorSeverity(error);

    switch (severity) {
      case ErrorSeverity.info:
        return ErrorColor.blue;
      case ErrorSeverity.warning:
        return ErrorColor.orange;
      case ErrorSeverity.error:
        return ErrorColor.red;
    }
  }
}

/// Error severity levels
enum ErrorSeverity {
  info,    // Blue - network issues, temporary problems
  warning, // Orange - permissions, validation issues
  error,   // Red - critical errors, app crashes
}

/// Error color themes
enum ErrorColor {
  blue,
  orange,
  red,
}

/// Extension to get color from ErrorColor enum
extension ErrorColorExtension on ErrorColor {
  String get hexColor {
    switch (this) {
      case ErrorColor.blue:
        return '#2196F3'; // Blue
      case ErrorColor.orange:
        return '#FF9800'; // Orange
      case ErrorColor.red:
        return '#F44336'; // Red
    }
  }
}