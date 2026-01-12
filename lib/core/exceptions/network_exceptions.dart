import 'dart:io';

import 'app_exception.dart';

/// Network-specific exception handling
class NetworkExceptions {
  static AppException handleNetworkException(dynamic error, {StackTrace? stackTrace}) {
    if (error is SocketException) {
      return _handleSocketException(error);
    }

    if (error is HttpException) {
      return _handleHttpException(error);
    }

    if (error is FormatException) {
      return _handleFormatException(error);
    }

    if (error is TimeoutException) {
      return _handleTimeoutException(error);
    }

    // Generic network exception
    return NetworkException(
      message: 'Network request failed',
      code: 'network_unknown',
      originalException: error,
      stackTrace: stackTrace,
    );
  }

  static NetworkException _handleSocketException(SocketException error) {
    switch (error.osError?.errorCode) {
      case 7: // ENOTCONN - No internet connection
      case 8: // ENOTSOCK - Socket operation on non-socket
      case 50: // ENETDOWN - Network is down
      case 51: // ENETUNREACH - Network is unreachable
        return NetworkException(
          message: 'No internet connection. Please check your network settings.',
          code: 'no_internet',
          originalException: error,
        );

      case 60: // ETIMEDOUT - Connection timed out
      case 61: // ECONNREFUSED - Connection refused
        return NetworkException(
          message: 'Connection failed. Please check your internet connection.',
          code: 'connection_failed',
          originalException: error,
        );

      case 65: // EHOSTUNREACH - No route to host
        return NetworkException(
          message: 'Unable to reach server. Please try again later.',
          code: 'host_unreachable',
          originalException: error,
        );

      default:
        return NetworkException(
          message: 'Network error occurred. Please check your connection.',
          code: 'network_error',
          originalException: error,
        );
    }
  }

  static AppException _handleHttpException(HttpException error) {
    final message = error.message;
    final messageLower = message.toLowerCase();

    if (messageLower.contains('404') || messageLower.contains('not found')) {
      return ServerException(
        message: 'Requested resource not found',
        code: 'not_found',
        originalException: error,
      );
    }

    if (messageLower.contains('403') || messageLower.contains('forbidden')) {
      return ServerException(
        message: 'Access denied. You may not have permission to perform this action.',
        code: 'forbidden',
        originalException: error,
      );
    }

    if (messageLower.contains('401') || messageLower.contains('unauthorized')) {
      return AuthenticationException(
        message: 'Authentication required. Please sign in again.',
        code: 'unauthorized',
        originalException: error,
      );
    }

    if (messageLower.contains('429') || messageLower.contains('too many requests')) {
      return ServerException(
        message: 'Too many requests. Please wait a moment and try again.',
        code: 'rate_limited',
        originalException: error,
      );
    }

    if (messageLower.contains('500') || messageLower.contains('internal server')) {
      return ServerException(
        message: 'Server error occurred. Please try again later.',
        code: 'server_error',
        originalException: error,
      );
    }

    if (messageLower.contains('502') || messageLower.contains('bad gateway')) {
      return ServerException(
        message: 'Service temporarily unavailable. Please try again later.',
        code: 'bad_gateway',
        originalException: error,
      );
    }

    if (messageLower.contains('503') || messageLower.contains('service unavailable')) {
      return ServerException(
        message: 'Service is under maintenance. Please try again later.',
        code: 'service_unavailable',
        originalException: error,
      );
    }

    return ServerException(
      message: 'Server communication error',
      code: 'http_error',
      originalException: error,
    );
  }

  static ValidationException _handleFormatException(FormatException error) {
    return ValidationException(
      message: 'Invalid data format received from server',
      code: 'invalid_format',
      originalException: error,
    );
  }

  static NetworkException _handleTimeoutException(TimeoutException error) {
    return NetworkException(
      message: 'Request timed out. Please check your connection and try again.',
      code: 'timeout',
      originalException: error,
    );
  }
}

/// Custom TimeoutException for consistency
class TimeoutException implements Exception {
  final String message;
  final Duration? duration;

  const TimeoutException([this.message = 'Operation timed out', this.duration]);

  @override
  String toString() => 'TimeoutException: $message';
}

/// Utility class for connectivity checks
class ConnectivityChecker {
  static Future<bool> hasInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }

  static Future<String> getConnectionType() async {
    // This would integrate with connectivity_plus package
    // For now, return a placeholder
    return 'wifi'; // or 'mobile', 'none'
  }
}

/// HTTP status code utilities
class HttpStatus {
  static bool isSuccess(int statusCode) {
    return statusCode >= 200 && statusCode < 300;
  }

  static bool isClientError(int statusCode) {
    return statusCode >= 400 && statusCode < 500;
  }

  static bool isServerError(int statusCode) {
    return statusCode >= 500 && statusCode < 600;
  }

  static String getMessage(int statusCode) {
    switch (statusCode) {
      case 200:
        return 'OK';
      case 201:
        return 'Created';
      case 204:
        return 'No Content';
      case 400:
        return 'Bad Request';
      case 401:
        return 'Unauthorized';
      case 403:
        return 'Forbidden';
      case 404:
        return 'Not Found';
      case 409:
        return 'Conflict';
      case 422:
        return 'Unprocessable Entity';
      case 429:
        return 'Too Many Requests';
      case 500:
        return 'Internal Server Error';
      case 502:
        return 'Bad Gateway';
      case 503:
        return 'Service Unavailable';
      case 504:
        return 'Gateway Timeout';
      default:
        return 'Unknown Status';
    }
  }
}