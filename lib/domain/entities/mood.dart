import 'package:equatable/equatable.dart';

enum MoodType {
  ecstatic,    // 5/5
  happy,       // 4/5
  content,     // 3/5
  neutral,     // 2/5
  sad,         // 1/5
  anxious,     // Custom mood
  excited,     // Custom mood
  peaceful,    // Custom mood
  frustrated,  // Custom mood
  grateful,    // Custom mood
}

class Mood extends Equatable {
  final String id;
  final String userId;
  final MoodType type;
  final int intensity; // 1-5 scale
  final String? note; // Optional note about the mood
  final DateTime timestamp;
  final String? locationId; // Associated place/location
  final List<String> tags; // Mood tags/context

  const Mood({
    required this.id,
    required this.userId,
    required this.type,
    required this.intensity,
    required this.timestamp,
    this.note,
    this.locationId,
    this.tags = const [],
  });

  @override
  List<Object?> get props => [
    id,
    userId,
    type,
    intensity,
    note,
    timestamp,
    locationId,
    tags,
  ];

  Mood copyWith({
    String? id,
    String? userId,
    MoodType? type,
    int? intensity,
    String? note,
    DateTime? timestamp,
    String? locationId,
    List<String>? tags,
  }) {
    return Mood(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      intensity: intensity ?? this.intensity,
      timestamp: timestamp ?? this.timestamp,
      note: note ?? this.note,
      locationId: locationId ?? this.locationId,
      tags: tags ?? this.tags,
    );
  }

  /// Convert Mood to JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'type': type.name, // Convert enum to string
      'intensity': intensity,
      'note': note,
      'timestamp': timestamp.toIso8601String(),
      'locationId': locationId,
      'tags': tags,
      'emoji': emoji,
      'displayName': displayName,
      'colorHex': colorHex,
    };
  }

  // Helper method to get emoji representation
  String get emoji {
    switch (type) {
      case MoodType.ecstatic:
        return '🤩';
      case MoodType.happy:
        return '😊';
      case MoodType.content:
        return '🙂';
      case MoodType.neutral:
        return '😐';
      case MoodType.sad:
        return '😢';
      case MoodType.anxious:
        return '😰';
      case MoodType.excited:
        return '🤗';
      case MoodType.peaceful:
        return '😌';
      case MoodType.frustrated:
        return '😤';
      case MoodType.grateful:
        return '🙏';
    }
  }

  // Helper method to get display name
  String get displayName {
    switch (type) {
      case MoodType.ecstatic:
        return 'Ecstatic';
      case MoodType.happy:
        return 'Happy';
      case MoodType.content:
        return 'Content';
      case MoodType.neutral:
        return 'Neutral';
      case MoodType.sad:
        return 'Sad';
      case MoodType.anxious:
        return 'Anxious';
      case MoodType.excited:
        return 'Excited';
      case MoodType.peaceful:
        return 'Peaceful';
      case MoodType.frustrated:
        return 'Frustrated';
      case MoodType.grateful:
        return 'Grateful';
    }
  }

  // Helper method to get color representation (hex codes)
  String get colorHex {
    switch (type) {
      case MoodType.ecstatic:
        return '#FFD700'; // Gold
      case MoodType.happy:
        return '#FFFF00'; // Yellow
      case MoodType.content:
        return '#90EE90'; // Light green
      case MoodType.neutral:
        return '#D3D3D3'; // Light gray
      case MoodType.sad:
        return '#87CEEB'; // Sky blue
      case MoodType.anxious:
        return '#FFA500'; // Orange
      case MoodType.excited:
        return '#FF69B4'; // Hot pink
      case MoodType.peaceful:
        return '#98FB98'; // Pale green
      case MoodType.frustrated:
        return '#FF6347'; // Tomato red
      case MoodType.grateful:
        return '#DDA0DD'; // Plum
    }
  }
}