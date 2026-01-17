import 'package:firebase_auth/firebase_auth.dart';

import 'app_exception.dart';

/// Firebase-specific exception handling
class FirebaseExceptions {
  static AppException handleFirebaseException(dynamic error) {
    // Handle Firebase Auth exceptions
    if (error is FirebaseAuthException) {
      return _handleAuthException(error);
    }

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
    return FirebaseServiceException(
      message: 'Firebase operation failed',
      code: 'firebase_unknown',
      originalException: error,
    );
  }

  static AppException _handleAuthException(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'user-not-found':
          return AuthenticationException(
            message: 'No account found with this email address',
            code: error.code,
            originalException: error,
          );
        case 'wrong-password':
          return AuthenticationException(
            message: 'Incorrect password',
            code: error.code,
            originalException: error,
          );
        case 'email-already-in-use':
          return AuthenticationException(
            message: 'An account with this email already exists',
            code: error.code,
            originalException: error,
          );
        case 'weak-password':
          return AuthenticationException(
            message: 'Password is too weak. Please choose a stronger password',
            code: error.code,
            originalException: error,
          );
        case 'invalid-email':
          return AuthenticationException(
            message: 'Please enter a valid email address',
            code: error.code,
            originalException: error,
          );
        case 'user-disabled':
          return AuthenticationException(
            message: 'This account has been disabled',
            code: error.code,
            originalException: error,
          );
        case 'too-many-requests':
          return AuthenticationException(
            message: 'Too many failed attempts. Please try again later',
            code: error.code,
            originalException: error,
          );
        case 'operation-not-allowed':
          return AuthenticationException(
            message:
                'This sign-in method is not enabled. Enable Email/Password in Firebase Authentication settings.',
            code: error.code,
            originalException: error,
          );
        case 'unauthorized-domain':
          return AuthenticationException(
            message:
                'This web domain is not authorized for Firebase Authentication. Add localhost to Authorized domains in Firebase Console.',
            code: error.code,
            originalException: error,
          );
        case 'invalid-api-key':
          return AuthenticationException(
            message:
                'Invalid Firebase API key. Check your FIREBASE_API_KEY web configuration.',
            code: error.code,
            originalException: error,
          );
        case 'app-not-authorized':
          return AuthenticationException(
            message:
                'This app is not authorized to use Firebase Authentication. Verify your Firebase project configuration.',
            code: error.code,
            originalException: error,
          );
        case 'network-request-failed':
          return AuthenticationException(
            message: 'Network connection failed. Please check your internet and try again.',
            code: 'network-error',
            originalException: error,
          );
        default:
          return AuthenticationException(
            message: error.message?.isNotEmpty == true
                ? error.message!
                : 'Authentication failed. Please try again',
            code: error.code,
            originalException: error,
          );
      }
    }

    final errorString = error.toString().toLowerCase();

    if (errorString.contains('user-not-found')) {
      return AuthenticationException(
        message: 'No account found with this email address',
        code: 'user-not-found',
        originalException: error,
      );
    }

    if (errorString.contains('wrong-password')) {
      return AuthenticationException(
        message: 'Incorrect password',
        code: 'wrong-password',
        originalException: error,
      );
    }

    if (errorString.contains('email-already-in-use')) {
      return AuthenticationException(
        message: 'An account with this email already exists',
        code: 'email-already-in-use',
        originalException: error,
      );
    }

    if (errorString.contains('weak-password')) {
      return AuthenticationException(
        message: 'Password is too weak. Please choose a stronger password',
        code: 'weak-password',
        originalException: error,
      );
    }

    if (errorString.contains('invalid-email')) {
      return AuthenticationException(
        message: 'Please enter a valid email address',
        code: 'invalid-email',
        originalException: error,
      );
    }

    if (errorString.contains('user-disabled')) {
      return AuthenticationException(
        message: 'This account has been disabled',
        code: 'user-disabled',
        originalException: error,
      );
    }

    if (errorString.contains('too-many-requests')) {
      return AuthenticationException(
        message: 'Too many failed attempts. Please try again later',
        code: 'too-many-requests',
        originalException: error,
      );
    }

    return AuthenticationException(
      message: 'Authentication failed. Please try again',
      code: 'auth_unknown',
      originalException: error,
    );
  }

  static AppException _handleFirestoreException(dynamic error) {
    final errorString = error.toString().toLowerCase();

    if (errorString.contains('permission-denied')) {
      return FirebaseServiceException(
        message: 'You don\'t have permission to perform this action',
        code: 'permission-denied',
        originalException: error,
      );
    }

    if (errorString.contains('not-found')) {
      return FirebaseServiceException(
        message: 'The requested data was not found',
        code: 'document-not-found',
        originalException: error,
      );
    }

    if (errorString.contains('already-exists')) {
      return FirebaseServiceException(
        message: 'This item already exists',
        code: 'document-already-exists',
        originalException: error,
      );
    }

    if (errorString.contains('resource-exhausted')) {
      return FirebaseServiceException(
        message: 'Service temporarily unavailable. Please try again later',
        code: 'resource-exhausted',
        originalException: error,
      );
    }

    if (errorString.contains('unavailable')) {
      return NetworkException(
        message: 'Service temporarily unavailable. Please check your connection',
        code: 'service-unavailable',
        originalException: error,
      );
    }

    return FirebaseServiceException(
      message: 'Database operation failed',
      code: 'firestore_unknown',
      originalException: error,
    );
  }

  static AppException _handleStorageException(dynamic error) {
    final errorString = error.toString().toLowerCase();

    if (errorString.contains('unauthorized')) {
      return StorageException(
        message: 'You don\'t have permission to upload files',
        code: 'storage-unauthorized',
        originalException: error,
      );
    }

    if (errorString.contains('object-not-found')) {
      return StorageException(
        message: 'File not found',
        code: 'object-not-found',
        originalException: error,
      );
    }

    if (errorString.contains('quota-exceeded')) {
      return StorageException(
        message: 'Storage quota exceeded',
        code: 'quota-exceeded',
        originalException: error,
      );
    }

    if (errorString.contains('invalid-format')) {
      return StorageException(
        message: 'Invalid file format',
        code: 'invalid-format',
        originalException: error,
      );
    }

    if (errorString.contains('canceled')) {
      return StorageException(
        message: 'Upload was canceled',
        code: 'upload-canceled',
        originalException: error,
      );
    }

    return StorageException(
      message: 'File upload failed',
      code: 'storage_unknown',
      originalException: error,
    );
  }
}