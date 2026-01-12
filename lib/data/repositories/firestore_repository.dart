import 'package:cloud_firestore/cloud_firestore.dart' as fs;
import 'package:firebase_auth/firebase_auth.dart' as auth;
import '../../core/exceptions/app_exception.dart';
import '../../core/exceptions/firebase_exceptions.dart';

/// Base repository for Firestore operations
abstract class FirestoreRepository {
  final fs.FirebaseFirestore _firestore = fs.FirebaseFirestore.instance;
  final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;

  fs.FirebaseFirestore get firestore => _firestore;

  /// Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  /// Get current user
  auth.User? get currentUser => _auth.currentUser;

  /// Ensure user is authenticated
  void _ensureAuthenticated() {
    if (currentUserId == null) {
      throw AuthenticationException(
        message: 'User must be authenticated to perform this operation',
        code: 'not_authenticated',
      );
    }
  }

  /// Execute a Firestore operation with error handling
  Future<T> executeOperation<T>(Future<T> Function() operation) async {
    try {
      _ensureAuthenticated();
      return await operation();
    } on fs.FirebaseException catch (e) {
      throw FirebaseExceptions.handleFirebaseException(e);
    } catch (e) {
      throw UnknownException(
        message: 'An unexpected error occurred: ${e.toString()}',
        code: 'unknown_error',
        originalException: e,
      );
    }
  }

  /// Get a document reference
  fs.DocumentReference<Map<String, dynamic>> doc(String path) {
    return _firestore.doc(path);
  }

  /// Get a collection reference
  fs.CollectionReference<Map<String, dynamic>> collection(String path) {
    return _firestore.collection(path);
  }

  /// Create a new document with auto-generated ID
  Future<fs.DocumentReference<Map<String, dynamic>>> addDocument(
    String collectionPath,
    Map<String, dynamic> data,
  ) async {
    return await executeOperation(() async {
      final docRef = await collection(collectionPath).add({
        ...data,
        'createdAt': fs.FieldValue.serverTimestamp(),
        'updatedAt': fs.FieldValue.serverTimestamp(),
        'createdBy': currentUserId,
      });
      return docRef;
    });
  }

  /// Set a document (create or overwrite)
  Future<void> setDocument(
    String documentPath,
    Map<String, dynamic> data, {
    bool merge = false,
  }) async {
    return await executeOperation(() async {
      await doc(documentPath).set({
        ...data,
        'updatedAt': fs.FieldValue.serverTimestamp(),
        if (!merge) ...{
          'createdAt': fs.FieldValue.serverTimestamp(),
          'createdBy': currentUserId,
        },
      }, fs.SetOptions(merge: merge));
    });
  }

  /// Update an existing document
  Future<void> updateDocument(
    String documentPath,
    Map<String, dynamic> data,
  ) async {
    return await executeOperation(() async {
      await doc(
        documentPath,
      ).update({...data, 'updatedAt': fs.FieldValue.serverTimestamp()});
    });
  }

  /// Delete a document
  Future<void> deleteDocument(String documentPath) async {
    return await executeOperation(() async {
      await doc(documentPath).delete();
    });
  }

  /// Get a document
  Future<fs.DocumentSnapshot<Map<String, dynamic>>> getDocument(
    String documentPath,
  ) async {
    return await executeOperation(() async {
      return await doc(documentPath).get();
    });
  }

  /// Get documents from a collection with optional query
  Future<fs.QuerySnapshot<Map<String, dynamic>>> getDocuments(
    String collectionPath, {
    fs.Query<Map<String, dynamic>> Function(fs.Query<Map<String, dynamic>>)?
    queryBuilder,
  }) async {
    return await executeOperation(() async {
      fs.Query<Map<String, dynamic>> query = collection(collectionPath);
      if (queryBuilder != null) {
        query = queryBuilder(query);
      }
      return await query.get();
    });
  }

  /// Listen to document changes
  Stream<fs.DocumentSnapshot<Map<String, dynamic>>> listenToDocument(
    String documentPath,
  ) {
    return doc(documentPath).snapshots();
  }

  /// Listen to collection changes
  Stream<fs.QuerySnapshot<Map<String, dynamic>>> listenToCollection(
    String collectionPath, {
    fs.Query<Map<String, dynamic>> Function(fs.Query<Map<String, dynamic>>)?
    queryBuilder,
  }) {
    fs.Query<Map<String, dynamic>> query = collection(collectionPath);
    if (queryBuilder != null) {
      query = queryBuilder(query);
    }
    return query.snapshots();
  }
}
