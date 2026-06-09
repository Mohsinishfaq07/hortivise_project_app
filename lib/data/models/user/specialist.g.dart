// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'specialist.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Specialist _$SpecialistFromJson(Map<String, dynamic> json) => Specialist(
      professionalName: json['professionalName'] as String,
      email: json['email'] as String,
      bio: json['bio'] as String,
      category: $enumDecode(_$SpecialistCategoryEnumMap, json['category']),
      status: $enumDecodeNullable(_$SpecialistStatusEnumMap, json['status']) ??
          SpecialistStatus.pending,
      statusMessage: json['statusMessage'] as String? ?? 'N/A',
    );

Map<String, dynamic> _$SpecialistToJson(Specialist instance) =>
    <String, dynamic>{
      'professionalName': instance.professionalName,
      'email': instance.email,
      'bio': instance.bio,
      'status': _$SpecialistStatusEnumMap[instance.status]!,
      'category': _$SpecialistCategoryEnumMap[instance.category]!,
      'statusMessage': instance.statusMessage,
    };

const _$SpecialistCategoryEnumMap = {
  SpecialistCategory.All: 'All',
  SpecialistCategory.Floweriest: 'Floweriest',
  SpecialistCategory.Palmist: 'Palmist',
};

const _$SpecialistStatusEnumMap = {
  SpecialistStatus.enabled: 'enabled',
  SpecialistStatus.incomplete: 'incomplete',
  SpecialistStatus.pending: 'pending',
  SpecialistStatus.restricted: 'restricted',
};
