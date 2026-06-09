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

// Create a global instance of ConsultantSideNotificationService
final ConsultantSideNotificationService notificationService =
    ConsultantSideNotificationService();

class ConsultantSideNotificationService {
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
    d.log('Consultant Local notifications initialized');
  }

  void scheduleConsultationNotification(
      DateTime appointmentDateTime, String message, int notificationId) async {
    d.log(
        'Consultant Attempting to schedule a notification for: $appointmentDateTime');

    AndroidNotificationChannel channel = AndroidNotificationChannel(
        Random.secure().nextInt(100000).toString(),
        'High Importance Notification',
        importance: Importance.max);

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id: notificationId,
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
        'Consultant Notification scheduled for: ${appointmentDateTime.toLocal()}');
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
    d.log('Consultant Background service initialized and started');
  }

  Future<void> startConsultantSideService() async {
    await initializeLocalNotifications();
    await initializeService();
    tz.initializeTimeZones();
  }
}

// Top-level onStart function
void onStart(ServiceInstance service) async {
  d.log('Consultant Background service started');
  tz.initializeTimeZones();
  d.log('Consultant Timezones initialized in background service');

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseFirestore firestore = FirebaseFirestore.instance;
  d.log('Consultant Firestore initialized in background service');
  d.log(' current user id: ${FirebaseAuth.instance.currentUser!.uid}');
  firestore
      .collection('Consultations')
      .where('specialist.uId',
          isEqualTo: FirebaseAuth.instance.currentUser!.uid)
      .where('status', isEqualTo: 'accepted')
      .snapshots()
      .listen((snapshot) {
    d.log('Received snapshot update with ${snapshot.docs.length} documents');

    for (var doc in snapshot.docs) {
      String uId = doc['specialist']['uId'];

      d.log('Consultation document: ${uId}');
      final data = doc.data();
      final consultationDate = DateTime.parse(data['startTime']);
      final customerName = data['customer']['userName'];

      d.log(
          'doc id: ${doc.id} Consultant Processing document for appointment at: $consultationDate with $customerName');

      if (consultationDate.isAfter(DateTime.now())) {
        // Schedule the notification for 30 minutes before the actual time
        DateTime reminderTime =
            consultationDate.subtract(Duration(minutes: 30));

        if (reminderTime.isAfter(DateTime.now())) {
          d.log(
              'Consultant Scheduling 30-minute reminder notification for: $reminderTime with $customerName');
          notificationService.scheduleConsultationNotification(
            reminderTime,
            'Reminder: Your consultation will start at ${consultationDate.toLocal()} with $customerName',
            0, // ID for 30-minute reminder notification
          );
        }

        // Schedule the actual consultation time notification
        d.log(
            'Consultant Scheduling notification for actual appointment at: $consultationDate with $customerName');
        notificationService.scheduleConsultationNotification(
          consultationDate,
          'Your consultation is starting now with $customerName!',
          1, // ID for actual appointment notification
        );
      } else {
        d.log('Consultant Skipping past appointment at: $consultationDate');
      }
    }
  });
}
