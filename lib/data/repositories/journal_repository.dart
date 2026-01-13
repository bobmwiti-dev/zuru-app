import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/exceptions/app_exception.dart';
import '../models/journal_model.dart';
import '../../domain/entities/journal_entry.dart';
import '../../domain/entities/place.dart';
import 'firestore_repository.dart';

/// Repository for journal/memory operations
class JournalRepository extends FirestoreRepository {
  static const String _journalsCollection = 'journals';
  static const String _usersCollection = 'users';
  static const String _likedJournalsSubcollection = 'liked_journals';
  static const String _savedJournalsSubcollection = 'saved_journals';

  /// Create a new journal entry from domain entity
  Future<JournalEntry> createEntry(JournalEntry entry) async {
    // Convert JournalEntry to JournalModel
    final journalModel = JournalModel(
      id: entry.id,
      userId: entry.userId,
      title: entry.title,
      content: entry.description,
      mood: entry.mood?.displayName,
      latitude: entry.place.latitude,
      longitude: entry.place.longitude,
      locationName: entry.place.name,
      photos: entry.photos,
      tags: entry.tags,
      isPublic: entry.privacyLevel == PrivacyLevel.public,
      createdAt: entry.createdAt,
      updatedAt: entry.updatedAt,
    );

    final createdModel = await createJournal(journalModel);

    // Convert back to JournalEntry
    return entry.copyWith(id: createdModel.id ?? entry.id);
  }

  /// Create a new journal entry
  Future<JournalModel> createJournal(JournalModel journal) async {
    return await executeOperation(() async {
      final docRef = await addDocument(_journalsCollection, journal.toJson());
      final newJournal = journal.copyWith(id: docRef.id);

      // Update user stats
      await _updateUserJournalCount(currentUserId!);

      return newJournal;
    });
  }

  /// Get journal by ID
  Future<JournalModel?> getJournal(String journalId) async {
    return await executeOperation(() async {
      final docSnapshot = await getDocument('$_journalsCollection/$journalId');

      if (!docSnapshot.exists || docSnapshot.data() == null) {
        return null;
      }

      final data = docSnapshot.data()!;
      if (data['isDeleted'] == true) {
        return null; // Soft deleted
      }

      return JournalModel.fromJson({
        ...data,
        'id': docSnapshot.id,
      });
    });
  }

  /// Update journal entry
  Future<JournalModel> updateJournal(String journalId, Map<String, dynamic> updates) async {
    return await executeOperation(() async {
      await updateDocument('$_journalsCollection/$journalId', updates);

      // Get updated journal
      final updatedJournal = await getJournal(journalId);
      if (updatedJournal == null) {
        throw DataException(message: 'Failed to retrieve updated journal');
      }

      return updatedJournal;
    });
  }

  /// Delete journal entry (soft delete)
  Future<void> deleteJournal(String journalId) async {
    return await executeOperation(() async {
      await updateDocument('$_journalsCollection/$journalId', {
        'isDeleted': true,
        'deletedAt': FieldValue.serverTimestamp(),
      });

      // Update user stats
      await _updateUserJournalCount(currentUserId!);
    });
  }

