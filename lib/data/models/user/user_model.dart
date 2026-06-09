import 'package:horti_vige/data/models/consultation_pricing/consultation_pricing.dart';
import 'package:json_annotation/json_annotation.dart';

import 'package:horti_vige/data/enums/specialist_category.dart';
import 'package:horti_vige/data/enums/user_type.dart';
import 'package:horti_vige/data/models/availability/availability.dart';
import 'package:horti_vige/data/models/user/specialist.dart';

part 'user_model.g.dart';

@JsonSerializable(explicitToJson: true)
class UserModel {
  const UserModel({
    required this.id,
    required this.userName,
    required this.email,
    required this.type,
    this.profession = '',
    required this.profileUrl,
    required this.isAuthenticated,
    required this.uId,
    this.specialist,
    this.balance = 0,
    this.availability,
    this.fcmToken,
    this.consultationPricing,
  });

  // Create empty factory
  factory UserModel.empty() {
    return UserModel(
      id: '',
      userName: '',
      email: '',
      profileUrl: '',
      type: UserType.CUSTOMER,
      isAuthenticated: false,
      uId: '',
      availability: Availability.empty(),
      specialist: Specialist.empty(),
      consultationPricing: ConsultationPricingModel.empty(),
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  /// Parses user blobs stored on [ConsultationModel] documents.
  /// Full legacy profiles include `consultationPricing`; slim writes omit it.
  factory UserModel.fromConsultationEmbed(Map<String, dynamic> json) {
    if (json.containsKey('consultationPricing')) {
      return UserModel.fromJson(json);
    }
    final typeStr = json['type'] as String? ?? UserType.CUSTOMER.name;
    final type = UserType.values.firstWhere(
      (e) => e.name == typeStr,
      orElse: () => UserType.CUSTOMER,
    );
    Specialist? spec;
    final specMap = json['specialist'];
    if (specMap is Map<String, dynamic>) {
      final catName = specMap['category'] as String? ?? '';
      final statusName = specMap['status'] as String? ?? SpecialistStatus.pending.name;
      spec = Specialist(
        professionalName: specMap['professionalName'] as String? ?? '',
        email: specMap['email'] as String? ?? '',
        bio: specMap['bio'] as String? ?? '',
        category: SpecialistCategory.values.firstWhere(
          (c) => c.name == catName,
          orElse: () => SpecialistCategory.All,
        ),
        status: SpecialistStatus.values.firstWhere(
          (s) => s.name == statusName,
          orElse: () => SpecialistStatus.pending,
        ),
        statusMessage: specMap['statusMessage'] as String? ?? '',
      );
    }
    return UserModel(
      id: json['id'] as String? ?? '',
      userName: json['userName'] as String? ?? '',
      email: json['email'] as String? ?? '',
      profileUrl: json['profileUrl'] as String? ?? '',
      type: type,
      profession: json['profession'] as String? ?? '',
      isAuthenticated: json['isAuthenticated'] as bool? ?? true,
      uId: json['uId'] as String? ?? '',
      specialist: spec,
      balance: 0,
      availability: null,
      fcmToken: null,
      consultationPricing: null,
    );
  }
  final String id;
  final String userName;
  final String email;
  final String profileUrl;
  final UserType type;
  final String profession;
  final Specialist? specialist;
  final bool isAuthenticated;
  final String uId;
  final double balance;
  final Availability? availability;
  final String? fcmToken;
  final ConsultationPricingModel? consultationPricing;

  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  UserModel copyWith({
    String? id,
    String? userName,
    String? email,
    String? profileUrl,
    UserType? type,
    String? profession,
    Specialist? specialist,
    bool? isAuthenticated,
    String? uId,
    double? balance,
    Availability? availability,
    ConsultationPricingModel? consultationPricing,
  }) {
    return UserModel(
      id: id ?? this.id,
      userName: userName ?? this.userName,
      email: email ?? this.email,
      profileUrl: profileUrl ?? this.profileUrl,
      type: type ?? this.type,
      profession: profession ?? this.profession,
      specialist: specialist ?? this.specialist,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      uId: uId ?? this.uId,
      balance: balance ?? this.balance,
      availability: availability ?? this.availability,
      consultationPricing: consultationPricing ?? this.consultationPricing,
    );
  }
}
