import 'package:zuru_app/domain/entities/journal_entry.dart';
import 'place_model.dart';
import 'mood_model.dart';

class JournalEntryModel extends JournalEntry {
  const JournalEntryModel({
    required super.id,
    required super.userId,
    required super.title,
    required PlaceModel super.place,
    required super.createdAt,
    required super.privacyLevel,
    super.description,
    super.photos,
    super.videos,
    super.rating,
    super.tags,
    MoodModel? super.mood,
    super.updatedAt,
    super.reflection,
    super.metadata,
    super.companionIds,
    super.cost,
    super.weather,
    super.temperature,
  });

  factory JournalEntryModel.fromJson(Map<String, dynamic> json) {
    return JournalEntryModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      photos: (json['photos'] as List<dynamic>?)?.cast<String>() ?? [],
      videos: (json['videos'] as List<dynamic>?)?.cast<String>() ?? [],
      rating: (json['rating'] as num?)?.toDouble(),
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
      mood:
          json['mood'] != null
              ? MoodModel.fromJson(json['mood'] as Map<String, dynamic>)
              : null,
      place: PlaceModel.fromJson(json['place'] as Map<String, dynamic>),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt:
          json['updatedAt'] != null
              ? DateTime.parse(json['updatedAt'] as String)
              : null,
      privacyLevel: PrivacyLevel.values.firstWhere(
        (e) => e.name == json['privacyLevel'],
        orElse: () => PrivacyLevel.private,
      ),
      reflection: json['reflection'] as String?,
      metadata:
          (json['metadata'] as Map<String, dynamic>?)?.cast<String, dynamic>(),
      companionIds:
          (json['companionIds'] as List<dynamic>?)?.cast<String>() ?? [],
      cost: (json['cost'] as num?)?.toDouble(),
      weather: json['weather'] as String?,
      temperature: (json['temperature'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'description': description,
      'photos': photos,
      'videos': videos,
      'rating': rating,
      'tags': tags,
      'mood': mood?.toJson(),
      'place': place.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'privacyLevel': privacyLevel.name,
      'reflection': reflection,
      'metadata': metadata,
      'companionIds': companionIds,
      'cost': cost,
      'weather': weather,
      'temperature': temperature,
    };
  }

  factory JournalEntryModel.fromEntity(JournalEntry entry) {
    return JournalEntryModel(
      id: entry.id,
      userId: entry.userId,
      title: entry.title,
      description: entry.description,
      photos: entry.photos,
      videos: entry.videos,
      rating: entry.rating,
      tags: entry.tags,
      mood: entry.mood != null ? MoodModel.fromEntity(entry.mood!) : null,
      place: PlaceModel.fromEntity(entry.place),
      createdAt: entry.createdAt,
      updatedAt: entry.updatedAt,
      privacyLevel: entry.privacyLevel,
      reflection: entry.reflection,
      metadata: entry.metadata,
      companionIds: entry.companionIds,
      cost: entry.cost,
      weather: entry.weather,
      temperature: entry.temperature,
    );
  }

  JournalEntry toEntity() {
    return JournalEntry(
      id: id,
      userId: userId,
      title: title,
      description: description,
      photos: photos,
      videos: videos,
      rating: rating,
      tags: tags,
      mood: mood,
      place: place,
      createdAt: createdAt,
      updatedAt: updatedAt,
      privacyLevel: privacyLevel,
      reflection: reflection,
      metadata: metadata,
      companionIds: companionIds,
      cost: cost,
      weather: weather,
      temperature: temperature,
    );
  }
}
