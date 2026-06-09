// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:horti_vige/core/utils/app_consts.dart';
import 'package:horti_vige/core/utils/app_date_utils.dart';
import 'package:horti_vige/data/enums/consultation_status.dart';
import 'package:horti_vige/data/enums/package_type.dart';
import 'package:horti_vige/data/models/consultation/consultation_model.dart';
import 'package:horti_vige/providers/consultations_provider.dart';
import 'package:horti_vige/ui/dialogs/cancelation_feedback_bottom_dialog.dart';
import 'package:horti_vige/ui/dialogs/confirmation_bottom_dialog.dart';
import 'package:horti_vige/ui/dialogs/update_consultation_bottom_dialog.dart';
import 'package:horti_vige/ui/resources/app_icons_icons.dart';
import 'package:horti_vige/ui/resources/strings.dart';
import 'package:horti_vige/ui/screens/common/conversation_screen.dart';
import 'package:horti_vige/ui/screens/video_call/video_call_screen.dart';
import 'package:horti_vige/ui/utils/colors/colors.dart';
import 'package:horti_vige/ui/utils/extensions/extensions.dart';
import 'package:horti_vige/ui/utils/styles/text_styles.dart';
import 'package:horti_vige/ui/widgets/app_filled_button.dart';
import 'package:horti_vige/ui/widgets/app_outlined_button.dart';
import 'package:horti_vige/ui/widgets/user_profile_avatar.dart';
import 'package:provider/provider.dart';
import 'dart:developer' as d;

class ConsultationDetailsScreen extends StatefulWidget {
  const ConsultationDetailsScreen({
    super.key,
  });
  static const String routeName = 'consultationDetails';

  @override
  State<ConsultationDetailsScreen> createState() =>
      _ConsultationDetailsScreenState();
}

class _ConsultationDetailsScreenState extends State<ConsultationDetailsScreen> {
  late ConsultationModel consultation;
  late bool fromUserConsultationPage;
  Timer? timer;

  Timer? statusTimer;
  String status = '';

  bool loading = true;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      final arguments = (ModalRoute.of(context)?.settings.arguments ??
          <String, dynamic>{}) as Map;
      consultation = arguments[Constants.consultModel] as ConsultationModel;
      fromUserConsultationPage =
          arguments[Constants.fromUserConsultationPage] as bool;
      loading = false;
      startTimer();
      setState(() {});

