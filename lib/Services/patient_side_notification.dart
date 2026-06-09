import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:horti_vige/firebase_options.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:developer' as d;

// Create a global instance of PatientSideNotificationService
final PatientSideNotificationService notificationService =
    PatientSideNotificationService();

class PatientSideNotificationService {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initializeLocalNotifications() async {
    const AndroidInitializationSettings androidInitializationSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: androidInitializationSettings);
    await flutterLocalNotificationsPlugin.initialize(
      settings: initializationSettings,
    );
    d.log('Patient Local notifications initialized');
  }

  void scheduleConsultationNotification(
      DateTime appointmentDateTime, String message, int id) async {
    d.log(
        'Patient Attempting to schedule a notification for: $appointmentDateTime');

    AndroidNotificationChannel channel = AndroidNotificationChannel(
        Random.secure().nextInt(100000).toString(),
        'High Importance Notification',
        importance: Importance.max);

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id: id,
      title: 'Consultation Reminder',
      body: message,
      scheduledDate: tz.TZDateTime.from(appointmentDateTime, tz.local),
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          channel.id,
          channel.name,
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );

    d.log(
        'Patient Notification scheduled for: ${appointmentDateTime.toLocal()}');
  }

  Future<void> initializeService() async {
    final service = FlutterBackgroundService();
    await service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        autoStart: true,
        isForegroundMode: true,
      ),
      iosConfiguration: IosConfiguration(),
    );
    await service.startService();
    d.log('Patient Background service initialized and started');
  }

  Future<void> startUserSideService() async {
    await initializeLocalNotifications();
    await initializeService();
    tz.initializeTimeZones();
  }
}

// Top-level onStart function
void onStart(ServiceInstance service) async {
  d.log('Patient Background service started');
  tz.initializeTimeZones();
  d.log('Patient Timezones initialized in background service');

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseFirestore firestore = FirebaseFirestore.instance;
  d.log('Patient Firestore initialized in background service');

  firestore
      .collection('Consultations')
      .where('customer.id', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
      .where('status', isEqualTo: 'accepted')
      .snapshots()
      .listen((snapshot) {
    d.log('Received snapshot update with ${snapshot.docs.length} documents');

    for (var doc in snapshot.docs) {
      final data = doc.data();

      // Parse the startTime string to a DateTime
      final consultationDate = DateTime.parse(data['startTime']);
      final consultantName = data['specialist']['userName'];

      d.log(
          'doc id: ${doc.id} Patient Processing document for appointment at: $consultationDate with $consultantName');

      if (consultationDate.isAfter(DateTime.now())) {
        // Schedule the notification for 30 minutes before the actual time
        DateTime reminderTime =
            consultationDate.subtract(Duration(minutes: 30));

        if (reminderTime.isAfter(DateTime.now())) {
          d.log(
              'Patient Scheduling 30-minute reminder notification for: $reminderTime with $consultantName');
          notificationService.scheduleConsultationNotification(
              reminderTime,
              'Reminder: Your consultation will start at ${consultationDate.toLocal()} with $consultantName',
              0);
        }

        // Schedule the actual consultation time notification
        d.log(
            'Scheduling notification for actual appointment at: $consultationDate with $consultantName');
        notificationService.scheduleConsultationNotification(consultationDate,
            'Your consultation started with $consultantName', 1);
      } else {
        d.log('Patient Skipping past appointment at: $consultationDate');
      }
    }
  });
}
