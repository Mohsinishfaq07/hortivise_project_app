import 'package:flutter/material.dart';
import 'package:horti_vige/Services/patient_side_notification.dart';
import 'package:horti_vige/data/services/notification_service.dart';

import 'package:horti_vige/ui/resources/app_icons_icons.dart';
import 'package:horti_vige/ui/screens/user/main/pages/user_blogs_page.dart';
import 'package:horti_vige/ui/screens/user/main/pages/user_consultants_page.dart';
import 'package:horti_vige/ui/screens/user/main/pages/user_home_page.dart';
import 'package:horti_vige/ui/screens/user/main/pages/user_notifications_page.dart';
import 'package:horti_vige/ui/utils/colors/colors.dart';
import 'package:horti_vige/ui/utils/styles/text_styles.dart';
import 'package:horti_vige/ui/widgets/exit_bottom_sheet.dart';

class UserMainScreen extends StatefulWidget {
  const UserMainScreen({super.key});

  @override
  State<UserMainScreen> createState() => _UserMainScreenState();
}

class _UserMainScreenState extends State<UserMainScreen> {
  final _pages = const [
    UserHomePage(),
    UserConsultantsPage(),
    UserNotificationsPage(),
    UserBlogsPage(),
  ];

  int _index = 0;

  @override
  void initState() {
    super.initState();
    //  PatientSideNotificationService().startUserSideService();
    //NotificationService.initializePatientService();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        backgroundColor: AppColors.colorBeige,
        body: _pages[_index],
        bottomNavigationBar: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(12),
            topRight: Radius.circular(12),
          ),
          child: BottomNavigationBar(
            onTap: (index) {
              setState(() {
                _index = index;
              });
            },
            currentIndex: _index,
            selectedItemColor: AppColors.colorGreen,
            unselectedItemColor: AppColors.colorGray.withAlpha(80),
            showUnselectedLabels: true,
            showSelectedLabels: true,
            selectedIconTheme: const IconThemeData(size: 20),
            unselectedIconTheme: const IconThemeData(size: 20),
            selectedFontSize: 11,
            unselectedFontSize: 11,
            selectedLabelStyle: AppTextStyles.bottomTabTextStyle,
            type: BottomNavigationBarType.fixed,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(AppIcons.home_outlined),
                activeIcon: Icon(AppIcons.home_filled),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(AppIcons.consultations_outlined),
                activeIcon: Icon(AppIcons.consultations_filled),
                label: 'Consultation',
              ),
              BottomNavigationBarItem(
                icon: Icon(AppIcons.notifications_outlined),
                activeIcon: Icon(AppIcons.notificatins_filled),
                label: 'Notifications',
              ),
              BottomNavigationBarItem(
                icon: Icon(AppIcons.blog_outlined),
                activeIcon: Icon(AppIcons.blog_filled),
                label: 'Blogs',
              ),
            ],
          ),
        ),
      ),
      onWillPop: () async {
        debugPrint('index: $_index');
        if (_index == 0) {
          showModalBottomSheet(
            context: context,
            backgroundColor: AppColors.colorBeige,
            builder: (context) {
              return const ExitBottomSheet();
            },
          );
        } else {
          setState(() {
            _index = 0;
          });
        }
        debugPrint('index: $_index');

        return false;
      },
    );
  }
}