      d.log(
        'consultation data customer${consultation.customer}, description ${consultation.description} , duration time  ${consultation.durationTime}, end date time${consultation.endDateTime} , end time ${consultation.endTime} , id  ${consultation.id}, start time${consultation.startTime}, start date time${consultation.startDateTime} , package type ${consultation.packageType},}',
      );
      consultation.packageType == PackageType.text
          ? startMonitoringTextTier(consultation)
          : startMonitoring(consultation);
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    statusTimer?.cancel();
    super.dispose();
  }

  Widget _profileHeaderImage(String profileUrl) {
    if (!UserProfileImage.hasRemote(profileUrl)) {
      return Container(
        height: 300,
        width: double.infinity,
        color: AppColors.colorGrayBg,
        child: const Icon(Icons.person, size: 120, color: Colors.grey),
      );
    }
    return Image.network(
      profileUrl,
      height: 300,
      fit: BoxFit.contain,
    );
  }

  // abdul rehnman  function to get status
  void startMonitoring(ConsultationModel consultation) {
    statusTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      DateTime now = DateTime.now();

      if (now.isBefore(consultation.startTime)) {
        // Status before the appointment starts
        setState(() {
          status = 'soon';
        });
      } else if (now.isAfter(consultation.startTime) &&
          now.isBefore(consultation.endTime)) {
        // Status when the appointment is ongoing
        setState(() {
          status = 'started';
        });
      } else {
        // Status when the appointment has expired
        setState(() {
          status = 'expired';
        });
        timer.cancel(); // Stop the timer when expired
      }

      d.log('status: $status'); // Optional: Log status for verification
    });
  }

  void startMonitoringTextTier(ConsultationModel consultation) {
    statusTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      DateTime now = DateTime.now();

      if (now.isBefore(consultation.startTime)) {
        setState(() {
          status = 'soon';
        });
      } else if (now.isAfter(consultation.startTime) &&
          now.isBefore(consultation.startTime.add(Duration(hours: 1)))) {
        setState(() {
          status = 'started';
        });
      } else {
        setState(() {
          status = 'expired';
        });
        timer.cancel();
      }

      d.log('status: $status');
    });
  }

  Future<void> startTimer() async {
    if (AppDateUtils.getTimeGapByMilliseconds(
          milliseconds: consultation.startTime.millisecondsSinceEpoch,
        ) ==
        'Starting Soon') {
      consultation.startTime.difference(DateTime.now()).inMinutes.log();

      if (consultation.startTime.difference(DateTime.now()).inMinutes < 15) {
        timer = Timer.periodic(const Duration(seconds: 1), (timer) {
          if (consultation.startTime.difference(DateTime.now()).inSeconds ==
              0) {
            consultation.isEnabled = true;
            timer.cancel();
            setState(() {});
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isCustomer =
        Provider.of<ConsultationProvider>(context, listen: false).isCustomer();

    return Scaffold(
      body: SingleChildScrollView(
        child: SizedBox(
          width: context.width,
          height: context.safeHeight,
          child: loading
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : Stack(
                  children: [
                    Positioned(
                      left: 0,
                      right: 0,
                      top: 0,
                      child: _profileHeaderImage(
                        isCustomer
                            ? consultation.specialist.profileUrl
                            : consultation.customer.profileUrl,
                      ),
                    ),
                    Positioned(
                      left: 8,
                      top: MediaQuery.of(context).viewInsets.top + 20,
                      child: RawMaterialButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        elevation: 1,
                        constraints: const BoxConstraints(
                          minWidth: 26,
                          minHeight: 26,
                          maxWidth: 26,
                          maxHeight: 26,
                        ),
                        fillColor: AppColors.colorWhite.withAlpha(100),
                        shape: const CircleBorder(),
                        child: const Icon(
                          Icons.arrow_back_ios_new,
                          size: 16,
                        ),
                      ),
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      top: 270,
                      bottom: 0,
                      child: Container(
                        padding: 16.allPadding,
                        decoration: const BoxDecoration(
                          color: AppColors.colorWhite,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(12),
                            topRight: Radius.circular(12),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            8.height,
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      isCustomer
                                          ? consultation.specialist.userName
                                          : consultation.customer.userName,
                                      style: AppTextStyles.bodyStyleMedium
                                          .changeSize(16),
                                    ),
                                    4.height,
                                    Text(
                                      isCustomer
                                          ? 'Professional ${consultation.specialist.specialist?.category.name}'
                                          : 'Customer',
                                      style: AppTextStyles.bodyStyle
                                          .changeSize(12),
                                    ),
                                  ],
                                ),
                                if (consultation.status !=
                                    ConsultationStatus.canceled)
                                  Text(
                                    status == 'soon'
                                        ? 'Starting Soon'
                                        : status == 'started'
                                            ? 'Appointment Started'
                                            : status == 'expired'
                                                ? 'Expired'
                                                : '',
                                    style: AppTextStyles.bodyStyle
                                        .changeSize(12)
                                        .changeColor(AppColors.colorOrange),
                                  )
                                else
                                  Text(
                                    'Canceled',
                                    style: AppTextStyles.bodyStyle
                                        .changeSize(12)
                                        .changeColor(AppColors.colorRed),
                                  ),
                              ],
                            ),
                            15.height,
                            Text(
                              'Description',
                              style:
                                  AppTextStyles.bodyStyleMedium.changeSize(14),
                            ),
                            8.height,
                            Text(
                              consultation.description,
                              style: AppTextStyles.bodyStyle
                                  .changeSize(11)
                                  .changeFontWeight(FontWeight.w300),
                            ),
                            15.height,
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Schedule',
                                      style: AppTextStyles.bodyStyle,
                                    ),
                                    Text(
                                      AppDateUtils.getDayViseDate(
                                        millis: consultation
                                            .startTime.millisecondsSinceEpoch,
                                      ),
                                      style: AppTextStyles.titleStyle
                                          .changeSize(16),
                                    ),
                                  ],
                                ),
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Start Time',
                                      style: AppTextStyles.bodyStyle,
                                    ),
                                    Text(
                                      AppDateUtils.getTime12HoursFromMillis(
                                        millies: consultation
                                            .startTime.millisecondsSinceEpoch,
                                      ),
                                      style: AppTextStyles.titleStyle
                                          .changeSize(16),
                                    ),
                                  ],
                                ),
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Duration',
                                      style: AppTextStyles.bodyStyle,
                                    ),
                                    Text(
                                      consultation.durationTime > 0
                                          ? AppDateUtils.getDurationHourMinutes(
                                              d: consultation.durationTime,
                                            )
                                          : consultation.title,
                                      style: AppTextStyles.titleStyle
                                          .changeSize(16),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            12.height,
                            Text(
                              'Notes',
                              style:
                                  AppTextStyles.bodyStyleMedium.changeSize(16),
                            ),
                            Container(
                              width: double.infinity,
                              padding: 8.allPadding,
                              margin: const EdgeInsets.only(top: 12),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: AppColors.colorBeige,
                              ),
                              child: const Text(
                                Strings.loremIpsum,
                                style: AppTextStyles.bodyStyle,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 3,
                                textAlign: TextAlign.left,
                              ),
                            ),
                            12.height,
                            // dummy call joining button
                            // ElevatedButton(
                            //   onPressed: () {
                            //     debugPrint(
                            //       'log: user type:${isCustomer ? 'Customer' : 'Doctor'}',
                            //     );
                            //     debugPrint(
                            //         'call start time :${consultation.startTime.millisecondsSinceEpoch}');
                            //     _onStartConsultation(
                            //       context,
                            //       isCustomer,
                            //       consultation,
                            //     );
                            //   },
                            //   child: consultation.packageType ==
                            //               PackageType.text &&
                            //           consultation.packageType ==
                            //               PackageType.video &&
                            //           status == 'expired'
                            //       ? Text('Expired')
                            //       : Text('See conversation'),
                            // ),
                            consultation.status != ConsultationStatus.canceled
                                ? Expanded(
                                    child: Stack(
                                      children: [
                                        Positioned(
                                          bottom: 0,
                                          left: 0,
                                          right: 0,
                                          child: Column(
                                            children: [
                                              AppFilledButton(
                                                onPress: () {
                                                  debugPrint(
                                                      'log: user type:${isCustomer ? 'Customer' : 'Doctor'}');
                                                  _onStartConsultation(
                                                    context,
                                                    isCustomer,
                                                    consultation,
                                                  );
                                                },
                                                title: status.isEmpty
                                                    ? ''
                                                    : (consultation.packageType ==
                                                                    PackageType
                                                                        .text &&
                                                                status ==
                                                                    'expired') ||
                                                            (consultation
                                                                        .packageType ==
                                                                    PackageType
                                                                        .video &&
                                                                status ==
                                                                    'expired')
                                                        ? 'See conversation'
                                                        : 'Start Consultation',
                                                isEnabled: status.isEmpty
                                                    ? false
                                                    : (consultation.packageType ==
                                                                PackageType
                                                                    .text &&
                                                            status ==
                                                                'started') ||
                                                        (consultation
                                                                    .packageType ==
                                                                PackageType
                                                                    .video &&
                                                            status ==
                                                                'started'),
                                              ),
                                              20.height,
                                              consultation.startTime
                                                          .millisecondsSinceEpoch >
                                                      DateTime.now()
                                                          .millisecondsSinceEpoch
                                                  ? Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Expanded(
                                                          child: isCustomer
                                                              ? AppFilledButton(
                                                                  onPress: () {
                                                                    _onCancel(
                                                                      context,
                                                                      fromUserConsultationPage,
                                                                      consultation,
                                                                    );
                                                                  },
                                                                  title:
                                                                      'Cancel',
                                                                  color: AppColors
                                                                      .colorRed,
                                                                  leftIcon:
                                                                      const Icon(
                                                                    AppIcons
                                                                        .ic_cross_round,
                                                                  ),
                                                                )
                                                              : 15.height,
                                                        ),
                                                        5.width,
                                                        Expanded(
                                                          child: isCustomer
                                                              ? AppOutlinedButton(
                                                                  onPress: () {
                                                                    _showBottomSheet(
                                                                      context,
                                                                      UpdateConsultationBottomDialog(
                                                                        consultation:
                                                                            consultation,
                                                                        onConsultationUpdate:
                                                                            (cons) {
                                                                          setState(
                                                                              () {
                                                                            consultation =
                                                                                cons;
                                                                          });
                                                                        },
                                                                      ),
                                                                    );
                                                                  },
                                                                  title: 'Edit',
                                                                  btnColor:
                                                                      AppColors
                                                                          .appGreenMaterial,
                                                                )
                                                              : 15.height,
                                                        ),
                                                      ],
                                                    )
                                                  : 15.height,
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : GestureDetector(
                                    onTap: () async {
                                      try {
                                        await FirebaseFirestore.instance
                                            .collection('Consultations')
                                            .doc(consultation.id)
                                            .delete()
                                            .then((value) {
                                          Navigator.pop(context);
                                        });
                                      } catch (e) {
                                        debugPrint(
                                            'error in deleting consultation :${e.toString()}');
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
                                  )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  void _onCancel(
    BuildContext context,
    bool fromUserConsultationPage,
    ConsultationModel consultation,
  ) {
    _showBottomSheet(
      context,
      ConfirmationBottomDialog(
        onCancelClick: () {
          _showBottomSheet(
            context,
            CancelFeedbackBottomDialog(
              consultation: consultation,
              onCancel: (cons) {
                setState(() {
                  consultation = cons;
                  Navigator.pop(
                    context,
                  );
                  if (!fromUserConsultationPage) {
                    Navigator.pop(
                      context,
                    );
                  }
                });
              },
            ),
          );
        },
      ),
    );
  }

  void _onStartConsultation(
    BuildContext context,
    bool isCustomer,
    ConsultationModel consultation,
  ) {
    debugPrint('log: user type:${isCustomer ? 'Customer' : 'Doctor'}');
    // consultation.toJson().log();
    if (consultation.packageType == PackageType.text) {
      debugPrint('log: user type:${isCustomer ? 'Customer' : 'Doctor'}');
      Navigator.pushNamed(
        context,
        ConversationScreen.routeName,
        arguments: {
          Constants.userModel:
              isCustomer ? consultation.specialist : consultation.customer,
          'consultation': consultation,
        },
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VideoCallScreen(
            consultationModel: consultation,
          ),
        ),
      );
    }
  }

  bool isNeedToShowStart(ConsultationModel consultationModel) {
    final current = DateTime.now().millisecondsSinceEpoch;
    if (consultationModel.status == ConsultationStatus.pending) {
      return false;
    }
    print('Current -> $current');
    print('start -> ${consultationModel.startTime}');
    print('end -> ${consultationModel.endTime}');

    if (consultationModel.packageType == PackageType.text) {
      return current >= consultationModel.startTime.millisecondsSinceEpoch &&
          current <= current + (30 * 60 * 1000);
    }
    return current >= consultationModel.startTime.millisecondsSinceEpoch &&
        current < consultationModel.endTime.millisecondsSinceEpoch;
  }

  void _showBottomSheet(BuildContext context, Widget widget) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      builder: (context) {
        return widget;
      },
    );
  }
}




// old app filled button 
/*
   AppFilledButton(
                                            onPress: () {
                                              debugPrint(
                                                  'log: user type:${isCustomer ? 'Customer' : 'Doctor'}');
                                              _onStartConsultation(
                                                context,
                                                isCustomer,
                                                consultation,
                                              );
                                            },
                                            title: (consultation.packageType ==
                                                        PackageType.text &&
                                                    consultation.packageType ==
                                                        PackageType.video &&
                                                    AppDateUtils
                                                            .getTimeGapByMilliseconds(
                                                          milliseconds: consultation
                                                              .startTime
                                                              .millisecondsSinceEpoch,
                                                        ) ==
                                                        'Expired')
                                                ? 'See conversation'
                                                : 'Start Consultation',
                                            isEnabled: consultation.isEnabled ||
                                                (consultation.packageType ==
                                                        PackageType.text &&
                                                    consultation.packageType ==
                                                        PackageType.video &&
                                                    AppDateUtils
                                                            .getTimeGapByMilliseconds(
                                                          milliseconds: consultation
                                                              .startTime
                                                              .millisecondsSinceEpoch,
                                                        ) ==
                                                        'Expired'),
                                          ),
*/