// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
      id: json['id'] as String,
      userName: json['userName'] as String,
      email: json['email'] as String,
      type: $enumDecode(_$UserTypeEnumMap, json['type']),
      profession: json['profession'] as String? ?? '',
      profileUrl: json['profileUrl'] as String,
      isAuthenticated: json['isAuthenticated'] as bool,
      uId: json['uId'] as String,
      specialist: json['specialist'] == null
          ? null
          : Specialist.fromJson(json['specialist'] as Map<String, dynamic>),
      balance: (json['balance'] as num?)?.toDouble() ?? 0,
      availability: json['availability'] == null
          ? null
          : Availability.fromJson(json['availability'] as Map<String, dynamic>),
      fcmToken: json['fcmToken'] as String?,
      consultationPricing: json['consultationPricing'] == null
          ? null
          : ConsultationPricingModel.fromJson(
              json['consultationPricing'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
      'id': instance.id,
      'userName': instance.userName,
      'email': instance.email,
      'profileUrl': instance.profileUrl,
      'type': _$UserTypeEnumMap[instance.type]!,
      'profession': instance.profession,
      'specialist': instance.specialist?.toJson(),
      'isAuthenticated': instance.isAuthenticated,
      'uId': instance.uId,
      'balance': instance.balance,
      'availability': instance.availability?.toJson(),
      'fcmToken': instance.fcmToken,
      'consultationPricing': instance.consultationPricing?.toJson(),
    };

const _$UserTypeEnumMap = {
  UserType.CUSTOMER: 'CUSTOMER',
  UserType.SPECIALIST: 'SPECIALIST',
};
