// Developed By Muhammad Waleed.. Senior Android and Flutter developer..
// waleedkalyar48@gmail.com/

import 'package:horti_vige/data/enums/specialist_category.dart';
import 'package:json_annotation/json_annotation.dart';

part 'specialist.g.dart';

/// Specialist onboarding / account state (not payment-related).
enum SpecialistStatus {
  enabled,
  incomplete,
  pending,
  restricted,
}

@JsonSerializable()
class Specialist {
  Specialist({
    required this.professionalName,
    required this.email,
    required this.bio,
    required this.category,
    this.status = SpecialistStatus.pending,
    this.statusMessage = 'N/A',
  });

  factory Specialist.empty() {
    return Specialist(
      professionalName: '',
      email: '',
      bio: '',
      category: SpecialistCategory.values.first,
    );
  }

  factory Specialist.fromJson(Map<String, dynamic> json) =>
      _$SpecialistFromJson(json);
  String professionalName;
  String email;
  String bio;
  SpecialistStatus status;
  SpecialistCategory category;
  String statusMessage;

  Map<String, dynamic> toJson() => _$SpecialistToJson(this);
}
