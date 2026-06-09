import 'package:flutter/foundation.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:horti_vige/core/exceptions/app_exception.dart';
import 'package:horti_vige/core/utils/helpers/preference_manager.dart';
import 'package:horti_vige/data/enums/consultation_status.dart';
import 'package:horti_vige/data/enums/notification_type.dart';
import 'package:horti_vige/data/models/consultation/consultation_model.dart';
import 'package:horti_vige/data/models/notification/notification_model.dart';
import 'package:horti_vige/data/models/notification/notification_user.dart';
import 'package:horti_vige/data/models/package/package_model.dart';
import 'package:horti_vige/data/models/user/user_model.dart';
import 'package:horti_vige/data/repositories/consultations_repository.dart';
import 'package:horti_vige/data/services/notification_service.dart';
import 'package:horti_vige/ui/utils/extensions/extensions.dart';

class ConsultationProvider extends ChangeNotifier {
  final _consultationsCollectionRef =
      FirebaseFirestore.instance.collection('Consultations');
  final _notificationsCollectionRef =
      FirebaseFirestore.instance.collection('Notifications');

  final double taxAmount = 2.75;

  PreferenceManager prefs = PreferenceManager.getInstance();

  Future<void> _setNotificationDoc(
    String documentId,
    NotificationModel model,
  ) async {
    try {
      await _notificationsCollectionRef.doc(documentId).set(model.toJson());
    } on FirebaseException catch (e) {
      if (kDebugMode) {
        debugPrint(
          'Notifications write skipped (${e.code}): ${e.message}',
        );
      }
    }
  }

  /// One Firestore listener for the home screen. Call [resetSpecialistBookingStream]
  /// after logout / account switch so the next specialist gets a fresh query.
  Stream<List<ConsultationModel>>? _pendingBySpecialistStream;

  void resetSpecialistBookingStream() {
    _pendingBySpecialistStream = null;
  }

  Future<String> sendConsultationRequest(
      {required UserModel specialistUser,
      required DateTime selectedDate,
      required PackageModel selectedPackage,
      required String timeZone}) async {
    final id = _consultationsCollectionRef.doc().id;
    final currentUser = PreferenceManager.getInstance().getCurrentUser()!;
    final totalAmount = selectedPackage.amount + taxAmount;
    final consultation = ConsultationModel(
        id: id,
        title: selectedPackage.title,
        description: specialistUser.specialist?.bio ?? '',
        durationTime: selectedPackage.duration,
        startTime: selectedDate,
        endTime: selectedDate.add(Duration(minutes: selectedPackage.duration)),
        startDateTime: selectedDate,
        endDateTime:
            selectedDate.add(Duration(minutes: selectedPackage.duration)),
        isEnabled: false,
        specialist: specialistUser,
        customer: currentUser,
        packageId: selectedPackage.id,
        tax: taxAmount,
        totalAmount: totalAmount,
        packageType: selectedPackage.type,
        timeZone: timeZone);

    await ConsultationRepository.addConsultationRequest(consultation);

    final notificationId = _notificationsCollectionRef.doc().id;
    final notificationModel = NotificationModel(
      id: notificationId,
      title: 'Consultation requested',
      descriptionUser:
          'Consultation request is send to ${consultation.specialist.userName} successfully',
      iconImageUrl: '',
      time: DateTime.now().millisecondsSinceEpoch,
      type: NotificationType.request_sent,
      data: '',
      userIds: [consultation.specialist.uId, consultation.customer.uId],
      descriptionSpecialist:
          'New consultation request is received from ${prefs.getCurrentUser()!.userName}',
      generatedBy: NotificationUser(
        id: prefs.getCurrentUser()!.uId,
        name: prefs.getCurrentUser()!.userName,
        profileUrl: prefs.getCurrentUser()!.profileUrl,
        userType: prefs.getCurrentUser()!.type,
      ),
    );
    await _setNotificationDoc(id, notificationModel);

    return 'Request submitted successfully';
  }

  Stream<List<ConsultationModel>>
      getAllConsultationPendingRequestsBySpecialist() {
    return _pendingBySpecialistStream ??=
        ConsultationRepository.getPendingConsultationRequestsBySpecialist();
  }

  Future<void> updateConsultationRequestStatus({
    required String consultationId,
    required ConsultationStatus status,
  }) async {
    final map = <String, dynamic>{};
    map['status'] = status.name;
    final consultationDoc =
        await _consultationsCollectionRef.doc(consultationId).get();
    final consultation = ConsultationModel.fromJson(consultationDoc.data()!);

    await _consultationsCollectionRef.doc(consultationId).update(map);

    final id = _notificationsCollectionRef.doc().id;

    var userDes = '';
    var specDes = '';
    if (status == ConsultationStatus.rejected) {
      userDes =
          'Your consultation request is rejected by ${consultation.specialist.userName}. Please check specialist availability times';
      specDes =
          'You have canceled the consultation request from ${consultation.customer.userName}. Please ensure your availability on your selected available times';
    }
    if (status == ConsultationStatus.accepted) {
      userDes =
          'Your consultation request is accepted by ${consultation.specialist.userName}. Please be on time to attend meeting';
      specDes =
          'You have accepted the consultation request of ${consultation.customer.userName}. Please be available on meeting time';
    }

    final notificationModel = NotificationModel(
      id: id,
      title: 'Consultation Updated',
      descriptionUser: userDes,
      iconImageUrl: '',
      time: DateTime.now().millisecondsSinceEpoch,
      type: NotificationType.request_updated,
      data: '',
      userIds: [consultation.specialist.uId, consultation.customer.uId],
      descriptionSpecialist: specDes,
      generatedBy: NotificationUser(
        id: prefs.getCurrentUser()!.uId,
        name: prefs.getCurrentUser()!.userName,
        profileUrl: prefs.getCurrentUser()!.profileUrl,
        userType: prefs.getCurrentUser()!.type,
      ),
    );
    await _setNotificationDoc(id, notificationModel);
  }

