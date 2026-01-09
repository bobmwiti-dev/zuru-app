import 'package:zuru_app/domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.email,
    required super.privacySettings,
    required super.preferences,
    required super.createdAt,
    super.displayName,
    super.bio,
    super.avatarUrl,
    super.friendIds,
    super.lastLoginAt,
    super.isEmailVerified,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      displayName: json['displayName'] as String?,
      bio: json['bio'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      friendIds: (json['friendIds'] as List<dynamic>?)?.cast<String>() ?? [],
      privacySettings:
          json['privacySettings'] != null
              ? PrivacySettingsModel.fromJson(
                json['privacySettings'] as Map<String, dynamic>,
              )
              : const PrivacySettingsModel(),
      preferences:
          json['preferences'] != null
              ? UserPreferencesModel.fromJson(
                json['preferences'] as Map<String, dynamic>,
              )
              : const UserPreferencesModel(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastLoginAt:
          json['lastLoginAt'] != null
              ? DateTime.parse(json['lastLoginAt'] as String)
              : null,
      isEmailVerified: json['isEmailVerified'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'bio': bio,
      'avatarUrl': avatarUrl,
      'friendIds': friendIds,
      'privacySettings':
          PrivacySettingsModel.fromEntity(privacySettings).toJson(),
      'preferences': UserPreferencesModel.fromEntity(preferences).toJson(),
      'createdAt': createdAt.toIso8601String(),
      'lastLoginAt': lastLoginAt?.toIso8601String(),
      'isEmailVerified': isEmailVerified,
    };
  }

  factory UserModel.fromEntity(User user) {
    return UserModel(
      id: user.id,
      email: user.email,
      displayName: user.displayName,
      bio: user.bio,
      avatarUrl: user.avatarUrl,
      friendIds: user.friendIds,
      privacySettings: PrivacySettingsModel.fromEntity(user.privacySettings),
      preferences: UserPreferencesModel.fromEntity(user.preferences),
      createdAt: user.createdAt,
      lastLoginAt: user.lastLoginAt,
      isEmailVerified: user.isEmailVerified,
    );
  }

  User toEntity() {
    return User(
      id: id,
      email: email,
      displayName: displayName,
      bio: bio,
      avatarUrl: avatarUrl,
      friendIds: friendIds,
      privacySettings: privacySettings,
      preferences: preferences,
      createdAt: createdAt,
      lastLoginAt: lastLoginAt,
      isEmailVerified: isEmailVerified,
    );
  }
}

class PrivacySettingsModel extends PrivacySettings {
  const PrivacySettingsModel({
    super.profileIsPublic,
    super.showLocationHistory,
    super.allowFriendRequests,
    super.showMoodHistory,
    super.blockedUserIds,
  });

  factory PrivacySettingsModel.fromJson(Map<String, dynamic> json) {
    return PrivacySettingsModel(
      profileIsPublic: json['profileIsPublic'] as bool? ?? false,
      showLocationHistory: json['showLocationHistory'] as bool? ?? false,
      allowFriendRequests: json['allowFriendRequests'] as bool? ?? true,
      showMoodHistory: json['showMoodHistory'] as bool? ?? false,
      blockedUserIds:
          (json['blockedUserIds'] as List<dynamic>?)?.cast<String>() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'profileIsPublic': profileIsPublic,
      'showLocationHistory': showLocationHistory,
      'allowFriendRequests': allowFriendRequests,
      'showMoodHistory': showMoodHistory,
      'blockedUserIds': blockedUserIds,
    };
  }

  factory PrivacySettingsModel.fromEntity(PrivacySettings settings) {
    return PrivacySettingsModel(
      profileIsPublic: settings.profileIsPublic,
      showLocationHistory: settings.showLocationHistory,
      allowFriendRequests: settings.allowFriendRequests,
      showMoodHistory: settings.showMoodHistory,
      blockedUserIds: settings.blockedUserIds,
    );
  }
}

class UserPreferencesModel extends UserPreferences {
  const UserPreferencesModel({
    super.enableNotifications,
    super.autoSaveDrafts,
    super.defaultPrivacyLevel,
    super.enableWeatherIntegration,
    super.enableLocationTracking,
    super.theme,
    super.language,
    super.customSettings,
  });

  factory UserPreferencesModel.fromJson(Map<String, dynamic> json) {
    return UserPreferencesModel(
      enableNotifications: json['enableNotifications'] as bool? ?? true,
      autoSaveDrafts: json['autoSaveDrafts'] as bool? ?? true,
      defaultPrivacyLevel: json['defaultPrivacyLevel'] as String? ?? 'private',
      enableWeatherIntegration:
          json['enableWeatherIntegration'] as bool? ?? true,
      enableLocationTracking: json['enableLocationTracking'] as bool? ?? true,
      theme: json['theme'] as String? ?? 'system',
      language: json['language'] as String? ?? 'en',
      customSettings: (json['customSettings'] as Map<String, dynamic>?) ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'enableNotifications': enableNotifications,
      'autoSaveDrafts': autoSaveDrafts,
      'defaultPrivacyLevel': defaultPrivacyLevel,
      'enableWeatherIntegration': enableWeatherIntegration,
      'enableLocationTracking': enableLocationTracking,
      'theme': theme,
      'language': language,
      'customSettings': customSettings,
    };
  }

  factory UserPreferencesModel.fromEntity(UserPreferences preferences) {
    return UserPreferencesModel(
      enableNotifications: preferences.enableNotifications,
      autoSaveDrafts: preferences.autoSaveDrafts,
      defaultPrivacyLevel: preferences.defaultPrivacyLevel,
      enableWeatherIntegration: preferences.enableWeatherIntegration,
      enableLocationTracking: preferences.enableLocationTracking,
      theme: preferences.theme,
      language: preferences.language,
      customSettings: preferences.customSettings,
    );
  }
}
