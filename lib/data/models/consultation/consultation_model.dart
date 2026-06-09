import 'package:horti_vige/data/enums/consultation_status.dart';
import 'package:horti_vige/data/enums/package_type.dart';
import 'package:horti_vige/data/models/user/user_model.dart';

/// Booking record. [toJson] writes a **slim** Firestore payload (no full profile
/// trees like availability / consultationPricing on nested users).
class ConsultationModel {
  ConsultationModel({
    required this.id,
    required this.title,
    required this.description,
    required this.durationTime,
    required this.startTime,
    required this.endTime,
    required this.startDateTime,
    required this.endDateTime,
    required this.isEnabled,
    required this.specialist,
    required this.customer,
    required this.packageId,
    required this.tax,
    required this.totalAmount,
    this.status = ConsultationStatus.pending,
    required this.packageType,
    required this.timeZone,
  });

  factory ConsultationModel.fromJson(Map<String, dynamic> json) {
    final spec = json['specialist'];
    final cust = json['customer'];
    Map<String, dynamic> specMap;
    Map<String, dynamic> custMap;
    if (spec is Map<String, dynamic>) {
      specMap = spec;
    } else {
      specMap = {
        'email': json['specialistEmail'] as String? ?? '',
        'userName': '',
        'id': '',
        'uId': '',
      };
    }
    if (cust is Map<String, dynamic>) {
      custMap = cust;
    } else {
      custMap = {
        'email': json['customerEmail'] as String? ?? '',
        'userName': '',
        'id': '',
        'uId': '',
      };
    }

    return ConsultationModel(
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      durationTime: (json['durationTime'] as num?)?.toInt() ?? 0,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: DateTime.parse(json['endTime'] as String),
      startDateTime: DateTime.parse(json['startDateTime'] as String),
      endDateTime: DateTime.parse(json['endDateTime'] as String),
      isEnabled: json['isEnabled'] as bool? ?? false,
      specialist: UserModel.fromConsultationEmbed(specMap),
      customer: UserModel.fromConsultationEmbed(custMap),
      packageId: json['packageId'] as String? ?? '',
      tax: (json['tax'] as num?)?.toDouble() ?? 0,
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0,
      status: _parseStatus(json['status'] as String?),
      packageType: _parsePackageType(json['packageType'] as String?),
      timeZone: json['timeZone'] as String? ?? '',
    );
  }

  String id;
  String title;
  String description;
  int durationTime;
  DateTime startTime;
  DateTime startDateTime;
  DateTime endDateTime;
  bool isEnabled;
  DateTime endTime;
  UserModel specialist;
  UserModel customer;
  String packageId;
  double tax;
  double totalAmount;
  PackageType packageType;
  ConsultationStatus status;
  String timeZone;

  /// Slim map for Firestore: core booking fields + small user stubs + denormalized emails.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'durationTime': durationTime,
      'startTime': startTime.toIso8601String(),
      'startDateTime': startDateTime.toIso8601String(),
      'endDateTime': endDateTime.toIso8601String(),
      'isEnabled': isEnabled,
      'endTime': endTime.toIso8601String(),
      'specialist': _userEmbed(specialist),
      'customer': _userEmbed(customer),
      'specialistEmail': specialist.email,
      'customerEmail': customer.email,
      'packageId': packageId,
      'tax': tax,
      'totalAmount': totalAmount,
      'packageType': packageType.name,
      'status': status.name,
      'timeZone': timeZone,
    };
  }

  static Map<String, dynamic> _userEmbed(UserModel u) {
    return {
      'id': u.id,
      'uId': u.uId,
      'email': u.email,
      'userName': u.userName,
      'type': u.type.name,
      'profileUrl': u.profileUrl,
      'isAuthenticated': u.isAuthenticated,
      'profession': u.profession,
      if (u.specialist != null)
        'specialist': {
          'professionalName': u.specialist!.professionalName,
          'email': u.specialist!.email,
          'bio': u.specialist!.bio,
          'category': u.specialist!.category.name,
          'status': u.specialist!.status.name,
          'statusMessage': u.specialist!.statusMessage,
        },
    };
  }

  static ConsultationStatus _parseStatus(String? raw) {
    if (raw == null) return ConsultationStatus.pending;
    return ConsultationStatus.values.firstWhere(
      (e) => e.name == raw,
      orElse: () => ConsultationStatus.pending,
    );
  }

  static PackageType _parsePackageType(String? raw) {
    if (raw == null) return PackageType.video;
    return PackageType.values.firstWhere(
      (e) => e.name == raw,
      orElse: () => PackageType.video,
    );
  }
}
