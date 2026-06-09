import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:horti_vige/core/exceptions/app_exception.dart';
import 'package:horti_vige/data/enums/specialist_category.dart';
import 'package:horti_vige/data/enums/user_type.dart';
import 'package:horti_vige/data/models/availability/availability.dart';
import 'package:horti_vige/data/models/user/specialist.dart';
import 'package:horti_vige/data/models/user/user_model.dart';
import 'package:provider/provider.dart';
import 'package:horti_vige/providers/consultations_provider.dart';
import 'package:horti_vige/data/repositories/user_repository.dart';
import 'package:horti_vige/data/services/auth_service.dart';
import 'package:horti_vige/ui/screens/common/profile_screen.dart';
import 'package:horti_vige/ui/utils/extensions/extensions.dart';
import 'package:horti_vige/core/utils/helpers/preference_manager.dart';
import 'package:horti_vige/ui/widgets/app_nav_drawer.dart';

class UserProvider extends ChangeNotifier {
  /// Firestore can hang when the device is offline or the link is flaky; without
  /// a timeout, [updateUser] never completes and [finally] never clears loading.
  /// 90s helps slow mobile / USB debugging paths; still fails fast vs hanging forever.
  static const Duration _firestoreOpTimeout = Duration(seconds: 90);

  static const String _firestoreTimeoutMessage =
      'Firestore did not respond in time. Stay on this screen until save finishes '
      '(switching apps can kill the connection). Check Wi‑Fi, turn off VPN, or try '
      'again. If Google Play services / DNS fail, toggle airplane mode once. '
      'Local data is kept when possible.';

  final _authService = AuthService();
  final _userCollectionRef = FirebaseFirestore.instance.collection('Users');
  final _profilesStoreRef =
      FirebaseStorage.instance.ref().child('UsersProfiles');
  final _firebaseAuth = FirebaseAuth.instance;
  final _prefManager = PreferenceManager.getInstance();

  final List<UserModel> _specialistsList = [];

  /// One stream per signed-in email so [StreamBuilder] is not reset to waiting
  /// on every [notifyListeners] from [Consumer<UserProvider>].
  String? _userStreamEmail;
  Stream<UserModel>? _userStream;

  var _selectedCat = 'All';
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  /// Resets stuck loading from [updateUser] / [loginUser] (e.g. after logout or
  /// if a network call never completed). Login UI binds to [isLoading].
  void clearLoading() {
    if (!_isLoading) return;
    _isLoading = false;
    notifyListeners();
  }

  /// Re-enables network and retries [write] up to [maxAttempts] times on timeout
  /// (common after app backgrounding, DNS blips, or MIUI killing sockets).
  Future<void> _firestoreWriteWithRetries(
    Future<void> Function() write, {
    required Duration perAttemptTimeout,
    int maxAttempts = 3,
  }) async {
    for (var attempt = 1; attempt <= maxAttempts; attempt++) {
      try {
        await FirebaseFirestore.instance.enableNetwork();
        await write().timeout(
          perAttemptTimeout,
          onTimeout: () => throw TimeoutException('firestore'),
        );
        return;
      } on TimeoutException {
        if (attempt == maxAttempts) rethrow;
        await Future<void>.delayed(Duration(seconds: 2 * attempt));
      }
    }
  }

  Future<void> signUpNewUser({
    required String name,
    required String email,
    required String password,
    required UserType type,
    String profileUrl = '',
  }) async {
    User? authUser;
    try {
      final effectiveProfileUrl = profileUrl.isNotEmpty ? profileUrl : '';

      final user = await _authService.createUserWithEmailAndPassword(
        email,
        password,
      );
      authUser = user;
      final model = UserModel(
        id: user.uid,
        userName: name,
        email: email,
        profileUrl: effectiveProfileUrl,
        uId: user.uid,
        isAuthenticated: true,
        type: type,
      );
      await UserRepository.createUser(model);
      await _prefManager.saveUserModelInPref(model);

      if (profileUrl.isNotEmpty) {
        await updateProfilePhoto(profileUri: profileUrl);
      }
    } on AppException {
      // If profile save failed after auth user creation, rollback auth user.
      try {
        await authUser?.delete();
      } catch (_) {}
      rethrow;
    } catch (e) {
      try {
        await authUser?.delete();
      } catch (_) {}
      throw AppException(
        title: 'Something went wrong',
        message: e.toString(),
      );
    }
    notifyListeners();
  }

