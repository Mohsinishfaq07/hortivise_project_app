// Developed By Muhammad Waleed.. Senior Android and Flutter developer..
// waleedkalyar48@gmail.com/

import 'dart:convert';
import 'package:horti_vige/data/models/user/user_model.dart';
import 'package:horti_vige/ui/utils/extensions/extensions.dart';
import 'package:horti_vige/core/utils/app_consts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferenceManager {
  PreferenceManager._();

  late SharedPreferences _prefs;
  static final PreferenceManager _instance = PreferenceManager._();

  static PreferenceManager getInstance() {
    return _instance;
  }

  Future<void> initSharedPreferences() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<void> deleteUser() async {
    await _prefs.remove(Constants.userModel);
  }

  UserModel? getCurrentUser() {
    final userString = _prefs.getString(Constants.userModel);
    if (userString == null) {
      return null;
    } else {
      final Map<String, dynamic> user = jsonDecode(userString);

      final model = UserModel.fromJson(user);
      return model;
    }
  }

  Future<void> saveUserModelInPref(UserModel? userModel) async {
    try {
      await _prefs.setString(
        Constants.userModel,
        jsonEncode(userModel!.toJson()),
      );
    } catch (e) {
      e.logError();
    }
  }
}