  /// Get user's journals
  Future<List<JournalModel>> getUserJournals({
    String? userId,
    int limit = 20,
    DocumentSnapshot? startAfter,
    String? mood,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final targetUserId = userId ?? currentUserId;
    if (targetUserId == null) return [];

    return await executeOperation(() async {
      Query<Map<String, dynamic>> query = collection(_journalsCollection)
          .where('userId', isEqualTo: targetUserId)
          .where('isDeleted', isEqualTo: false)
          .orderBy('createdAt', descending: true)
          .limit(limit);

      // Apply filters
      if (mood != null) {
        query = query.where('mood', isEqualTo: mood);
      }

      if (startDate != null) {
        query = query.where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
      }

      if (endDate != null) {
        query = query.where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(endDate));
      }

      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }

      final querySnapshot = await query.get();

      return querySnapshot.docs
          .map((doc) => JournalModel.fromJson({
                ...doc.data(),
                'id': doc.id,
              }))
          .toList();
    });
  }

  /// Get journal entries as domain entities
  Future<List<JournalEntry>> getEntries({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
    int? offset,
  }) async {
    final journals = await getUserJournals(
      userId: userId,
      limit: limit ?? 20,
      startDate: startDate,
      endDate: endDate,
    );

    // Convert JournalModel to JournalEntry
    return journals.map((model) {
      // Create Place from location data
      final place = Place(
        id: model.id ?? 'unknown',
        name: model.locationName ?? 'Unknown Location',
        latitude: model.latitude ?? 0.0,
        longitude: model.longitude ?? 0.0,
        category: PlaceCategory.other,
        address: model.locationName,
      );

      // Determine privacy level
      final privacyLevel = model.isPublic 
          ? PrivacyLevel.public 
          : PrivacyLevel.private;

      return JournalEntry(
        id: model.id ?? '',
        userId: model.userId,
        title: model.title,
        description: model.content,
        photos: model.photos,
        videos: const [], // JournalModel doesn't store videos
        tags: model.tags,
        mood: null, // Mood conversion would require more data
        place: place,
        createdAt: model.createdAt,
        updatedAt: model.updatedAt,
        privacyLevel: privacyLevel,
        companionIds: const [], // JournalModel doesn't store companionIds
      );
    }).toList();
  }

  /// Get public journals (for sharing/discovery)
  Future<List<JournalModel>> getPublicJournals({
    int limit = 20,
    DocumentSnapshot? startAfter,
    String? mood,
  }) async {
    return await executeOperation(() async {
      Query<Map<String, dynamic>> query = collection(_journalsCollection)
          .where('isPublic', isEqualTo: true)
          .where('isDeleted', isEqualTo: false)
          .orderBy('createdAt', descending: true)
          .limit(limit);

      if (mood != null) {
        query = query.where('mood', isEqualTo: mood);
      }

      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }

      final querySnapshot = await query.get();

      return querySnapshot.docs
          .map((doc) => JournalModel.fromJson({
                ...doc.data(),
                'id': doc.id,
              }))
          .toList();
    });
  }

  /// Search journals by content
  Future<List<JournalModel>> searchJournals(String query, {
    bool includePrivate = false,
    int limit = 20,
  }) async {
    return await executeOperation(() async {
      Query<Map<String, dynamic>> firestoreQuery = collection(_journalsCollection)
          .where('isDeleted', isEqualTo: false)
          .orderBy('createdAt', descending: true)
          .limit(limit);

      if (!includePrivate) {
        firestoreQuery = firestoreQuery.where('isPublic', isEqualTo: true);
      }

      final querySnapshot = await firestoreQuery.get();

      // Client-side filtering since Firestore doesn't support full-text search
      return querySnapshot.docs
          .map((doc) => JournalModel.fromJson({
                ...doc.data(),
                'id': doc.id,
              }))
          .where((journal) =>
              journal.title.toLowerCase().contains(query.toLowerCase()) ||
              (journal.content?.toLowerCase().contains(query.toLowerCase()) ?? false) ||
              journal.tags.any((tag) => tag.toLowerCase().contains(query.toLowerCase())))
          .toList();
    });
  }

  /// Get journals by mood
  Future<List<JournalModel>> getJournalsByMood(String mood, {
    int limit = 20,
    bool publicOnly = true,
  }) async {
    return await executeOperation(() async {
      Query<Map<String, dynamic>> query = collection(_journalsCollection)
          .where('mood', isEqualTo: mood)
          .where('isDeleted', isEqualTo: false)
          .orderBy('createdAt', descending: true)
          .limit(limit);

      if (publicOnly) {
        query = query.where('isPublic', isEqualTo: true);
      }

      final querySnapshot = await query.get();

      return querySnapshot.docs
          .map((doc) => JournalModel.fromJson({
                ...doc.data(),
                'id': doc.id,
              }))
          .toList();
    });
  }

  /// Toggle journal privacy
  Future<void> toggleJournalPrivacy(String journalId) async {
    return await executeOperation(() async {
      final journal = await getJournal(journalId);
      if (journal == null) {
        throw DataException(message: 'Journal not found');
      }

      await updateDocument('$_journalsCollection/$journalId', {
        'isPublic': !journal.isPublic,
      });
    });
  }

  /// Add tags to journal
  Future<void> addTagsToJournal(String journalId, List<String> tags) async {
    return await executeOperation(() async {
      await updateDocument('$_journalsCollection/$journalId', {
        'tags': FieldValue.arrayUnion(tags),
      });
    });
  }

  /// Remove tags from journal
  Future<void> removeTagsFromJournal(String journalId, List<String> tags) async {
    return await executeOperation(() async {
      await updateDocument('$_journalsCollection/$journalId', {
        'tags': FieldValue.arrayRemove(tags),
      });
    });
  }

  Future<void> toggleLike(String journalId, {required bool isLiked}) async {
    return await executeOperation(() async {
      final uid = currentUserId;
      if (uid == null) {
        throw AuthenticationException(message: 'User not authenticated');
      }

      final journalRef = firestore.collection(_journalsCollection).doc(journalId);
      final likeRef = firestore
          .collection(_usersCollection)
          .doc(uid)
          .collection(_likedJournalsSubcollection)
          .doc(journalId);

      await firestore.runTransaction((txn) async {
        final journalSnap = await txn.get(journalRef);
        final likeSnap = await txn.get(likeRef);

        final journalData = journalSnap.data();
        final currentCount = (journalData?['likesCount'] as num?)?.toInt() ?? 0;

        if (isLiked) {
          if (likeSnap.exists) return;

          txn.set(likeRef, {
            'createdAt': FieldValue.serverTimestamp(),
          });
          txn.update(journalRef, {
            'likesCount': currentCount + 1,
          });
        } else {
          if (!likeSnap.exists) return;

          txn.delete(likeRef);
          txn.update(journalRef, {
            'likesCount': currentCount > 0 ? currentCount - 1 : 0,
          });
        }
      });
    });
  }

  Future<void> toggleSave(String journalId, {required bool isSaved}) async {
    return await executeOperation(() async {
      final uid = currentUserId;
      if (uid == null) {
        throw AuthenticationException(message: 'User not authenticated');
      }

      final journalRef = firestore.collection(_journalsCollection).doc(journalId);
      final saveRef = firestore
          .collection(_usersCollection)
          .doc(uid)
          .collection(_savedJournalsSubcollection)
          .doc(journalId);

      await firestore.runTransaction((txn) async {
        final journalSnap = await txn.get(journalRef);
        final saveSnap = await txn.get(saveRef);

        final journalData = journalSnap.data();
        final currentCount = (journalData?['savesCount'] as num?)?.toInt() ?? 0;

        if (isSaved) {
          if (saveSnap.exists) return;

          txn.set(saveRef, {
            'createdAt': FieldValue.serverTimestamp(),
          });
          txn.update(journalRef, {
            'savesCount': currentCount + 1,
          });
        } else {
          if (!saveSnap.exists) return;

          txn.delete(saveRef);
          txn.update(journalRef, {
            'savesCount': currentCount > 0 ? currentCount - 1 : 0,
          });
        }
      });
    });
  }

  Future<Set<String>> getLikedJournalIds(List<String> journalIds) async {
    return await executeOperation(() async {
      final uid = currentUserId;
      if (uid == null) {
        throw AuthenticationException(message: 'User not authenticated');
      }

      final ids = journalIds.where((e) => e.trim().isNotEmpty).toList();
      if (ids.isEmpty) return <String>{};

      final liked = <String>{};
      final likedCol = firestore
          .collection(_usersCollection)
          .doc(uid)
          .collection(_likedJournalsSubcollection);

      for (final chunk in _chunksOf(ids, 10)) {
        final snap = await likedCol
            .where(FieldPath.documentId, whereIn: chunk)
            .get();
        liked.addAll(snap.docs.map((d) => d.id));
      }
      return liked;
    });
  }

  Future<Set<String>> getSavedJournalIds(List<String> journalIds) async {
    return await executeOperation(() async {
      final uid = currentUserId;
      if (uid == null) {
        throw AuthenticationException(message: 'User not authenticated');
      }

      final ids = journalIds.where((e) => e.trim().isNotEmpty).toList();
      if (ids.isEmpty) return <String>{};

      final saved = <String>{};
      final savedCol = firestore
          .collection(_usersCollection)
          .doc(uid)
          .collection(_savedJournalsSubcollection);

      for (final chunk in _chunksOf(ids, 10)) {
        final snap = await savedCol
            .where(FieldPath.documentId, whereIn: chunk)
            .get();
        saved.addAll(snap.docs.map((d) => d.id));
      }
      return saved;
    });
  }

  Iterable<List<T>> _chunksOf<T>(List<T> items, int size) sync* {
    for (var i = 0; i < items.length; i += size) {
      yield items.sublist(i, i + size > items.length ? items.length : i + size);
    }
  }

  /// Update user journal count
  Future<void> _updateUserJournalCount(String userId) async {
    try {
      final journalsCount = await _countUserJournals(userId);
      await setDocument('user_stats/$userId', {
        'journalsCount': journalsCount,
        'lastActivity': FieldValue.serverTimestamp(),
      }, merge: true);
    } catch (e) {
      // Don't fail the main operation
      // Log error using ConsoleLogger if needed
    }
  }

  /// Count user's journals
  Future<int> _countUserJournals(String userId) async {
    try {
      final querySnapshot = await getDocuments(
        _journalsCollection,
        queryBuilder: (query) => query
            .where('userId', isEqualTo: userId)
            .where('isDeleted', isEqualTo: false),
      );
      return querySnapshot.docs.length;
    } catch (e) {
      return 0;
    }
  }

  /// Listen to user's journals
  Stream<List<JournalModel>> listenToUserJournals({String? userId}) {
    final targetUserId = userId ?? currentUserId;
    if (targetUserId == null) return Stream.value([]);

    return listenToCollection(
      _journalsCollection,
      queryBuilder: (query) => query
          .where('userId', isEqualTo: targetUserId)
          .where('isDeleted', isEqualTo: false)
          .orderBy('createdAt', descending: true)
          .limit(50),
    ).map((snapshot) {
      return snapshot.docs
          .map((doc) => JournalModel.fromJson({
                ...doc.data(),
                'id': doc.id,
              }))
          .toList();
    });
  }

  /// Listen to public journals feed
  Stream<List<JournalModel>> listenToPublicJournals() {
    return listenToCollection(
      _journalsCollection,
      queryBuilder: (query) => query
          .where('isPublic', isEqualTo: true)
          .where('isDeleted', isEqualTo: false)
          .orderBy('createdAt', descending: true)
          .limit(50),
    ).map((snapshot) {
      return snapshot.docs
          .map((doc) => JournalModel.fromJson({
                ...doc.data(),
                'id': doc.id,
              }))
          .toList();
    });
  }
}