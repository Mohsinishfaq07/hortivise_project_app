// Developed By Muhammad Waleed.. Senior Android and Flutter developer..
// waleedkalyar48@gmail.com/

import 'package:horti_vige/data/enums/specialist_category.dart';
import 'package:json_annotation/json_annotation.dart';

import 'package:horti_vige/data/services/stripe.dart';

part 'specialist.g.dart';

@JsonSerializable()
class Specialist {
  Specialist({
    required this.professionalName,
    required this.email,
    required this.bio,
    required this.category,
    required this.stripeId,
    required this.isStripeActive,
    this.status = StripeStatus.pending,
    this.statusMessage = 'N/A',
  });

  // Create empty factory
  factory Specialist.empty() {
    return Specialist(
      professionalName: '',
      email: '',
      bio: '',
      isStripeActive: false,
      stripeId: '',
      category: SpecialistCategory.values.first,
    );
  }

  factory Specialist.fromJson(Map<String, dynamic> json) =>
      _$SpecialistFromJson(json);
  String professionalName;
  String email;
  String stripeId;
  String bio;
  bool isStripeActive;
  StripeStatus status;
  SpecialistCategory category;
  String statusMessage;

  Map<String, dynamic> toJson() => _$SpecialistToJson(this);
}
