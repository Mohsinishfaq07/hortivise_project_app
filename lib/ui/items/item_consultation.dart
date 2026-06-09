// import 'package:flutter/material.dart';
// import 'package:horti_vige/constants.dart';
// import 'package:horti_vige/data/models/consultation/consultation_model.dart';
// import 'package:horti_vige/ui/resources/app_icons_icons.dart';
// import 'package:horti_vige/ui/utils/colors/colors.dart';
// import 'package:horti_vige/ui/utils/extensions/extensions.dart';
// import 'package:horti_vige/ui/utils/styles/text_styles.dart';
// import 'package:horti_vige/core/utils/app_date_utils.dart';
// import 'package:horti_vige/data/enums/package_type.dart';
// import 'package:timezone/data/latest.dart' as tz;
// import 'package:timezone/timezone.dart' as tz;

// class ItemConsultation extends StatelessWidget {
//   const ItemConsultation({
//     super.key,
//     required this.isCustomer,
//     required this.consultation,
//     this.onItemClick,
//   });
//   final Function(ConsultationModel model)? onItemClick;
//   final ConsultationModel consultation;
//   final bool isCustomer;

//   @override
//   Widget build(BuildContext context) {
//     debugPrint('patient time zone in firebase:${consultation.timeZone}');
//     DateTime now = DateTime.now();
//     return Container(
//       padding: 1.verticalPadding,
//       child: InkWell(
//         onTap: () => onItemClick!(consultation),
//         child: Card(
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//           color: AppColors.colorWhite,
//           child: Column(
//             children: [
//               ListTile(
//                 leading: CircleAvatar(
//                   backgroundImage: NetworkImage(
//                     isCustomer
//                         ? consultation.specialist.profileUrl
//                         : consultation.customer.profileUrl,
//                   ),
//                   radius: 24,
//                 ),
//                 title: Text(
//                   isCustomer
//                       ? consultation.specialist.userName
//                       : consultation.customer.userName,
//                   style: AppTextStyles.titleStyle.changeSize(14),
//                 ),
//                 subtitle: Text(
//                   isCustomer
//                       ? consultation.specialist.specialist?.category.name ??
//                           'N/A'
//                       : 'Customer',
//                   style: AppTextStyles.bodyStyle.changeSize(11),
//                 ),
//                 trailing: Text(
//                   '\$${consultation.totalAmount.toStringAsFixed(2)}',
//                   style: AppTextStyles.titleStyle.changeSize(14),
//                 ),
//               ),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                 children: [
//                   RichText(
//                     text: TextSpan(
//                       children: [
//                         const WidgetSpan(
//                           alignment: PlaceholderAlignment.middle,
//                           child: Icon(
//                             Icons.calendar_today_rounded,
//                             size: 18,
//                             color: AppColors.colorGreen,
//                           ),
//                         ),
//                         const TextSpan(
//                           text: ' ',
//                           style: AppTextStyles.bodyStyle,
//                         ),
//                         TextSpan(
//                           text: AppDateUtils.getDayViseDate(
//                             millis:
//                                 consultation.startTime.millisecondsSinceEpoch,
//                           ),
//                           style: AppTextStyles.bodyStyle
//                               .changeColor(AppColors.colorBlack)
//                               .changeSize(12),
//                         ),
//                       ],
//                     ),
//                   ),
//                   RichText(
//                     text: TextSpan(
//                       children: [
//                         const WidgetSpan(
//                           alignment: PlaceholderAlignment.middle,
//                           child: Icon(
//                             AppIcons.ic_clock_time,
//                             size: 18,
//                             color: AppColors.colorGreen,
//                           ),
//                         ),
//                         const TextSpan(
//                           text: ' ',
//                           style: AppTextStyles.bodyStyle,
//                         ),
//                         TextSpan(
//                           text: AppDateUtils.getTime12HoursFromMillis(
//                             millies:
//                                 consultation.startTime.millisecondsSinceEpoch,
//                           ),
//                           style: AppTextStyles.bodyStyle
//                               .changeColor(AppColors.colorBlack)
//                               .changeSize(12),
//                         ),
//                       ],
//                     ),
//                   ),
//                   RichText(
//                     text: TextSpan(
//                       children: [
//                         const WidgetSpan(
//                           alignment: PlaceholderAlignment.middle,
//                           child: Icon(
//                             AppIcons.ic_hourglass_time,
//                             size: 18,
//                             color: AppColors.colorGreen,
//                           ),
//                         ),
//                         const TextSpan(
//                           text: ' ',
//                           style: AppTextStyles.bodyStyle,
//                         ),
//                         TextSpan(
//                           text: consultation.durationTime > 0
//                               ? AppDateUtils.getDurationHourMinutes(
//                                   d: consultation.durationTime,
//                                 )
//                               : consultation.title,
//                           style: AppTextStyles.bodyStyle
//                               .changeColor(AppColors.colorBlack)
//                               .changeSize(12),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//               8.height,
//               consultation.packageType == PackageType.text &&
//                       (now.isAfter(consultation.startTime) &&
//                           !now.isBefore(
//                               consultation.startTime.add(Duration(hours: 1))))
//                   ? Align(
//                       alignment: Alignment.topLeft,
//                       child: Padding(
//                         padding: const EdgeInsets.only(left: 10.0),
//                         child: Text(
//                           'Expired',
//                           style: AppTextStyles.bodyStyle
//                               .changeSize(15)
//                               .changeColor(AppColors.colorOrange),
//                         ),
//                       ),
//                     )
//                   : consultation.packageType == PackageType.video &&
//                           (now.isAfter(consultation.startTime) &&
//                               !now.isBefore(consultation.endTime))
//                       ? Align(
//                           alignment: Alignment.topLeft,
//                           child: Padding(
//                             padding: const EdgeInsets.only(left: 10.0),
//                             child: Text(
//                               'Expired',
//                               style: AppTextStyles.bodyStyle
//                                   .changeSize(15)
//                                   .changeColor(AppColors.colorOrange),
//                             ),
//                           ),
//                         )
//                       : const SizedBox.shrink(),
//               8.height,
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   String getTimeZoneIdFromName(String humanReadableName) {
//     return timeZoneMapping.entries
//         .firstWhere((entry) => entry.value == humanReadableName,
//             orElse: () => const MapEntry('UTC', 'UTC'))
//         .key;
//   }

//   DateTime convertToLocalTime(
//       int millisSinceEpoch, String firebaseTimeZoneName) {
//     tz.initializeTimeZones();

//     // Get the time zone ID from the human-readable name
//     String timeZoneId = getTimeZoneIdFromName(firebaseTimeZoneName);

//     // Get the locations for the Firebase time zone and local time zone
//     final firebaseTimeZone = tz.getLocation(timeZoneId);
//     final localTimeZone = tz.local; // Local device time zone

//     // Convert start time to Firebase time zone
//     final consultationTime = tz.TZDateTime.fromMillisecondsSinceEpoch(
//       firebaseTimeZone,
//       millisSinceEpoch,
//     );

//     // Convert to local time zone
//     final localTime = tz.TZDateTime.from(consultationTime, localTimeZone);

//     return localTime;
//   }
// }

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:horti_vige/constants.dart';
import 'package:horti_vige/data/enums/consultation_status.dart';
import 'package:horti_vige/data/models/consultation/consultation_model.dart';
import 'package:horti_vige/ui/resources/app_icons_icons.dart';
import 'package:horti_vige/ui/utils/colors/colors.dart';
import 'package:horti_vige/ui/utils/extensions/extensions.dart';
import 'package:horti_vige/ui/utils/styles/text_styles.dart';
import 'package:horti_vige/ui/widgets/user_profile_avatar.dart';
import 'package:horti_vige/core/utils/app_date_utils.dart';
import 'package:horti_vige/data/enums/package_type.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class ItemConsultation extends StatelessWidget {
  const ItemConsultation({
    super.key,
    required this.isCustomer,
    required this.consultation,
    this.onItemClick,
  });

  final Function(ConsultationModel model)? onItemClick;
  final ConsultationModel consultation;
  final bool isCustomer;

  @override
  Widget build(BuildContext context) {
    tz.initializeTimeZones(); // Initialize timezone database
    debugPrint('Patient time zone in Firebase: ${consultation.timeZone}');

    // Convert the consultation startTime to local time
    final localStartTime = convertToLocalTime(
      consultation.startTime.millisecondsSinceEpoch,
      consultation.timeZone,
    );
    debugPrint('localStartTime:$localStartTime');
    debugPrint(
        'Displaying local time from firebase: ${consultation.startTime}');

    DateTime now = DateTime.now();

    return Container(
      padding: 1.verticalPadding,
      child: InkWell(
        onTap: () => onItemClick!(consultation),
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          color: AppColors.colorWhite,
          child: Column(
            children: [
              ListTile(
                leading: UserProfileAvatar(
                  imageUrl: isCustomer
                      ? consultation.specialist.profileUrl
                      : consultation.customer.profileUrl,
                  radius: 24,
                ),
                title: Text(
                  isCustomer
                      ? consultation.specialist.userName
                      : consultation.customer.userName,
                  style: AppTextStyles.titleStyle.changeSize(14),
                ),
                subtitle: Text(
                  isCustomer
                      ? consultation.specialist.specialist?.category.name ??
                          'N/A'
                      : 'Customer',
                  style: AppTextStyles.bodyStyle.changeSize(11),
                ),
                trailing: Text(
                  '\$${consultation.totalAmount.toStringAsFixed(2)}',
                  style: AppTextStyles.titleStyle.changeSize(14),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        const WidgetSpan(
                          alignment: PlaceholderAlignment.middle,
                          child: Icon(
                            Icons.calendar_today_rounded,
                            size: 18,
                            color: AppColors.colorGreen,
                          ),
                        ),
                        const TextSpan(text: ' '),
                        TextSpan(
                          text: AppDateUtils.getDayViseDate(
                            millis: localStartTime.millisecondsSinceEpoch,
                          ),
                          style: AppTextStyles.bodyStyle
                              .changeColor(AppColors.colorBlack)
                              .changeSize(12),
                        ),
                      ],
                    ),
                  ),
                  RichText(
                    text: TextSpan(
                      children: [
                        const WidgetSpan(
                          alignment: PlaceholderAlignment.middle,
                          child: Icon(
                            AppIcons.ic_clock_time,
                            size: 18,
                            color: AppColors.colorGreen,
                          ),
                        ),
                        const TextSpan(text: ' '),
                        TextSpan(
                          text: AppDateUtils.getTime12HoursFromMillis(
                            millies: localStartTime.millisecondsSinceEpoch,
                          ),
                          style: AppTextStyles.bodyStyle
                              .changeColor(AppColors.colorBlack)
                              .changeSize(12),
                        ),
                      ],
                    ),
                  ),
                  RichText(
                    text: TextSpan(
                      children: [
                        const WidgetSpan(
                          alignment: PlaceholderAlignment.middle,
                          child: Icon(
                            AppIcons.ic_hourglass_time,
                            size: 18,
                            color: AppColors.colorGreen,
                          ),
                        ),
                        const TextSpan(text: ' '),
                        TextSpan(
                          text: consultation.durationTime > 0
                              ? AppDateUtils.getDurationHourMinutes(
                                  d: consultation.durationTime,
                                )
                              : consultation.title,
                          style: AppTextStyles.bodyStyle
                              .changeColor(AppColors.colorBlack)
                              .changeSize(12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              8.height,
              consultation.packageType == PackageType.text &&
                      (now.isAfter(localStartTime) &&
                          !now.isBefore(localStartTime.add(Duration(hours: 1))))
                  ? _expiredText()
                  : consultation.packageType == PackageType.video &&
                          (now.isAfter(localStartTime) &&
                              !now.isBefore(consultation.endTime))
                      ? _expiredText()
                      : const SizedBox.shrink(),
              4.height,
              (now.isAfter(localStartTime) &&
                          !now.isBefore(
                            localStartTime.add(
                              const Duration(hours: 1),
                            ),
                          )) ||
                      consultation.status == ConsultationStatus.canceled
                  ? _deleteButton(docId: consultation.id, context: context)
                  : const SizedBox.shrink(),
            ],
          ),
        ),
      ),
    );
  }

  // Widget for displaying "Expired"
  Widget _expiredText() {
    return Align(
      alignment: Alignment.topLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 10.0),
        child: Text(
          'Expired',
          style: AppTextStyles.bodyStyle
              .changeSize(15)
              .changeColor(AppColors.colorOrange),
        ),
      ),
    );
  }

  Widget _deleteButton({required String docId, required BuildContext context}) {
    return GestureDetector(
      onTap: () async {
        try {
          await FirebaseFirestore.instance
              .collection('Consultations')
              .doc(docId)
              .delete();
        } catch (e) {
          debugPrint('error in deleting consultation :${e.toString()}');
        }
      },
      child: Container(
        margin: const EdgeInsets.all(10),
        height: 30,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.colorRed,
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }

  // Function to get time zone ID from human-readable name
  String getTimeZoneIdFromName(String humanReadableName) {
    return timeZoneMapping.entries
        .firstWhere(
          (entry) => entry.value == humanReadableName,
          orElse: () => const MapEntry('UTC', 'UTC'),
        )
        .key;
  }

  Future<String> localTimeGet() async {
    String localTimeZone =
        (await FlutterTimezone.getLocalTimezone()).identifier;
    return localTimeZone;
  }

  // Function to convert time to local time
  DateTime convertToLocalTime(
      int millisSinceEpoch, String firebaseTimeZoneName) {
    // Get the time zone ID from the human-readable name
    String timeZoneId = getTimeZoneIdFromName(firebaseTimeZoneName);

    String checkingZoneId = getTimeZoneIdFromName(
        sf.getString('localTimeZone') ?? 'Pakistan Standard Time (GMT +5:00)');

    // Get the locations for the Firebase time zone and local time zone
    final firebaseTimeZone = tz.getLocation(timeZoneId);

    final localTimeZone = tz.getLocation(checkingZoneId);
    ////final Sha
    // String localTimeId =;
    // print('Local time zone id: $localTimeId');
    //  String? matchedTimeZone = timeZoneMapping[localTimeId];
    //final localTimeZoneId = getTimeZoneIdFromName(matchedTimeZone!);
    //debugPrint('matchedTimeZone:$localTimeZoneId');
    //  final localTimeZone = tz.getLocation(localTimeZoneId);
    debugPrint('localTimeZone:$localTimeZone');
    // // Convert start time to Firebase time zone
    final consultationTime = tz.TZDateTime.fromMillisecondsSinceEpoch(
      firebaseTimeZone,
      millisSinceEpoch,
    );

    // // Convert to local time zone
    final localTime = tz.TZDateTime.from(consultationTime, localTimeZone);
    debugPrint('localTime:$localTime');
    return localTime;
  }
}
