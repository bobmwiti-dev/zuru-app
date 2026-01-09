import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String email;
  final String? displayName;
  final String? bio;
  final String? avatarUrl;
  final List<String> friendIds;
  final PrivacySettings privacySettings;
  final UserPreferences preferences;
  final DateTime createdAt;
  final DateTime? lastLoginAt;
  final bool isEmailVerified;

  const User({
    required this.id,
    required this.email,
    required this.privacySettings,
    required this.preferences,
    required this.createdAt,
    this.displayName,
    this.bio,
    this.avatarUrl,
    this.friendIds = const [],
    this.lastLoginAt,
    this.isEmailVerified = false,
  });

  @override
  List<Object?> get props => [
    id,
    email,
    displayName,
    bio,
    avatarUrl,
    friendIds,
    privacySettings,
    preferences,
    createdAt,
    lastLoginAt,
    isEmailVerified,
  ];

  User copyWith({
    String? id,
    String? email,
    String? displayName,
    String? bio,
    String? avatarUrl,
    List<String>? friendIds,
    PrivacySettings? privacySettings,
    UserPreferences? preferences,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    bool? isEmailVerified,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      bio: bio ?? this.bio,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      friendIds: friendIds ?? this.friendIds,
      privacySettings: privacySettings ?? this.privacySettings,
      preferences: preferences ?? this.preferences,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
    );
  }
}

class PrivacySettings extends Equatable {
  final bool profileIsPublic;
  final bool showLocationHistory;
  final bool allowFriendRequests;
  final bool showMoodHistory;
  final List<String> blockedUserIds;

  const PrivacySettings({
    this.profileIsPublic = false,
    this.showLocationHistory = false,
    this.allowFriendRequests = true,
    this.showMoodHistory = false,
    this.blockedUserIds = const [],
  });

  @override
  List<Object?> get props => [
    profileIsPublic,
    showLocationHistory,
    allowFriendRequests,
    showMoodHistory,
    blockedUserIds,
  ];

  PrivacySettings copyWith({
    bool? profileIsPublic,
    bool? showLocationHistory,
    bool? allowFriendRequests,
    bool? showMoodHistory,
    List<String>? blockedUserIds,
  }) {
    return PrivacySettings(
      profileIsPublic: profileIsPublic ?? this.profileIsPublic,
      showLocationHistory: showLocationHistory ?? this.showLocationHistory,
      allowFriendRequests: allowFriendRequests ?? this.allowFriendRequests,
      showMoodHistory: showMoodHistory ?? this.showMoodHistory,
      blockedUserIds: blockedUserIds ?? this.blockedUserIds,
    );
  }
}

class UserPreferences extends Equatable {
  final bool enableNotifications;
  final bool autoSaveDrafts;
  final String defaultPrivacyLevel; // 'private', 'friends', 'public'
  final bool enableWeatherIntegration;
  final bool enableLocationTracking;
  final String theme; // 'light', 'dark', 'system'
  final String language;
  final Map<String, dynamic> customSettings;

  const UserPreferences({
    this.enableNotifications = true,
    this.autoSaveDrafts = true,
    this.defaultPrivacyLevel = 'private',
    this.enableWeatherIntegration = true,
    this.enableLocationTracking = true,
    this.theme = 'system',
    this.language = 'en',
    this.customSettings = const {},
  });

  @override
  List<Object?> get props => [
    enableNotifications,
    autoSaveDrafts,
    defaultPrivacyLevel,
    enableWeatherIntegration,
    enableLocationTracking,
    theme,
    language,
    customSettings,
  ];

  UserPreferences copyWith({
    bool? enableNotifications,
    bool? autoSaveDrafts,
    String? defaultPrivacyLevel,
    bool? enableWeatherIntegration,
    bool? enableLocationTracking,
    String? theme,
    String? language,
    Map<String, dynamic>? customSettings,
  }) {
    return UserPreferences(
      enableNotifications: enableNotifications ?? this.enableNotifications,
      autoSaveDrafts: autoSaveDrafts ?? this.autoSaveDrafts,
      defaultPrivacyLevel: defaultPrivacyLevel ?? this.defaultPrivacyLevel,
      enableWeatherIntegration: enableWeatherIntegration ?? this.enableWeatherIntegration,
      enableLocationTracking: enableLocationTracking ?? this.enableLocationTracking,
      theme: theme ?? this.theme,
      language: language ?? this.language,
      customSettings: customSettings ?? this.customSettings,
    );
  }
}