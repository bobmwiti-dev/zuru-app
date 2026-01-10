import 'package:cloud_firestore/cloud_firestore.dart';

/// Firestore Data Source for Journal Entries
class FirestoreDataSource {
  final FirebaseFirestore _firestore;

  FirestoreDataSource() : _firestore = FirebaseFirestore.instance;

  /// Get journal entries collection reference
  CollectionReference<Map<String, dynamic>> get _journalEntriesCollection =>
      _firestore.collection('journal_entries');

  /// Get users collection reference
  CollectionReference<Map<String, dynamic>> get _usersCollection =>
      _firestore.collection('users');

  /// Create a new journal entry
  Future<DocumentReference<Map<String, dynamic>>> createJournalEntry(
    Map<String, dynamic> entryData,
  ) async {
    return await _journalEntriesCollection.add({
      ...entryData,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Get journal entry by ID
  Future<DocumentSnapshot<Map<String, dynamic>>> getJournalEntry(String id) async {
    return await _journalEntriesCollection.doc(id).get();
  }

  /// Get all journal entries for a user
  Future<QuerySnapshot<Map<String, dynamic>>> getUserJournalEntries(
    String userId, {
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
    DocumentSnapshot? startAfter,
  }) async {
    Query<Map<String, dynamic>> query = _journalEntriesCollection
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true);

    if (startDate != null) {
      query = query.where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
    }

    if (endDate != null) {
      query = query.where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(endDate));
    }

    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }

    if (limit != null) {
      query = query.limit(limit);
    }

    return await query.get();
  }

  /// Update journal entry
  Future<void> updateJournalEntry(String id, Map<String, dynamic> updates) async {
    await _journalEntriesCollection.doc(id).update({
      ...updates,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Delete journal entry
  Future<void> deleteJournalEntry(String id) async {
    await _journalEntriesCollection.doc(id).delete();
  }

  /// Search journal entries
  Future<QuerySnapshot<Map<String, dynamic>>> searchJournalEntries(
    String userId,
    String query,
  ) async {
    // Note: Firestore doesn't support full-text search natively
    // This is a basic implementation - you might want to use Algolia or Elastic Search for production
    return await _journalEntriesCollection
        .where('userId', isEqualTo: userId)
        .where('title', isGreaterThanOrEqualTo: query)
        .where('title', isLessThan: '$query\uf8ff')
        .get();
  }

  /// Create or update user profile
  Future<void> createOrUpdateUser(String userId, Map<String, dynamic> userData) async {
    await _usersCollection.doc(userId).set({
      ...userData,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Get user profile
  Future<DocumentSnapshot<Map<String, dynamic>>> getUser(String userId) async {
    return await _usersCollection.doc(userId).get();
  }

  /// Listen to journal entries changes
  Stream<QuerySnapshot<Map<String, dynamic>>> listenToJournalEntries(String userId) {
    return _journalEntriesCollection
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  /// Batch operations
  Future<void> batchWrite(WriteBatch Function(WriteBatch batch) batchOperations) async {
    final batch = _firestore.batch();
    batchOperations(batch);
    await batch.commit();
  }
}