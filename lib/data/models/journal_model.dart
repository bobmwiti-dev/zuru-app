import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

/// Journal/Memory entry model for Firestore operations
class JournalModel extends Equatable {
  final String? id;
  final String userId;
  final String title;
  final String? content;
  final String? mood;

  final String? voiceNoteUrl;
  final int? voiceNoteDurationMs;
  final String? voiceNoteMimeType;

  final double? latitude;
  final double? longitude;
  final String? locationName;
  final String? locationCity;
  final String? locationCountry;
  final String? locationCountryCode;
  final String? locationAdminArea;
  final String? locationSubLocality;
  final String? locationAddress;
  final String? locationSource;
  final List<String> photos;
  final List<String> tags;
  final String? collection;
  final String? entryType;
  final double? reviewRating;
  final int? reviewCostTier;
  final List<String> reviewVibes;
  final bool? reviewWouldReturn;
  final List<String> reviewHighlights;
  final String? reviewTips;
  final int likesCount;
  final int savesCount;
  final bool isPublic;
  final bool isDeleted;
  final List<String> captionSuggestions;
  final List<String> highlightSuggestions;
  final String? selectedCaption;
  final DateTime? suggestionsGeneratedAt;
  final String? suggestionsSource;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;

  const JournalModel({
    this.id,
    required this.userId,
    required this.title,
    this.content,

    this.mood,
    this.voiceNoteUrl,
    this.voiceNoteDurationMs,
    this.voiceNoteMimeType,
    this.latitude,
    this.longitude,
    this.locationName,
    this.locationCity,
    this.locationCountry,
    this.locationCountryCode,
    this.locationAdminArea,
    this.locationSubLocality,
    this.locationAddress,
    this.locationSource,
    this.photos = const [],
    this.tags = const [],
    this.collection,
    this.entryType,
    this.reviewRating,
    this.reviewCostTier,
    this.reviewVibes = const [],
    this.reviewWouldReturn,
    this.reviewHighlights = const [],
    this.reviewTips,
    this.likesCount = 0,
    this.savesCount = 0,
    this.isPublic = false,
    this.isDeleted = false,
    this.captionSuggestions = const [],
    this.highlightSuggestions = const [],
    this.selectedCaption,
    this.suggestionsGeneratedAt,
    this.suggestionsSource,
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
      voiceNoteUrl: json['voiceNoteUrl'] as String?,
      voiceNoteDurationMs: (json['voiceNoteDurationMs'] as num?)?.toInt(),
      voiceNoteMimeType: json['voiceNoteMimeType'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      locationName: json['locationName'] as String?,
      locationCity: json['locationCity'] as String?,
      locationCountry: json['locationCountry'] as String?,
      locationCountryCode: json['locationCountryCode'] as String?,
      locationAdminArea: json['locationAdminArea'] as String?,
      locationSubLocality: json['locationSubLocality'] as String?,
      locationAddress: json['locationAddress'] as String?,
      locationSource: json['locationSource'] as String?,
      photos: (json['photos'] as List<dynamic>?)?.cast<String>() ?? [],
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
      collection: json['collection'] as String?,
      entryType: json['entryType'] as String?,
      reviewRating: (json['reviewRating'] as num?)?.toDouble(),
      reviewCostTier: (json['reviewCostTier'] as num?)?.toInt(),
      reviewVibes: (json['reviewVibes'] as List<dynamic>?)?.cast<String>() ?? [],
      reviewWouldReturn: json['reviewWouldReturn'] as bool?,
      reviewHighlights:
          (json['reviewHighlights'] as List<dynamic>?)?.cast<String>() ?? [],
      reviewTips: json['reviewTips'] as String?,
      likesCount: (json['likesCount'] as num?)?.toInt() ?? legacyLikedBy,
      savesCount: (json['savesCount'] as num?)?.toInt() ?? legacySavedBy,
      isPublic: json['isPublic'] as bool? ?? false,
      isDeleted: json['isDeleted'] as bool? ?? false,
      captionSuggestions:
          (json['captionSuggestions'] as List<dynamic>?)?.cast<String>() ?? [],
      highlightSuggestions:
          (json['highlightSuggestions'] as List<dynamic>?)?.cast<String>() ?? [],
      selectedCaption: json['selectedCaption'] as String?,
      suggestionsGeneratedAt:
          (json['suggestionsGeneratedAt'] as Timestamp?)?.toDate(),
      suggestionsSource: json['suggestionsSource'] as String?,
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
      if (voiceNoteUrl != null) 'voiceNoteUrl': voiceNoteUrl,
      if (voiceNoteDurationMs != null) 'voiceNoteDurationMs': voiceNoteDurationMs,
      if (voiceNoteMimeType != null) 'voiceNoteMimeType': voiceNoteMimeType,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (locationName != null) 'locationName': locationName,
      if (locationCity != null) 'locationCity': locationCity,
      if (locationCountry != null) 'locationCountry': locationCountry,
      if (locationCountryCode != null) 'locationCountryCode': locationCountryCode,
      if (locationAdminArea != null) 'locationAdminArea': locationAdminArea,
      if (locationSubLocality != null) 'locationSubLocality': locationSubLocality,
      if (locationAddress != null) 'locationAddress': locationAddress,
      if (locationSource != null) 'locationSource': locationSource,
      'photos': photos,
      'tags': tags,
      if (collection != null) 'collection': collection,
      if (entryType != null) 'entryType': entryType,
      if (reviewRating != null) 'reviewRating': reviewRating,
      if (reviewCostTier != null) 'reviewCostTier': reviewCostTier,
      if (reviewVibes.isNotEmpty) 'reviewVibes': reviewVibes,
      if (reviewWouldReturn != null) 'reviewWouldReturn': reviewWouldReturn,
      if (reviewHighlights.isNotEmpty) 'reviewHighlights': reviewHighlights,
      if (reviewTips != null) 'reviewTips': reviewTips,
      'likesCount': likesCount,
      'savesCount': savesCount,
      'isPublic': isPublic,
      'isDeleted': isDeleted,
      if (captionSuggestions.isNotEmpty) 'captionSuggestions': captionSuggestions,
      if (highlightSuggestions.isNotEmpty)
        'highlightSuggestions': highlightSuggestions,
      if (selectedCaption != null) 'selectedCaption': selectedCaption,
      if (suggestionsGeneratedAt != null)
        'suggestionsGeneratedAt': Timestamp.fromDate(suggestionsGeneratedAt!),
      if (suggestionsSource != null) 'suggestionsSource': suggestionsSource,
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

    String? voiceNoteUrl,
    int? voiceNoteDurationMs,
    String? voiceNoteMimeType,

    double? latitude,
    double? longitude,
    String? locationName,
    String? locationCity,
    String? locationCountry,
    String? locationCountryCode,
    String? locationAdminArea,
    String? locationSubLocality,
    String? locationAddress,
    String? locationSource,
    List<String>? photos,
    List<String>? tags,
    String? collection,
    String? entryType,
    double? reviewRating,
    int? reviewCostTier,
    List<String>? reviewVibes,
    bool? reviewWouldReturn,
    List<String>? reviewHighlights,
    String? reviewTips,
    int? likesCount,
    int? savesCount,
    bool? isPublic,
    bool? isDeleted,
    List<String>? captionSuggestions,
    List<String>? highlightSuggestions,
    String? selectedCaption,
    DateTime? suggestionsGeneratedAt,
    String? suggestionsSource,
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
      voiceNoteUrl: voiceNoteUrl ?? this.voiceNoteUrl,
      voiceNoteDurationMs: voiceNoteDurationMs ?? this.voiceNoteDurationMs,
      voiceNoteMimeType: voiceNoteMimeType ?? this.voiceNoteMimeType,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      locationName: locationName ?? this.locationName,
      locationCity: locationCity ?? this.locationCity,
      locationCountry: locationCountry ?? this.locationCountry,
      locationCountryCode: locationCountryCode ?? this.locationCountryCode,
      locationAdminArea: locationAdminArea ?? this.locationAdminArea,
      locationSubLocality: locationSubLocality ?? this.locationSubLocality,
      locationAddress: locationAddress ?? this.locationAddress,
      locationSource: locationSource ?? this.locationSource,
      photos: photos ?? this.photos,
      tags: tags ?? this.tags,
      collection: collection ?? this.collection,
      entryType: entryType ?? this.entryType,
      reviewRating: reviewRating ?? this.reviewRating,
      reviewCostTier: reviewCostTier ?? this.reviewCostTier,
      reviewVibes: reviewVibes ?? this.reviewVibes,
      reviewWouldReturn: reviewWouldReturn ?? this.reviewWouldReturn,
      reviewHighlights: reviewHighlights ?? this.reviewHighlights,
      reviewTips: reviewTips ?? this.reviewTips,
      likesCount: likesCount ?? this.likesCount,
      savesCount: savesCount ?? this.savesCount,
      isPublic: isPublic ?? this.isPublic,
      isDeleted: isDeleted ?? this.isDeleted,
      captionSuggestions: captionSuggestions ?? this.captionSuggestions,
      highlightSuggestions: highlightSuggestions ?? this.highlightSuggestions,
      selectedCaption: selectedCaption ?? this.selectedCaption,
      suggestionsGeneratedAt: suggestionsGeneratedAt ?? this.suggestionsGeneratedAt,
      suggestionsSource: suggestionsSource ?? this.suggestionsSource,
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
        voiceNoteUrl,
        voiceNoteDurationMs,
        voiceNoteMimeType,
        latitude,
        longitude,
        locationName,
        locationCity,
        locationCountry,
        locationCountryCode,
        locationAdminArea,
        locationSubLocality,
        locationAddress,
        locationSource,
        photos,
        tags,
        collection,
        entryType,
        reviewRating,
        reviewCostTier,
        reviewVibes,
        reviewWouldReturn,
        reviewHighlights,
        reviewTips,
        likesCount,
        savesCount,
        isPublic,
        isDeleted,
        captionSuggestions,
        highlightSuggestions,
        selectedCaption,
        suggestionsGeneratedAt,
        suggestionsSource,
        createdAt,
        updatedAt,
        deletedAt,
      ];

  @override
  String toString() {
    return 'JournalModel(id: $id, title: $title, userId: $userId, isPublic: $isPublic)';
  }
}