import 'package:flutter/material.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:horti_vige/constants.dart';
import 'package:horti_vige/core/utils/app_consts.dart';
import 'package:horti_vige/data/models/availability/availability.dart';
import 'package:horti_vige/data/models/package/package_model.dart';
import 'package:horti_vige/data/models/user/user_model.dart';
import 'package:horti_vige/data/services/notification_service.dart';
import 'package:horti_vige/providers/consultations_provider.dart';
import 'package:horti_vige/ui/dialogs/waiting_dialog.dart';
import 'package:horti_vige/ui/screens/user/appointment/pages/confirm_booking_page.dart';
import 'package:horti_vige/ui/screens/user/appointment/pages/select_date_time_page.dart';
import 'package:horti_vige/ui/utils/colors/colors.dart';
import 'package:horti_vige/ui/utils/extensions/extensions.dart';
import 'package:horti_vige/ui/utils/styles/text_styles.dart';
import 'package:horti_vige/ui/widgets/read_only_widget.dart';
import 'package:provider/provider.dart';

class BookAppointmentScreen extends StatefulWidget {
  const BookAppointmentScreen({super.key});
  static const routeName = 'BookAppointment';

  @override
  State<BookAppointmentScreen> createState() => _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends State<BookAppointmentScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  late DateTime _selectedDate;
  PackageModel? _selectedPkg;
  String patientTimeZone = '';

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    Future.delayed(const Duration(milliseconds: 200), () {
      setLocalTimeZone();
    });
    super.initState();
  }

  void setLocalTimeZone() async {
    String localTimeZone =
        (await FlutterTimezone.getLocalTimezone()).identifier;
    String? matchedTimeZone = timeZoneMapping[localTimeZone];
    patientTimeZone = matchedTimeZone!;
    setState(() {});
    debugPrint('patient local time zone :$patientTimeZone');
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = (ModalRoute.of(context)!.settings.arguments!
        as Map)[Constants.userModel];
    final packages = (ModalRoute.of(context)!.settings.arguments!
        as Map)[Constants.packages];

    return Scaffold(
      backgroundColor: AppColors.colorWhite,
      appBar: AppBar(
        backgroundColor: AppColors.colorWhite,
        leading: IconButton(
          onPressed: () {
            if (_tabController.index > 0) {
              setState(() {
                final index = _tabController.index;
                _tabController.index = index - 1;
              });
            } else {
              Navigator.pop(context);
            }
          },
          icon: const Icon(
            Icons.arrow_back_ios_new,
            size: 20,
          ),
        ),
        title: Text(
          _tabController.index == 0 ? 'Choose date & Time' : 'Confirm Booking',
          style: AppTextStyles.titleStyle
              .changeSize(16)
              .changeFontWeight(FontWeight.w500),
        ),
        bottom: ReadOnlyWidget(
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: AppColors.colorWhite,
                width: 2,
              ),
            ),
          ),
          child: TabBar(
            controller: _tabController,
            dividerColor: Colors.transparent,
            labelStyle: AppTextStyles.bodyStyle,
            indicatorSize: TabBarIndicatorSize.tab,
            unselectedLabelColor: AppColors.colorGrayLight,
            labelColor: AppColors.appGreenMaterial,
            indicatorPadding: 85.horizontalPadding,
            indicatorWeight: 1,
            // indicator: UnderlineTabIndicator(
            //   borderSide:
            //       BorderSide(width: 1, color: AppColors.appGreenMaterial),
            //   borderRadius: BorderRadius.circular(1),
            //   insets:  const EdgeInsets.symmetric(horizontal: 80),
            // ),
            tabs: [
              Tab(
                icon: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _tabController.index >= 0
                        ? AppColors.colorGreen
                        : AppColors.colorGrayLight,
                  ),
                  child: Center(
                    child: Text(
                      '1',
                      style: AppTextStyles.bodyStyle
                          .changeSize(14)
                          .changeColor(AppColors.colorWhite),
                    ),
                  ),
                ),
                text: 'Select Date & time',
              ),
              Tab(
                icon: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _tabController.index == 1
                        ? AppColors.colorGreen
                        : AppColors.colorGrayLight,
                  ),
                  child: Center(
                    child: Text(
                      '2',
                      style: AppTextStyles.bodyStyle
                          .changeSize(14)
                          .changeColor(AppColors.colorWhite),
                    ),
                  ),
                ),
                text: 'Checkout',
              ),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          SelectDateTimePage(
            availability: user.availability ?? Availability.empty(),
            packages: packages,
            bookNowClick: (selectedDate, selectedPackage) {
              setState(() {
                _selectedDate = selectedDate;
                _selectedPkg = selectedPackage;
                print('tab 1 is selected');
                _tabController.index = 1;
              });
              debugPrint('_selectedDate$_selectedDate');
            },
            consultantEmail: user.email,
          ),
          ConfirmBookingPage(
            selectedPackage: _selectedPkg,
            confirmBooking: (specialist) {
              submitConsultationRequest(
                  selectedDate: _selectedDate,
                  selectedPkg: _selectedPkg!,
                  specialist: specialist,
                  timeZone: patientTimeZone);
            },
          ),
        ],
      ),
    );
  }

  void submitConsultationRequest({
    required DateTime selectedDate,
    required PackageModel selectedPkg,
    required UserModel specialist,
    required String timeZone,
  }) {
    context.showProgressDialog(
      dialog: const WaitingDialog(status: 'Sending Request'),
    );
    Provider.of<ConsultationProvider>(context, listen: false)
        .sendConsultationRequest(
      timeZone: timeZone,
      specialistUser: specialist,
      selectedDate: selectedDate,
      selectedPackage: selectedPkg,
    )
        .then((message) {
      Navigator.pop(context);
      context.showSnack(message: message);
      Navigator.pop(context);
      NotificationService.sendNotificationNow(
        title: 'Consultation Request',
        body: 'Your request has been sent successfully.',
      );

      NotificationService.sendAndRetrieveMessage(
        title: 'Consultation Request',
        body: 'You have a new consultation request.',
        token: specialist.fcmToken ?? '',
        consultationScheduleTime: DateTime.now()
            .add(const Duration(seconds: 5))
            .millisecondsSinceEpoch,
      );
    }).catchError((error) {
      Navigator.pop(context);
      context.showSnack(message: '$error');
    });
  }
}
