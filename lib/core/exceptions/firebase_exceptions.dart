import 'app_exception.dart';

/// Firebase-specific exception handling
class FirebaseExceptions {
  static AppException handleFirebaseException(dynamic error) {
    // Handle Firebase Auth exceptions
    if (error.toString().contains('firebase_auth')) {
      return _handleAuthException(error);
    }

    // Handle Firebase Firestore exceptions
    if (error.toString().contains('cloud_firestore')) {
      return _handleFirestoreException(error);
    }

    // Handle Firebase Storage exceptions
    if (error.toString().contains('firebase_storage')) {
      return _handleStorageException(error);
    }

    // Generic Firebase exception
    return FirebaseException(
      message: 'Firebase operation failed',
      code: 'firebase_unknown',
      originalError: error,
    );
  }

  static AppException _handleAuthException(dynamic error) {
    final errorString = error.toString().toLowerCase();

    if (errorString.contains('user-not-found')) {
      return AuthException(
        message: 'No account found with this email address',
        code: 'user-not-found',
        originalError: error,
      );
    }

    if (errorString.contains('wrong-password')) {
      return AuthException(
        message: 'Incorrect password',
        code: 'wrong-password',
        originalError: error,
      );
    }

    if (errorString.contains('email-already-in-use')) {
      return AuthException(
        message: 'An account with this email already exists',
        code: 'email-already-in-use',
        originalError: error,
      );
    }

    if (errorString.contains('weak-password')) {
      return AuthException(
        message: 'Password is too weak. Please choose a stronger password',
        code: 'weak-password',
        originalError: error,
      );
    }

    if (errorString.contains('invalid-email')) {
      return AuthException(
        message: 'Please enter a valid email address',
        code: 'invalid-email',
        originalError: error,
      );
    }

    if (errorString.contains('user-disabled')) {
      return AuthException(
        message: 'This account has been disabled',
        code: 'user-disabled',
        originalError: error,
      );
    }

    if (errorString.contains('too-many-requests')) {
      return AuthException(
        message: 'Too many failed attempts. Please try again later',
        code: 'too-many-requests',
        originalError: error,
      );
    }

    return AuthException(
      message: 'Authentication failed. Please try again',
      code: 'auth_unknown',
      originalError: error,
    );
  }

  static AppException _handleFirestoreException(dynamic error) {
    final errorString = error.toString().toLowerCase();

    if (errorString.contains('permission-denied')) {
      return FirebaseException(
        message: 'You don\'t have permission to perform this action',
        code: 'permission-denied',
        originalError: error,
      );
    }

    if (errorString.contains('not-found')) {
      return FirebaseException(
        message: 'The requested data was not found',
        code: 'document-not-found',
        originalError: error,
      );
    }

    if (errorString.contains('already-exists')) {
      return FirebaseException(
        message: 'This item already exists',
        code: 'document-already-exists',
        originalError: error,
      );
    }

    if (errorString.contains('resource-exhausted')) {
      return FirebaseException(
        message: 'Service temporarily unavailable. Please try again later',
        code: 'resource-exhausted',
        originalError: error,
      );
    }

    if (errorString.contains('unavailable')) {
      return NetworkException(
        message: 'Service temporarily unavailable. Please check your connection',
        code: 'service-unavailable',
        originalError: error,
      );
    }

    return FirebaseException(
      message: 'Database operation failed',
      code: 'firestore_unknown',
      originalError: error,
    );
  }

  static AppException _handleStorageException(dynamic error) {
    final errorString = error.toString().toLowerCase();

    if (errorString.contains('unauthorized')) {
      return StorageException(
        message: 'You don\'t have permission to upload files',
        code: 'storage-unauthorized',
        originalError: error,
      );
    }

    if (errorString.contains('object-not-found')) {
      return StorageException(
        message: 'File not found',
        code: 'object-not-found',
        originalError: error,
      );
    }

    if (errorString.contains('quota-exceeded')) {
      return StorageException(
        message: 'Storage quota exceeded',
        code: 'quota-exceeded',
        originalError: error,
      );
    }

    if (errorString.contains('invalid-format')) {
      return StorageException(
        message: 'Invalid file format',
        code: 'invalid-format',
        originalError: error,
      );
    }

    if (errorString.contains('canceled')) {
      return StorageException(
        message: 'Upload was canceled',
        code: 'upload-canceled',
        originalError: error,
      );
    }

    return StorageException(
      message: 'File upload failed',
      code: 'storage_unknown',
      originalError: error,
    );
  }
}