  /// When [silent] is true, no global loading and no thrown [AppException] on
  /// failure — used for background sync (e.g. default availability). Prefs are
  /// still updated so local state matches when the network is poor.
  Future<void> updateUser({
    required UserModel model,
    bool silent = false,
  }) async {
    if (!silent) {
      _isLoading = true;
      notifyListeners();
    }

    try {
      final t = silent ? const Duration(minutes: 3) : _firestoreOpTimeout;
      await _firestoreWriteWithRetries(
        () => UserRepository.updateUser(model),
        perAttemptTimeout: t,
      );
      if (!silent &&
          model.type == UserType.SPECIALIST &&
          bioController.text.isNotEmpty) {
        await _firestoreWriteWithRetries(
          () async {
            await FirebaseFirestore.instance
                .collection('Users')
                .doc(model.email)
                .update({
              'specialist.bio': bioController.text.trim(),
            });
          },
          perAttemptTimeout: t,
        );
      }
      await _prefManager.saveUserModelInPref(model);
    } on TimeoutException catch (_) {
      if (silent) {
        await _prefManager.saveUserModelInPref(model);
        return;
      }
      throw AppException(
        title: 'Connection timeout',
        message: _firestoreTimeoutMessage,
      );
    } on AppException catch (e) {
      if (silent) {
        await _prefManager.saveUserModelInPref(model);
        e.message.logError();
        return;
      }
      rethrow;
    } catch (e) {
      e.logError();
      if (silent) {
        await _prefManager.saveUserModelInPref(model);
        return;
      }
      throw AppException(
        title: 'Update failed',
        message: e.toString(),
      );
    } finally {
      if (!silent) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  Future<void> updateFCMToken() async {
    try {
      if (_firebaseAuth.currentUser == null) return;
      final user = await UserRepository.get(_authService.currentUser!.email!);
      if (user == null) return;

      final fcmToken = await FirebaseMessaging.instance.getToken();
      if (fcmToken == null) return;
      if (fcmToken.isNotEmpty && fcmToken != user.fcmToken) {
        await UserRepository.saveFCMToken(user.email, fcmToken);
      }
    } on AppException catch (e) {
      e.message.logError();
    } catch (e) {
      e.logError();
    }
  }

  Stream<UserModel> getUserStream() {
    final email = _firebaseAuth.currentUser?.email ??
        _prefManager.getCurrentUser()?.email;
    if (email == null || email.isEmpty) {
      _userStreamEmail = null;
      _userStream = null;
      return Stream<UserModel>.error(
        StateError('No signed-in user email for user stream'),
      );
    }
    if (_userStream == null || _userStreamEmail != email) {
      _userStreamEmail = email;
      _userStream = UserRepository.getUserStream(email);
    }
    return _userStream!;
  }

  /// If Firebase Auth succeeded but loading the Firestore profile did not, we must
  /// sign out and clear prefs. Otherwise [LandingScreen] still sees a matching
  /// `currentUser` + cached email on the next launch and skips login — even though
  /// this login never finished.
  Future<void> _rollbackLoginAfterAuthSucceeded() async {
    try {
      await _firebaseAuth.signOut();
    } catch (_) {}
    try {
      await _prefManager.deleteUser();
    } catch (_) {}
  }

  Future<void> loginUser(
      {required String email,
      required String password,
      required BuildContext context}) async {
    var authSucceeded = false;
    try {
      _isLoading = true;
      notifyListeners();
      await _authService.signInWithEmailAndPassword(
        email,
        password,
      );
      authSucceeded = true;

      // Firestore first read after sign-in can take several seconds (TLS/GMS init,
      // wireless debug latency). Auth is already done; this fetch loads your profile.
      final resolvedEmail = _firebaseAuth.currentUser?.email ?? email;
      final appUser = await UserRepository.get(resolvedEmail).timeout(
        const Duration(seconds: 45),
        onTimeout: () => throw AppException(
          title: 'Connection timeout',
          message: _firestoreTimeoutMessage,
        ),
      );
      if (appUser == null) {
        throw AppException(
          title: 'Login failed',
          message: 'User profile not found. Please sign up again.',
        );
      } else {
        await _prefManager.saveUserModelInPref(appUser);
        if (context.mounted) {
          context.read<ConsultationProvider>().resetSpecialistBookingStream();
        }
        Navigator.pushNamed(context, ZoomDrawerScreen.routeName);
      }
    } on AppException catch (e) {
      if (authSucceeded) {
        await _rollbackLoginAfterAuthSucceeded();
      }
      rethrow;
    } catch (e) {
      if (authSucceeded) {
        await _rollbackLoginAfterAuthSucceeded();
      }
      throw AppException(
        title: 'Something went wrong',
        message: e.toString(),
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // change password
  Future<String> changePassword({
    required String oldPassword,
    required String newPassword,
    required BuildContext context,
  }) async {
    return _authService.changePassword(oldPassword, newPassword);
  }

  Future<void> updateProfilePhoto({String profileUri = ''}) async {
    final profileImageRef =
        _profilesStoreRef.child(Uri.parse(profileUri).pathSegments.last);
    final file = File(profileUri);
    await profileImageRef.putFile(file);
    final downloadUrl = await profileImageRef.getDownloadURL();
    final map = <String, dynamic>{};
    map['profileUrl'] = downloadUrl;
    await _userCollectionRef
        .doc(FirebaseAuth.instance.currentUser?.email)
        .update(map);
    final model = _prefManager.getCurrentUser();
    _prefManager.saveUserModelInPref(
      model?.copyWith(
        profileUrl: downloadUrl,
      ),
    );
    notifyListeners();
  }

  UserModel? getCurrentUser() {
    return _prefManager.getCurrentUser();
  }

  UserType getCurrentUserType() {
    return _prefManager.getCurrentUser()?.type ?? UserType.CUSTOMER;
  }

  Future<String> sendSpecialistRequest(
      {required String name,
      required String email,
      required String category,
      required String bio,
      required String password}) async {
    final currentTimeZone =
        (await FlutterTimezone.getLocalTimezone()).identifier;
    final userModel = UserModel(
      id: _userCollectionRef.doc().id,
      userName: name,
      email: email,
      type: UserType.SPECIALIST,
      profileUrl: '',
      uId: '',
      isAuthenticated: true,
      specialist: Specialist(
        status: SpecialistStatus.enabled,
        statusMessage: 'Approved',
        professionalName: name,
        email: email,
        bio: bio,
        category: SpecialistCategory.values.byName(category),
      ),
      availability: Availability(
        defaultFrom: const TimeOfDay(hour: 09, minute: 0),
        defaultTo: const TimeOfDay(hour: 18, minute: 0),
        timeZone: currentTimeZone,
        days: const [],
      ),
    );

    print(userModel.toJson());
    // Avoid pre-signup Firestore query here because anonymous/unauthorized reads
    // can be blocked by rules. Firebase Auth already validates duplicate emails.
    try {
      final user = await _authService.createUserWithEmailAndPassword(
        email,
        password,
      );
      final specialistModel = userModel.copyWith(
        id: user.uid,
        uId: user.uid,
      );
      try {
        await _userCollectionRef
            .doc(specialistModel.email)
            .set(specialistModel.toJson());
      } catch (e) {
        debugPrint('Firestore specialist save failed: $e');
        try {
          await user.delete();
        } catch (_) {}
        return 'Error in Request submission . Try again later!';
      }
      await _prefManager.saveUserModelInPref(specialistModel);
      notifyListeners();
      return 'Request submitted successfully!';
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        return 'User already exists with provided email';
      }
      debugPrint('error in consultant signup auth: ${e.toString()}');
      return 'Error in Request submission . Try again later!';
    } catch (e) {
      debugPrint('error in consultant signup: ${e.toString()}');
      return 'Error in Request submission . Try again later!';
    }
  }

  String getPlaceHolderName(String name) {
    final words = name.split(' ');
    if (words.length == 1) return words.first;
    if (words.length > 1) return words.first + words[1];
    return name;
  }

  Future<List<UserModel>> getAllSpecialistUsers() async {
    final querySnapshots = await _userCollectionRef
        .where('type', isEqualTo: UserType.SPECIALIST.name)
        .get();
    _specialistsList.clear();

    for (final element in querySnapshots.docs) {
      final data = element.data();
      debugPrint('Raw data from Firestore: $data');

      final model = UserModel.fromJson(data);

      debugPrint('Parsed specialist user: ${model.toJson()}');

      _specialistsList.add(model);
    }
    return _specialistsList;
  }

  List<UserModel> getSpecialistsByCat({required String catName}) {
    if (catName.toLowerCase() == 'all') {
      return _specialistsList;
    } else {
      return _specialistsList
          .where((element) => element.specialist != null)
          .where((element) => element.specialist!.category.name == catName)
          .toList();
    }
  }

  Future<void> logoutUser() async {
    try {
      await FirebaseAuth.instance.signOut();
      await _prefManager.deleteUser();
      _userStreamEmail = null;
      _userStream = null;
      _specialistsList.clear();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      e.logError();
      _isLoading = false;
      notifyListeners();
    }
  }

  void setCategory(String cat) {
    _selectedCat = cat;
    notifyListeners();
  }

  String getSelectedCat() {
    return _selectedCat;
  }

}
