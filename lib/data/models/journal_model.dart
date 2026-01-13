import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

/// Journal/Memory entry model for Firestore operations
class JournalModel extends Equatable {
  final String? id;
  final String userId;
  final String title;
  final String? content;
  final String? mood;
  final double? latitude;
  final double? longitude;
  final String? locationName;
  final List<String> photos;
  final List<String> tags;
  final int likesCount;
  final int savesCount;
  final bool isPublic;
  final bool isDeleted;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;

  const JournalModel({
    this.id,
    required this.userId,
    required this.title,
    this.content,
    this.mood,
    this.latitude,
    this.longitude,
    this.locationName,
    this.photos = const [],
    this.tags = const [],
    this.likesCount = 0,
    this.savesCount = 0,
    this.isPublic = false,
    this.isDeleted = false,
    required this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  /// Create from Firestore document
  factory JournalModel.fromJson(Map<String, dynamic> json) {
    final legacyLikedBy = (json['likedBy'] as List<dynamic>?)?.length ?? 0;
    final legacySavedBy = (json['savedBy'] as List<dynamic>?)?.length ?? 0;

    return JournalModel(
      id: json['id'] as String?,
      userId: json['userId'] as String,
      title: json['title'] as String,
      content: json['content'] as String?,
      mood: json['mood'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      locationName: json['locationName'] as String?,
      photos: (json['photos'] as List<dynamic>?)?.cast<String>() ?? [],
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
      likesCount: (json['likesCount'] as num?)?.toInt() ?? legacyLikedBy,
      savesCount: (json['savesCount'] as num?)?.toInt() ?? legacySavedBy,
      isPublic: json['isPublic'] as bool? ?? false,
      isDeleted: json['isDeleted'] as bool? ?? false,
      createdAt: (json['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (json['updatedAt'] as Timestamp?)?.toDate(),
      deletedAt: (json['deletedAt'] as Timestamp?)?.toDate(),
    );
  }

  /// Convert to Firestore document format
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'userId': userId,
      'title': title,
      if (content != null) 'content': content,
      if (mood != null) 'mood': mood,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (locationName != null) 'locationName': locationName,
      'photos': photos,
      'tags': tags,
      'likesCount': likesCount,
      'savesCount': savesCount,
      'isPublic': isPublic,
      'isDeleted': isDeleted,
      'createdAt': Timestamp.fromDate(createdAt),
      if (updatedAt != null) 'updatedAt': Timestamp.fromDate(updatedAt!),
      if (deletedAt != null) 'deletedAt': Timestamp.fromDate(deletedAt!),
    };
  }

  /// Create copy with updated fields
  JournalModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? content,
    String? mood,
    double? latitude,
    double? longitude,
    String? locationName,
    List<String>? photos,
    List<String>? tags,
    int? likesCount,
    int? savesCount,
    bool? isPublic,
    bool? isDeleted,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    return JournalModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      content: content ?? this.content,
      mood: mood ?? this.mood,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      locationName: locationName ?? this.locationName,
      photos: photos ?? this.photos,
      tags: tags ?? this.tags,
      likesCount: likesCount ?? this.likesCount,
      savesCount: savesCount ?? this.savesCount,
      isPublic: isPublic ?? this.isPublic,
      isDeleted: isDeleted ?? this.isDeleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  /// Create empty journal for form initialization
  factory JournalModel.empty(String userId) {
    return JournalModel(
      userId: userId,
      title: '',
      createdAt: DateTime.now(),
    );
  }

  /// Check if journal has location data
  bool get hasLocation => latitude != null && longitude != null;

  /// Check if journal has media
  bool get hasMedia => photos.isNotEmpty;

  /// Check if journal has content
  bool get hasContent => content != null && content!.isNotEmpty;

  @override
  List<Object?> get props => [
        id,
        userId,
        title,
        content,
        mood,
        latitude,
        longitude,
        locationName,
        photos,
        tags,
        likesCount,
        savesCount,
        isPublic,
        isDeleted,
        createdAt,
        updatedAt,
        deletedAt,
      ];

  @override
  String toString() {
    return 'JournalModel(id: $id, title: $title, userId: $userId, isPublic: $isPublic)';
  }
}