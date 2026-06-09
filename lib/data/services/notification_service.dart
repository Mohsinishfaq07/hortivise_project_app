import 'dart:convert';
import 'dart:math';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:horti_vige/ui/utils/colors/colors.dart';
import 'package:horti_vige/ui/utils/extensions/extensions.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/standalone.dart' as standalone_tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:http/http.dart' as http;

class NotificationService {
  NotificationService._();

  static Future<void> initialize() async {
    await _configureLocalTimeZone();
    await _initLocalNotifications();
    await _checkAppLaunchNotification();
  }

  static Future<void> _configureLocalTimeZone() async {
    final timeZoneName =
        (await FlutterTimezone.getLocalTimezone()).identifier;
    standalone_tz.setLocalLocation(standalone_tz.getLocation(timeZoneName));
  }

  static Future<void> _initLocalNotifications() async {
    await FlutterLocalNotificationsPlugin().initialize(
      settings: InitializationSettings(
        android: const AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
          requestCriticalPermission: true,
        ),
      ),
      // onDidReceiveNotificationResponse: notificationTapBackground,   these handlers are causing multiple thread running issue
      // onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );
  }

  static Future<void> _checkAppLaunchNotification() async {
    final details = await FlutterLocalNotificationsPlugin()
        .getNotificationAppLaunchDetails();

    if (details?.didNotificationLaunchApp ?? false) {
      final payload = details?.notificationResponse?.payload;
      if (payload != null) {
        payload.log();
      }
    }
  }

  static Future<void> askForNotificationPermission() async {
    try {
      FirebaseMessaging.instance.requestPermission(
        announcement: true,
        criticalAlert: true,
        provisional: true,
      );
    } catch (e) {
      print(e);
    }
  }

  static void setupNotifications() async {
    try {
      FirebaseMessaging.onMessageOpenedApp.listen((message) {
        message.data.log();
        _onNotification(message);
      });

      FirebaseMessaging.onMessage.listen((message) {
        message.data.log();

        _onNotification(message);
      });

      // FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      FirebaseMessaging.instance.getInitialMessage().then((message) {
        if (message != null) {
          _onNotification(message);
        }
      });

      try {
        tz_data.initializeTimeZones();
      } catch (e) {
        e.logError();
      }

