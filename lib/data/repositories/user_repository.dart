import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:horti_vige/core/exceptions/app_exception.dart';
import 'package:horti_vige/data/database/collection_refs.dart';
import 'package:horti_vige/data/models/user/user_model.dart';

class UserRepository {
  UserRepository._();

  /// [Users/{userId}] rules require `request.auth.token.email == userId`. The
  /// JWT email is normalized; prefs may still hold a different casing — always
  /// use the signed-in account when writing the current user's document.
  static String _docIdForCurrentUser(UserModel user) {
    final authEmail = FirebaseAuth.instance.currentUser?.email;
    if (authEmail != null && authEmail.isNotEmpty) {
      return authEmail;
    }
    return user.email;
  }

  /// Firestore `set(merge: true)` **deletes** a field when the payload contains
  /// an explicit `null`. [json_serializable] emits nulls for missing optionals,
  /// which was wiping `specialist` / `consultationPricing` and blocking reliable
  /// `availability` updates.
  static Map<String, dynamic> _jsonWithoutNullValues(Map<String, dynamic> json) {
    dynamic strip(dynamic value) {
      if (value == null) return null;
      if (value is Map) {
        final m = <String, dynamic>{};
        for (final e in value.entries) {
          final s = strip(e.value);
          if (s != null) {
            m[e.key as String] = s;
          }
        }
        return m;
      }
      if (value is List) {
        return value.map(strip).toList();
      }
      return value;
    }

    final out = <String, dynamic>{};
    for (final e in json.entries) {
      final s = strip(e.value);
      if (s != null) {
        out[e.key] = s;
      }
    }
    return out;
  }

  /// Prefer local cache when present so login / refresh does not wait on a
  /// slow or flaky link to Firestore (see SDK log: backend didn’t respond in 10s).
  static Future<UserModel?> get(String email) async {
    final ref = CollectionRefs.users.doc(email);
    try {
      final cached = await ref.get(const GetOptions(source: Source.cache));
      if (cached.exists && cached.data() != null) {
        return UserModel.fromJson(cached.data()!);
      }
    } on FirebaseException catch (_) {
      // Cache miss or unavailable; fall through to server.
    }
    try {
      final user =
          await ref.get(const GetOptions(source: Source.server));
      if (!user.exists || user.data() == null) return null;
      return UserModel.fromJson(user.data()!);
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        throw AppException(
          title: 'Firestore access denied',
          message:
              'Your account can’t read the user profile in Firestore (security '
              'rules). In Firebase Console → Firestore → Rules, allow signed-in '
              'users to read/write their own document in `Users/{email}`, or '
              'confirm this app uses the same Firebase project as your data.',
        );
      }
      throw AppException(
        title: 'Getting user data failed',
        message: e.message ?? 'Something went wrong',
      );
    } catch (e) {
      throw AppException(
        title: 'Getting user data failed',
        message: e.toString(),
      );
    }
  }

  static Stream<UserModel> getUserStream(String email) {
    try {
      return CollectionRefs.users
          .doc(email)
          .snapshots()
          .map((event) => UserModel.fromJson(event.data()!));
    } on FirebaseException catch (e) {
      throw AppException(
        title: 'Getting user data failed',
        message: e.message ?? 'Something went wrong',
      );
    }
  }

  static Future<void> saveFCMToken(String email, String fcmToken) async {
    try {
      final docId = FirebaseAuth.instance.currentUser?.email ?? email;
      await CollectionRefs.users.doc(docId).update({
        'fcmToken': fcmToken,
      });
    } on FirebaseException catch (e) {
      throw AppException(
        message: e.message ?? '',
        title: 'Error deleting user',
      );
    }
  }

  static Future<void> updateUser(UserModel user) async {
    try {
      final docId = _docIdForCurrentUser(user);
      // `update` fails with NOT_FOUND if the document was never created; merge
      // write matches typical “upsert profile” behavior and persists nested
      // fields like [consultationPricing] reliably.
      final raw = user.email == docId
          ? user.toJson()
          : user.copyWith(email: docId).toJson();
      final payload = _jsonWithoutNullValues(raw);
      await CollectionRefs.users
          .doc(docId)
          .set(payload, SetOptions(merge: true));
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        throw AppException(
          title: 'Firestore access denied',
          message:
              'Saving your profile was blocked by Firestore security rules. '
              'Update rules for `Users/{email}` or use the correct Firebase project.',
        );
      }
      throw AppException(
        message: e.message ?? '',
        title: 'Error updating user',
      );
    }
  }

  static Future<void> createUser(UserModel user) async {
    try {
      final docId = _docIdForCurrentUser(user);
      final payload = user.email == docId
          ? user.toJson()
          : user.copyWith(email: docId).toJson();
      await CollectionRefs.users.doc(docId).set(payload);
    } on FirebaseException catch (e) {
      throw AppException(
        message: e.message ?? '',
        title: 'Error creating user',
      );
    }
  }
}
