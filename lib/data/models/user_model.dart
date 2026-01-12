import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

/// User profile model for Firestore operations
class UserModel extends Equatable {
  final String id;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final String? bio;
  final DateTime? dateOfBirth;
  final String? location;
  final List<String> interests;
  final bool isEmailVerified;
  final bool isDeleted;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? lastLoginAt;
  final DateTime? deletedAt;

  const UserModel({
    required this.id,
    required this.email,
    this.displayName,
    this.photoUrl,
    this.bio,
    this.dateOfBirth,
    this.location,
    this.interests = const [],
    this.isEmailVerified = false,
    this.isDeleted = false,
    required this.createdAt,
    this.updatedAt,
    this.lastLoginAt,
    this.deletedAt,
  });

  /// Create from Firestore document
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      displayName: json['displayName'] as String?,
      photoUrl: json['photoUrl'] as String?,
      bio: json['bio'] as String?,
      dateOfBirth: (json['dateOfBirth'] as Timestamp?)?.toDate(),
      location: json['location'] as String?,
      interests: (json['interests'] as List<dynamic>?)?.cast<String>() ?? [],
      isEmailVerified: json['isEmailVerified'] as bool? ?? false,
      isDeleted: json['isDeleted'] as bool? ?? false,
      createdAt: (json['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (json['updatedAt'] as Timestamp?)?.toDate(),
      lastLoginAt: (json['lastLoginAt'] as Timestamp?)?.toDate(),
      deletedAt: (json['deletedAt'] as Timestamp?)?.toDate(),
    );
  }

  /// Convert to Firestore document format
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      if (displayName != null) 'displayName': displayName,
      if (photoUrl != null) 'photoUrl': photoUrl,
      if (bio != null) 'bio': bio,
      if (dateOfBirth != null) 'dateOfBirth': Timestamp.fromDate(dateOfBirth!),
      if (location != null) 'location': location,
      'interests': interests,
      'isEmailVerified': isEmailVerified,
      'isDeleted': isDeleted,
      'createdAt': Timestamp.fromDate(createdAt),
      if (updatedAt != null) 'updatedAt': Timestamp.fromDate(updatedAt!),
      if (lastLoginAt != null) 'lastLoginAt': Timestamp.fromDate(lastLoginAt!),
      if (deletedAt != null) 'deletedAt': Timestamp.fromDate(deletedAt!),
    };
  }

  /// Create from Firebase Auth user
  factory UserModel.fromFirebaseUser(dynamic firebaseUser) {
    return UserModel(
      id: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      displayName: firebaseUser.displayName,
      photoUrl: firebaseUser.photoURL,
      isEmailVerified: firebaseUser.emailVerified ?? false,
      createdAt: firebaseUser.metadata?.creationTime ?? DateTime.now(),
      lastLoginAt: firebaseUser.metadata?.lastSignInTime ?? DateTime.now(),
    );
  }

  /// Create copy with updated fields
  UserModel copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoUrl,
    String? bio,
    DateTime? dateOfBirth,
    String? location,
    List<String>? interests,
    bool? isEmailVerified,
    bool? isDeleted,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastLoginAt,
    DateTime? deletedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      bio: bio ?? this.bio,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      location: location ?? this.location,
      interests: interests ?? this.interests,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      isDeleted: isDeleted ?? this.isDeleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  /// Get display name or fallback to email
  String get displayNameOrEmail => displayName ?? email.split('@').first;

  /// Check if user has complete profile
  bool get hasCompleteProfile =>
      displayName != null && displayName!.isNotEmpty && bio != null && bio!.isNotEmpty;

  @override
  List<Object?> get props => [
        id,
        email,
        displayName,
        photoUrl,
        bio,
        dateOfBirth,
        location,
        interests,
        isEmailVerified,
        isDeleted,
        createdAt,
        updatedAt,
        lastLoginAt,
        deletedAt,
      ];

  @override
  String toString() {
    return 'UserModel(id: $id, email: $email, displayName: $displayName)';
  }
}

/// User statistics model
class UserStats extends Equatable {
  final int journalsCount;
  final int friendsCount;
  final int followersCount;
  final int followingCount;
  final DateTime? lastActivity;

  const UserStats({
    required this.journalsCount,
    required this.friendsCount,
    required this.followersCount,
    required this.followingCount,
    this.lastActivity,
  });

  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      journalsCount: json['journalsCount'] as int? ?? 0,
      friendsCount: json['friendsCount'] as int? ?? 0,
      followersCount: json['followersCount'] as int? ?? 0,
      followingCount: json['followingCount'] as int? ?? 0,
      lastActivity: (json['lastActivity'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'journalsCount': journalsCount,
      'friendsCount': friendsCount,
      'followersCount': followersCount,
      'followingCount': followingCount,
      if (lastActivity != null) 'lastActivity': Timestamp.fromDate(lastActivity!),
    };
  }

  factory UserStats.empty() {
    return const UserStats(
      journalsCount: 0,
      friendsCount: 0,
      followersCount: 0,
      followingCount: 0,
    );
  }

  @override
  List<Object?> get props => [
        journalsCount,
        friendsCount,
        followersCount,
        followingCount,
        lastActivity,
      ];
}