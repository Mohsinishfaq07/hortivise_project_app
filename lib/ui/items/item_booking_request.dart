import 'package:flutter/material.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:horti_vige/constants.dart';
import 'package:horti_vige/data/enums/consultation_status.dart';
import 'package:horti_vige/data/models/consultation/consultation_model.dart';
import 'package:horti_vige/ui/resources/app_icons_icons.dart';
import 'package:horti_vige/ui/utils/colors/colors.dart';
import 'package:horti_vige/ui/utils/extensions/extensions.dart';
import 'package:horti_vige/ui/utils/styles/text_styles.dart';
import 'package:horti_vige/ui/widgets/app_filled_button.dart';
import 'package:horti_vige/ui/widgets/app_outlined_button.dart';
import 'package:horti_vige/ui/widgets/user_profile_avatar.dart';
import 'package:horti_vige/core/utils/app_date_utils.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class ItemBookingRequest extends StatelessWidget {
  const ItemBookingRequest({
    super.key,
    required this.requestModel,
    this.onItemClick,
    required this.onItemAction,
  });
  final Function()? onItemClick;
  final Function(ConsultationStatus status, String id) onItemAction;
  final ConsultationModel requestModel;

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    tz.initializeTimeZones();
    final localStartTime = convertToLocalTime(
      requestModel.startTime.millisecondsSinceEpoch,
      requestModel.timeZone,
    );
    debugPrint('localStartTime in consultant:$localStartTime');
    debugPrint(
        'Displaying local time from firebase in consultant: ${requestModel.startTime}');

    return Container(
      padding: 1.verticalPadding,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        color: AppColors.colorWhite,
        child: InkWell(
          onTap: onItemClick,
          child: Column(
            children: [
              ListTile(
                leading: UserProfileAvatar(
                  imageUrl: requestModel.customer.profileUrl,
                  radius: 24,
                ),
                title: Text(
                  requestModel.customer.userName,
                  style: AppTextStyles.titleStyle.changeSize(14),
                ),
                subtitle: Text(
                  requestModel.customer.email,
                  style: AppTextStyles.bodyStyle.changeSize(11),
                ),
                trailing: Text(
                  '\$${requestModel.totalAmount}',
                  style: AppTextStyles.titleStyle.changeSize(14),
                ),
              ),
              // Padding(
              //   padding: 12.horizontalPadding,
              //   child: Text(
              //     requestModel.description,
              //     style: AppTextStyles.bodyStyle,
              //     maxLines: 3,
              //     overflow: TextOverflow.ellipsis,
              //     textAlign: TextAlign.start,
              //   ),
              // ),
              6.height,
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
                        const TextSpan(
                          text: ' ',
                          style: AppTextStyles.bodyStyle,
                        ),
                        TextSpan(
                          text: AppDateUtils.getDayViseDate(
                            millis:
                                requestModel.startTime.millisecondsSinceEpoch,
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
                        const TextSpan(
                          text: ' ',
                          style: AppTextStyles.bodyStyle,
                        ),
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
                        const TextSpan(
                          text: ' ',
                          style: AppTextStyles.bodyStyle,
                        ),
                        TextSpan(
                          text: requestModel.durationTime > 0
                              ? AppDateUtils.getDurationHourMinutes(
                                  d: requestModel.durationTime,
                                )
                              : requestModel.title,
                          style: AppTextStyles.bodyStyle
                              .changeColor(AppColors.colorBlack)
                              .changeSize(12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              16.height,
              Row(
                children: [
                  Expanded(
                    child: AppOutlinedButton(
                      onPress: () {
                        onItemAction(
                          ConsultationStatus.rejected,
                          requestModel.id,
                        );
                      },
                      title: 'Decline',
                      btnColor: AppColors.appGreenMaterial,
                      height: 30,
                    ),
                  ),
                  Expanded(
                    child: AppFilledButton(
                      onPress: () {
                        onItemAction(
                          ConsultationStatus.accepted,
                          requestModel.id,
                        );
                      },
                      title: 'Accept',
                      height: 30,
                    ),
                  ),
                ],
              ),
              10.height,
            ],
          ),
        ),
      ),
    );
  }

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
