import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/exceptions/app_exception.dart';
import '../models/user_model.dart';
import 'firestore_repository.dart';

/// Repository for user profile operations
class UserRepository extends FirestoreRepository {
  static const String _usersCollection = 'users';
  static const String _userStatsCollection = 'user_stats';

  /// Create or update user profile
  Future<UserModel> createOrUpdateUserProfile(UserModel user) async {
    return await executeOperation(() async {
      final userDoc = doc('$_usersCollection/${user.id}');

      final userData = user.toJson();
      await userDoc.set(userData, SetOptions(merge: true));

      // Update user stats
      await _updateUserStats(user.id);

      return user;
    });
  }

  /// Get user profile by ID
  Future<UserModel?> getUserProfile(String userId) async {
    return await executeOperation(() async {
      final docSnapshot = await getDocument('$_usersCollection/$userId');

      if (!docSnapshot.exists || docSnapshot.data() == null) {
        return null;
      }

      return UserModel.fromJson({
        ...docSnapshot.data()!,
        'id': docSnapshot.id,
      });
    });
  }

  /// Get current user profile
  Future<UserModel?> getCurrentUserProfile() async {
    if (currentUserId == null) return null;
    return await getUserProfile(currentUserId!);
  }

  /// Update user profile
  Future<UserModel> updateUserProfile(String userId, Map<String, dynamic> updates) async {
    return await executeOperation(() async {
      await updateDocument('$_usersCollection/$userId', updates);

      // Get updated profile
      final updatedProfile = await getUserProfile(userId);
      if (updatedProfile == null) {
        throw DataException(message: 'Failed to retrieve updated profile');
      }

      return updatedProfile;
    });
  }

  /// Delete user profile (soft delete by setting deleted flag)
  Future<void> deleteUserProfile(String userId) async {
    return await executeOperation(() async {
      await updateDocument('$_usersCollection/$userId', {
        'isDeleted': true,
        'deletedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  /// Search users by display name or email
  Future<List<UserModel>> searchUsers(String query, {int limit = 20}) async {
    return await executeOperation(() async {
      final querySnapshot = await getDocuments(
        _usersCollection,
        queryBuilder: (query) => query
            .where('isDeleted', isEqualTo: false)
            .orderBy('displayName')
            .limit(limit),
      );

      return querySnapshot.docs
          .map((doc) => UserModel.fromJson({
                ...doc.data(),
                'id': doc.id,
              }))
          .where((user) =>
              user.displayName?.toLowerCase().contains(query.toLowerCase()) == true ||
              user.email.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  /// Get users by IDs
  Future<List<UserModel>> getUsersByIds(List<String> userIds) async {
    if (userIds.isEmpty) return [];

    return await executeOperation(() async {
      final querySnapshot = await getDocuments(
        _usersCollection,
        queryBuilder: (query) => query
            .where(FieldPath.documentId, whereIn: userIds.take(10).toList()) // Firestore limit
            .where('isDeleted', isEqualTo: false),
      );

      return querySnapshot.docs
          .map((doc) => UserModel.fromJson({
                ...doc.data(),
                'id': doc.id,
              }))
          .toList();
    });
  }

  /// Get user statistics
  Future<UserStats> getUserStats(String userId) async {
    return await executeOperation(() async {
      final docSnapshot = await getDocument('$_userStatsCollection/$userId');

      if (!docSnapshot.exists || docSnapshot.data() == null) {
        return UserStats.empty();
      }

      return UserStats.fromJson(docSnapshot.data()!);
    });
  }

  /// Update user statistics
  Future<void> _updateUserStats(String userId) async {
    try {
      // This would typically be called by cloud functions or triggers
      // For now, we'll do basic stats calculation
      final journalsCount = await _countUserJournals(userId);
      final friendsCount = await _countUserFriends(userId);

      await setDocument('$_userStatsCollection/$userId', {
        'journalsCount': journalsCount,
        'friendsCount': friendsCount,
        'lastActivity': FieldValue.serverTimestamp(),
      }, merge: true);
    } catch (e) {
      // Don't fail the main operation if stats update fails
      // Log error using ConsoleLogger if needed
    }
  }

  /// Count user's journals
  Future<int> _countUserJournals(String userId) async {
    try {
      final querySnapshot = await getDocuments(
        'journals',
        queryBuilder: (query) => query
            .where('userId', isEqualTo: userId)
            .where('isDeleted', isEqualTo: false),
      );
      return querySnapshot.docs.length;
    } catch (e) {
      return 0;
    }
  }

  /// Count user's friends
  Future<int> _countUserFriends(String userId) async {
    try {
      final querySnapshot = await getDocuments(
        'friends',
        queryBuilder: (query) => query
            .where('userId', isEqualTo: userId)
            .where('status', isEqualTo: 'accepted'),
      );
      return querySnapshot.docs.length;
    } catch (e) {
      return 0;
    }
  }

  /// Listen to user profile changes
  Stream<UserModel?> listenToUserProfile(String userId) {
    return listenToDocument('$_usersCollection/$userId').map((snapshot) {
      if (!snapshot.exists || snapshot.data() == null) {
        return null;
      }
      return UserModel.fromJson({
        ...snapshot.data()!,
        'id': snapshot.id,
      });
    });
  }

  /// Listen to current user profile changes
  Stream<UserModel?> listenToCurrentUserProfile() {
    if (currentUserId == null) return Stream.value(null);
    return listenToUserProfile(currentUserId!);
  }
}