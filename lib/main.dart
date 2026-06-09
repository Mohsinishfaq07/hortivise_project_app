// import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:horti_vige/constants.dart';
import 'package:horti_vige/data/services/notification_service.dart';
import 'package:horti_vige/firebase_options.dart';
import 'package:horti_vige/providers/availability_provider.dart';
import 'package:horti_vige/providers/blogs_provider.dart';
import 'package:horti_vige/providers/chat_provider.dart';
import 'package:horti_vige/providers/consultation_pricing_provider.dart';
import 'package:horti_vige/providers/consultations_provider.dart';
import 'package:horti_vige/providers/notifications_provider.dart';
import 'package:horti_vige/providers/packages_provider.dart';
import 'package:horti_vige/providers/user_provider.dart';
import 'package:horti_vige/ui/screens/auth/become_consultant_screen.dart';
import 'package:horti_vige/ui/screens/auth/change_password_screen.dart';
import 'package:horti_vige/ui/screens/auth/forgot_password_screen.dart';
import 'package:horti_vige/ui/screens/auth/login_screen.dart';
import 'package:horti_vige/ui/screens/auth/signup_screen.dart';
import 'package:horti_vige/ui/screens/common/blog_detail_screen.dart';
import 'package:horti_vige/ui/screens/common/conversation_screen.dart';