  Future<void> updateConsultationModel({
    required String consultationId,
    required ConsultationModel model,
  }) async {
    await _consultationsCollectionRef
        .doc(consultationId)
        .update(model.toJson());

    final id = _notificationsCollectionRef.doc().id;

    var userDes = '';
    var specDes = '';
    if (model.status == ConsultationStatus.pendingUpdated) {
      userDes =
          'You have updated the consultation. It will go for approval from ${model.specialist.userName} again!';
      specDes =
          'Your Meeting for consultation is updated by ${model.customer.userName}, please approve or decline according to your availability';
    }

    final notificationModel = NotificationModel(
      id: id,
      title: 'Consultation Updated',
      descriptionUser: userDes,
      iconImageUrl: '',
      time: DateTime.now().millisecondsSinceEpoch,
      type: NotificationType.request_updated,
      data: '',
      userIds: [model.specialist.uId, model.customer.uId],
      descriptionSpecialist: specDes,
      generatedBy: NotificationUser(
        id: prefs.getCurrentUser()!.uId,
        name: prefs.getCurrentUser()!.userName,
        profileUrl: prefs.getCurrentUser()!.profileUrl,
        userType: prefs.getCurrentUser()!.type,
      ),
    );
    await _setNotificationDoc(id, notificationModel);
  }

  Future<List<ConsultationModel>> getAllCurrentUserConsultations() async {
    final currentUserId =
        PreferenceManager.getInstance().getCurrentUser()?.id ?? '';
    final querySnapshots = await _consultationsCollectionRef
        .where(FieldPath(const ['specialist', 'id']), isEqualTo: currentUserId)
        .orderBy('startTime', descending: true)
        .get();
    final querySnapshots2 = await _consultationsCollectionRef
        .where(FieldPath(const ['customer', 'id']), isEqualTo: currentUserId)
        .orderBy('startTime', descending: true)
        .get();
    querySnapshots.docs.addAll(querySnapshots2.docs);

    final list1 = querySnapshots.docs
        .map((doc) => ConsultationModel.fromJson(doc.data()))
        .toList();

    final list2 = querySnapshots2.docs
        .map((doc) => ConsultationModel.fromJson(doc.data()))
        .toList();
    list1.addAll(list2);
    list1.sort((a, b) => a.startTime.compareTo(b.startTime));
    return list1.reversed.toList();
  }

  Future<ConsultationModel?> findConsultationBySpecialistEmail(
    String email,
  ) async {
    try {
      return ConsultationRepository.findConsultationBySpecialistEmail(
        email,
      );
    } on AppException catch (e) {
      e.message.logError();
    } catch (e) {
      e.logError();
    }
    return null;
  }

  bool isCustomer() {
    return PreferenceManager.getInstance().getCurrentUser()?.specialist == null;
  }

  Future<String> cancelConsultation({
    required ConsultationModel consultation,
  }) async {
    final map = <String, dynamic>{};
    map['status'] = ConsultationStatus.canceled.name;
    await _consultationsCollectionRef.doc(consultation.id).update(map);
    //send Notification as well.
    final id = _notificationsCollectionRef.doc().id;

    var userDes = '';
    var specDes = '';

    userDes =
        'You canceled the consultation with ${consultation.specialist.userName}. Your amount will be send you back soon!';
    specDes =
        'Your Meeting for consultation is canceled by ${consultation.customer.userName}, please approve or decline according to your availability';

    final notificationModel = NotificationModel(
      id: id,
      title: 'Request Canceled',
      descriptionUser: userDes,
      iconImageUrl: '',
      time: DateTime.now().millisecondsSinceEpoch,
      type: NotificationType.request_cancel,
      data: '',
      userIds: [consultation.specialist.uId, consultation.customer.uId],
      generatedBy: NotificationUser(
        id: prefs.getCurrentUser()!.uId,
        name: prefs.getCurrentUser()!.userName,
        profileUrl: prefs.getCurrentUser()!.profileUrl,
        userType: prefs.getCurrentUser()!.type,
      ),
      descriptionSpecialist: specDes,
    );
    await _setNotificationDoc(id, notificationModel);
    NotificationService.sendNotificationNow(
      title: 'Consultation Canceled',
      body: 'You canceled the consultation.',
    );

    NotificationService.sendAndRetrieveMessage(
      title: 'Consultation Canceled',
      body:
          'Your Meeting for consultation is canceled by ${consultation.customer.userName}.',
      token: consultation.specialist.fcmToken ?? '',
      consultationScheduleTime:
          DateTime.now().add(const Duration(seconds: 5)).millisecondsSinceEpoch,
    );
    return 'Consultation canceled successfully';
  }
}
