// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mood_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MoodModel _$MoodModelFromJson(Map<String, dynamic> json) => MoodModel(
  id: json['id'] as String,
  userId: json['userId'] as String,
  type: $enumDecode(_$MoodTypeEnumMap, json['type']),
  intensity: (json['intensity'] as num).toInt(),
  timestamp: DateTime.parse(json['timestamp'] as String),
  note: json['note'] as String?,
  locationId: json['locationId'] as String?,
  tags:
      (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
);

Map<String, dynamic> _$MoodModelToJson(MoodModel instance) => <String, dynamic>{
  'id': instance.id,
  'userId': instance.userId,
  'type': _$MoodTypeEnumMap[instance.type]!,
  'intensity': instance.intensity,
  'note': instance.note,
  'timestamp': instance.timestamp.toIso8601String(),
  'locationId': instance.locationId,
  'tags': instance.tags,
};

const _$MoodTypeEnumMap = {
  MoodType.ecstatic: 'ecstatic',
  MoodType.happy: 'happy',
  MoodType.content: 'content',
  MoodType.neutral: 'neutral',
  MoodType.sad: 'sad',
  MoodType.anxious: 'anxious',
  MoodType.excited: 'excited',
  MoodType.peaceful: 'peaceful',
  MoodType.frustrated: 'frustrated',
  MoodType.grateful: 'grateful',
};