      NotificationService.initialize();
    } catch (e) {
      e.logError();
    }
  }

  static void _onNotification(RemoteMessage message) {
    if (message.notification != null) {
      sendNotificationNow(
        title: message.notification!.title ?? 'ebooking',
        body: message.notification!.body ?? '',
      );
    }

    if (message.data['consultationScheduleTime'] != null) {
      scheduleNotification(
        int.tryParse(message.data['consultationScheduleTime']) ?? 0,
      );
    }
  }

  @pragma('vm:entry-point')
  static void notificationTapBackground(
    NotificationResponse notificationResponse,
  ) {}

  static NotificationDetails notificationDetails() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        'ebooking',
        'ebooking_local_channel',
        importance: Importance.max,
        priority: Priority.max,
        icon: 'ic_launcher',
        color: AppColors.colorWhite,
      ),
      iOS: DarwinNotificationDetails(
        interruptionLevel: InterruptionLevel.critical,
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );
  }

  static void scheduleNotification(
    int scheduledNotificationDateTime,
  ) async {
    if (scheduledNotificationDateTime - DateTime.now().millisecondsSinceEpoch >=
        300000) {
      final alarmTime = scheduledNotificationDateTime - 300000;
      final scheduleTime = DateTime.fromMillisecondsSinceEpoch(alarmTime);
      'Notification Scheduled'.log();
      try {
        await FlutterLocalNotificationsPlugin().zonedSchedule(
          id: Random().nextInt(10000000),
          title: 'ebooking',
          body: 'Your appointment is coming up!',
          scheduledDate: tz.TZDateTime.from(
            scheduleTime,
            tz.local,
          ),
          notificationDetails: notificationDetails(),
          matchDateTimeComponents: DateTimeComponents.dateAndTime,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        );
      } catch (e) {
        e.logError();
      }
    }
  }

  static Future<void> sendNotificationNow({
    required String title,
    required String body,
  }) async {
    await FlutterLocalNotificationsPlugin().show(
      id: Random().nextInt(10000000),
      title: title,
      body: body,
      notificationDetails: notificationDetails(),
    );
  }

  static Future<void> sendAndRetrieveMessage({
    required String title,
    required String body,
    required String token,
    int? consultationScheduleTime,
  }) async {
    const serverKey =
        'AAAAJMJU5GM:APA91bHUIhQYxEdTEWNnjIVCp5-A4-XhWakohoPYAlmy2LGcASQ4JrPTlhcbZMVojoehguBK_3KmRilm29862rD8PBKcw0Flg_y0tI-Lxpg69A0kPM3bWVOP-dONjUp9PD2lW1vSITbT';
    await http.post(
      Uri.parse('https://fcm.googleapis.com/fcm/send'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'key=$serverKey',
      },
      body: jsonEncode(
        <String, dynamic>{
          'notification': <String, dynamic>{
            'body': body,
            'title': title,
          },
          'priority': 'high',
          'data': <String, dynamic>{
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            'id': '1',
            'consultationScheduleTime': consultationScheduleTime,
          },
          // FCM Token lists.
          // 'registration_ids': ["Your_FCM_Token_One", "Your_FCM_Token_Two"],
          'to': token,
        },
      ),
    );
  }

  static Future<void> cancelScheduledNotifications() async {
    FlutterLocalNotificationsPlugin().cancelAll();
  }

  // static Future<void> initializePatientService() async {
  //   final service = FlutterBackgroundService();
  //   await service.configure(
  //     androidConfiguration: AndroidConfiguration(
  //       onStart: onPatientStart,
  //       autoStart: true,
  //       isForegroundMode: true,
  //     ),
  //     iosConfiguration: IosConfiguration(),
  //   );
  //   await service.startService();
  //   d.log('Patient Background service initialized and started');
  // }

  // static Future<void> schedulePatientNotification(
  //     DateTime appointmentDateTime, String message, int id) async {
  //   d.log(
  //       'Patient Attempting to schedule a notification for: $appointmentDateTime');

  //   AndroidNotificationChannel channel = AndroidNotificationChannel(
  //       Random.secure().nextInt(100000).toString(),
  //       'High Importance Notification',
  //       importance: Importance.max);

  //   await FlutterLocalNotificationsPlugin().zonedSchedule(
  //     id,
  //     'Consultation Reminder',
  //     message,
  //     tz.TZDateTime.from(appointmentDateTime, tz.local),
  //     NotificationDetails(
  //       android: AndroidNotificationDetails(
  //         channel.id,
  //         channel.name,
  //         importance: Importance.max,
  //         priority: Priority.high,
  //       ),
  //     ),
  //     androidAllowWhileIdle: true,
  //     uiLocalNotificationDateInterpretation:
  //         UILocalNotificationDateInterpretation.absoluteTime,
  //   );

  //   d.log(
  //       'Patient Notification scheduled for: ${appointmentDateTime.toLocal()}');
  // }
}

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

// void onPatientStart(ServiceInstance service) async {
//   d.log('Patient Background service started');
//   // tz_data.initializeTimeZones();
//   d.log('Patient Timezones initialized in background service');

//   // await Firebase.initializeApp(
//   //   options: DefaultFirebaseOptions.currentPlatform,
//   // );

//   FirebaseFirestore firestore = FirebaseFirestore.instance;
//   d.log('Patient Firestore initialized in background service');

//   firestore
//       .collection('Consultations')
//       .where('customer.id', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
//       .where('status', isEqualTo: 'accepted')
//       .snapshots()
//       .listen((snapshot) {
//     d.log('Received snapshot update with ${snapshot.docs.length} documents');

//     for (var doc in snapshot.docs) {
//       final data = doc.data();

//       // Parse the startTime string to a DateTime
//       final consultationDate = DateTime.parse(data['startTime']);
//       final consultantName = data['specialist']['userName'];

//       d.log(
//           'doc id: ${doc.id} Patient Processing document for appointment at: $consultationDate with $consultantName');

//       if (consultationDate.isAfter(DateTime.now())) {
//         // Schedule the notification for 30 minutes before the actual time
//         DateTime reminderTime =
//             consultationDate.subtract(Duration(minutes: 30));

//         if (reminderTime.isAfter(DateTime.now())) {
//           d.log(
//               'Patient Scheduling 30-minute reminder notification for: $reminderTime with $consultantName');
//           NotificationService.schedulePatientNotification(
//               reminderTime,
//               'Reminder: Your consultation will start at ${consultationDate.toLocal()} with $consultantName',
//               0);
//         }

//         // Schedule the actual consultation time notification
//         d.log(
//             'Scheduling notification for actual appointment at: $consultationDate with $consultantName');
//         NotificationService.schedulePatientNotification(consultationDate,
//             'Your consultation started with $consultantName', 1);
//       } else {
//         d.log('Patient Skipping past appointment at: $consultationDate');
//       }
//     }
//   });
// }
