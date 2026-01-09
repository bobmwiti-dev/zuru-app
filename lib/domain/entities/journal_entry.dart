import 'package:equatable/equatable.dart';
import 'package:zuru_app/domain/entities/place.dart';
import 'package:zuru_app/domain/entities/mood.dart';

enum PrivacyLevel {
  private,    // Only visible to user
  friends,    // Visible to friends
  public,     // Visible to everyone
}

class JournalEntry extends Equatable {
  final String id;
  final String userId;
  final String title;
  final String? description;
  final List<String> photos; // URLs or file paths
  final List<String> videos; // URLs or file paths
  final double? rating; // 1-5 stars
  final List<String> tags;
  final Mood? mood;
  final Place place;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final PrivacyLevel privacyLevel;
  final String? reflection; // Personal reflection/thoughts
  final Map<String, dynamic>? metadata; // Additional flexible data
  final List<String> companionIds; // IDs of people who were there
  final double? cost; // Entry cost or total spent
  final String? weather; // Weather conditions
  final double? temperature; // Temperature in Celsius

  const JournalEntry({
    required this.id,
    required this.userId,
    required this.title,
    required this.place,
    required this.createdAt,
    required this.privacyLevel,
    this.description,
    this.photos = const [],
    this.videos = const [],
    this.rating,
    this.tags = const [],
    this.mood,
    this.updatedAt,
    this.reflection,
    this.metadata,
    this.companionIds = const [],
    this.cost,
    this.weather,
    this.temperature,
  });

  @override
  List<Object?> get props => [
    id,
    userId,
    title,
    description,
    photos,
    videos,
    rating,
    tags,
    mood,
    place,
    createdAt,
    updatedAt,
    privacyLevel,
    reflection,
    metadata,
    companionIds,
    cost,
    weather,
    temperature,
  ];

  JournalEntry copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    List<String>? photos,
    List<String>? videos,
    double? rating,
    List<String>? tags,
    Mood? mood,
    Place? place,
    DateTime? createdAt,
    DateTime? updatedAt,
    PrivacyLevel? privacyLevel,
    String? reflection,
    Map<String, dynamic>? metadata,
    List<String>? companionIds,
    double? cost,
    String? weather,
    double? temperature,
  }) {
    return JournalEntry(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      photos: photos ?? this.photos,
      videos: videos ?? this.videos,
      rating: rating ?? this.rating,
      tags: tags ?? this.tags,
      mood: mood ?? this.mood,
      place: place ?? this.place,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      privacyLevel: privacyLevel ?? this.privacyLevel,
      reflection: reflection ?? this.reflection,
      metadata: metadata ?? this.metadata,
      companionIds: companionIds ?? this.companionIds,
      cost: cost ?? this.cost,
      weather: weather ?? this.weather,
      temperature: temperature ?? this.temperature,
    );
  }
}