import 'package:horti_vige/ui/screens/common/landing_screen.dart';
import 'package:horti_vige/ui/screens/common/profile_screen.dart';
import 'package:horti_vige/ui/screens/consultant/consultation_details_screen.dart';
import 'package:horti_vige/ui/screens/consultant/consultation_pricing/add_pricing_screen.dart';
import 'package:horti_vige/ui/screens/consultant/consultation_pricing/consultation_pricing_screen.dart';
import 'package:horti_vige/ui/screens/consultant/consultation_request_screen.dart';
import 'package:horti_vige/ui/screens/consultant/edit_availability_screen.dart';
import 'package:horti_vige/ui/screens/consultant/main/consultant_main_screen.dart';
import 'package:horti_vige/ui/screens/greetings/booking_success_screen.dart';
import 'package:horti_vige/ui/screens/greetings/congrats_screen.dart';
import 'package:horti_vige/ui/screens/greetings/thank_you_screen.dart';
import 'package:horti_vige/ui/screens/user/appointment/book_appointment_screen.dart';
import 'package:horti_vige/ui/screens/user/calendar_screen.dart';
import 'package:horti_vige/ui/screens/user/consultant_details_screen.dart';
import 'package:horti_vige/ui/screens/video_call_screen.dart';
import 'package:horti_vige/ui/utils/colors/colors.dart';
import 'package:horti_vige/ui/utils/styles/text_styles.dart';
import 'package:horti_vige/ui/widgets/app_nav_drawer.dart';
import 'package:horti_vige/core/utils/helpers/preference_manager.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';
import 'dart:developer' as developer;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await PreferenceManager.getInstance().initSharedPreferences();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // Ensure Firestore isn’t left disabled after offline/errors (helps flaky links).
  await FirebaseFirestore.instance.enableNetwork();
  //await FirebaseAppCheck.instance.activate();
  // await dotenv.load(fileName: 'assets/.env');

  NotificationService.setupNotifications();
  // VideoService.instance.init();
  // final isGranted = await VideoService.instance.isPermissionsGranted();
  // if (isGranted) {
  //   await VideoService.instance.initAgora();
  // }

  final FirebaseAnalytics firebaseAnalytics = FirebaseAnalytics.instance;
  if (kDebugMode) {
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(false);
    FlutterError.onError = (errorDetails) {
      // ignore: avoid_bool_literals_in_conditional_expressions
      final isFatal = (errorDetails.exception is HttpException ||
              errorDetails.exception is SocketException ||
              errorDetails.exception is HandshakeException ||
              errorDetails.exception is PlatformException ||
              errorDetails.exception is ClientException ||
              errorDetails.exception is FlutterError ||
              errorDetails.exception is FileSystemException)
          ? false
          : true;
      developer.log('error occurred: $errorDetails');
      developer.log('error isFatal: $isFatal');
      FirebaseCrashlytics.instance.recordFlutterError(
        errorDetails,
        fatal: isFatal,
      );
    };
  } else {
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
    FlutterError.onError = (errorDetails) {
      FirebaseCrashlytics.instance.recordFlutterError(
        errorDetails,
        fatal: !(errorDetails.exception is HttpException ||
            errorDetails.exception is SocketException ||
            errorDetails.exception is HandshakeException ||
            errorDetails.exception is PlatformException ||
            errorDetails.exception is ClientException ||
            errorDetails.exception is FlutterError ||
            errorDetails.exception is FileSystemException),
      );
    };
  }

  getTimeZoneAndSave();
  injectionFunction();

  runApp(
    const MyApp(),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // This widget is the root of your application.

  Future<void> setUpAllThings() async {
    await PreferenceManager.getInstance().initSharedPreferences();
  }

  @override
  void initState() {
    //  setUpAllThings();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => UserProvider(),
        ),
        ChangeNotifierProvider(create: (_) => ConsultationProvider()),
        ChangeNotifierProvider(create: (_) => PackagesProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => NotificationsProvider()),
        ChangeNotifierProvider(create: (_) => BlogsProvider()),
        ChangeNotifierProvider(
          create: (_) => AvailabilityProvider(
            userProvider: UserProvider(),
          ),
        ),
        // ChangeNotifierProvider(
        //   create: (_) => ConsultationPricingProvider(
        //     userProvider: UserProvider(),
        //   ),
        // ),
      ],
      child: MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: TextScaler.noScaling,
        ),
        child: MaterialApp(
          title: 'ebooking',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: AppColors.colorGreen),
            snackBarTheme: const SnackBarThemeData(
              contentTextStyle: AppTextStyles.bodyStyleMedium,
            ),
            useMaterial3: false,
            appBarTheme: const AppBarTheme(
              backgroundColor: AppColors.colorWhite,
              foregroundColor: AppColors.colorBlack,
              elevation: 1,
            ),
            fontFamily: 'Poppins',
          ),
          initialRoute: LandingScreen.routeName,
          routes: {
            LandingScreen.routeName: (ctx) => const LandingScreen(),
            LoginScreen.routeName: (ctx) => const LoginScreen(),
            SignUpScreen.routeName: (ctx) => const SignUpScreen(),
            ZoomDrawerScreen.routeName: (ctx) => const ZoomDrawerScreen(),
            BecomeConsultantScreen.routeName: (ctx) =>
                const BecomeConsultantScreen(),
            ThankYouScreen.routeName: (ctx) => const ThankYouScreen(),
            CongratsScreen.routeName: (ctx) => const CongratsScreen(),
            ConsultantDetailsScreen.routeName: (ctx) =>
                const ConsultantDetailsScreen(),
            BookAppointmentScreen.routeName: (ctx) =>
                const BookAppointmentScreen(),
            CalendarScreen.routeName: (ctx) => const CalendarScreen(),
            BookingSuccessScreen.routeName: (ctx) =>
                const BookingSuccessScreen(),
            ConsultantMainScreen.routeName: (ctx) =>
                const ConsultantMainScreen(),
            ConsultationDetailsScreen.routeName: (ctx) =>
                const ConsultationDetailsScreen(),
            EditAvailabilityScreen.routeName: (ctx) =>
                const EditAvailabilityScreen(),
            ConsultationRequestScreen.routeName: (ctx) =>
                const ConsultationRequestScreen(),
            ProfileScreen.routeName: (ctx) => const ProfileScreen(),
            BlogDetailScreen.routeName: (ctx) => const BlogDetailScreen(),
            ChangePasswordScreen.routeName: (ctx) =>
                const ChangePasswordScreen(),
            DemoAppHome.routeName: (ctx) => const DemoAppHome(),
            // ConsultationPricingScreen.routeName: (ctx) =>
            //     const ConsultationPricingScreen(),
            // AddPricingScreen.routeName: (ctx) => const AddPricingScreen(),
            ForgotPasswordScreen.routeName: (ctx) =>
                const ForgotPasswordScreen(),
            ConversationScreen.routeName: (ctx) => const ConversationScreen(),
          },
        ),
      ),
    );
  }
}

// top class function to store the local time zone
void getTimeZoneAndSave() async {
  String localTimeZone =
      (await FlutterTimezone.getLocalTimezone()).identifier; // e.g., Asia/Karachi
  String? matchedTimeZone = timeZoneMapping[localTimeZone];
  SharedPreferences sf = await SharedPreferences.getInstance();
  sf.remove('localTimeZone');

  sf.setString(
      'localTimeZone', matchedTimeZone ?? 'Pakistan Standard Time (GMT +5:00)');

  debugPrint('local time zone in cache:${sf.getString('localTimeZone')}');
}
