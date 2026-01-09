import 'package:json_annotation/json_annotation.dart';
import 'package:zuru_app/domain/entities/mood.dart';

part 'mood_model.g.dart';

@JsonSerializable()
class MoodModel extends Mood {
  const MoodModel({
    required super.id,
    required super.userId,
    required super.type,
    required super.intensity,
    required super.timestamp,
    super.note,
    super.locationId,
    super.tags,
  });

  factory MoodModel.fromJson(Map<String, dynamic> json) =>
      _$MoodModelFromJson(json);

  Map<String, dynamic> toJson() => _$MoodModelToJson(this);

  factory MoodModel.fromEntity(Mood mood) {
    return MoodModel(
      id: mood.id,
      userId: mood.userId,
      type: mood.type,
      intensity: mood.intensity,
      timestamp: mood.timestamp,
      note: mood.note,
      locationId: mood.locationId,
      tags: mood.tags,
    );
  }

  Mood toEntity() {
    return Mood(
      id: id,
      userId: userId,
      type: type,
      intensity: intensity,
      timestamp: timestamp,
      note: note,
      locationId: locationId,
      tags: tags,
    );
  }
}