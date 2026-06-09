// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:json_annotation/json_annotation.dart';

import 'package:horti_vige/data/models/consultation_pricing/text_pricing_model.dart';
import 'package:horti_vige/data/models/consultation_pricing/video_pricing_model.dart';

part 'consultation_pricing.g.dart';

@JsonSerializable()
class ConsultationPricingModel {
  ConsultationPricingModel({
    required this.textPackages,
    required this.videoPackages,
  });

  // create empty factory
  factory ConsultationPricingModel.empty() {
    return ConsultationPricingModel(
      textPackages: [],
      videoPackages: [],
    );
  }

  /// Default tiers consultants can edit later (stored when profile had no pricing).
  /// Tiers are **on** by default so booking/video flows work until toggled off.
  factory ConsultationPricingModel.defaultSeed() {
    return ConsultationPricingModel(
      textPackages: [
        TextPricingModel(noOfTexts: 15, price: 20, isEnabled: true),
        TextPricingModel(noOfTexts: 30, price: 37, isEnabled: true),
        TextPricingModel(noOfTexts: 50, price: 45, isEnabled: true),
      ],
      videoPackages: [
        VideoPricingModel(
          noOf: 30,
          duration: VideoDurationEnum.minute,
          price: 20,
          isEnabled: true,
        ),
        VideoPricingModel(
          noOf: 1,
          duration: VideoDurationEnum.hour,
          price: 37,
          isEnabled: true,
        ),
        VideoPricingModel(
          noOf: 2,
          duration: VideoDurationEnum.hour,
          price: 45,
          isEnabled: true,
        ),
      ],
    );
  }

  factory ConsultationPricingModel.fromJson(Map<String, dynamic> json) =>
      _$ConsultationPricingModelFromJson(json);

  Map<String, dynamic> toJson() => _$ConsultationPricingModelToJson(this);

  final List<TextPricingModel> textPackages;
  final List<VideoPricingModel> videoPackages;

  ConsultationPricingModel copyWith({
    List<TextPricingModel>? textPackages,
    List<VideoPricingModel>? videoPackages,
  }) {
    return ConsultationPricingModel(
      textPackages: textPackages ?? this.textPackages,
      videoPackages: videoPackages ?? this.videoPackages,
    );
  }

  List<VideoPricingModel> getVideoPackages() {
    return videoPackages.where((e) => e.isEnabled).toList();
  }

  List<TextPricingModel> getTextPackages() {
    return textPackages.where((e) => e.isEnabled).toList();
  }
}
