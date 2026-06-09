import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:horti_vige/data/models/availability/availability.dart';
import 'package:horti_vige/data/models/user/user_model.dart';
import 'package:horti_vige/providers/user_provider.dart';

class AvailabilityProvider with ChangeNotifier {
  AvailabilityProvider({required this.userProvider});
  final UserProvider userProvider;

  Availability _availability = Availability.empty();

  /// Keeps [defaultFrom]/[defaultTo] in sync and notifies so day rows and
  /// dropdowns rebuild when availability changes.
  Availability get availability => _availability;
  set availability(Availability value) {
    _availability = value;
    defaultFrom = value.defaultFrom;
    defaultTo = value.defaultTo;
    notifyListeners();
  }

  UserModel? user;

  TimeOfDay defaultFrom = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay defaultTo = const TimeOfDay(hour: 18, minute: 0);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  /// First open used to `await` a Firestore write here, so the screen stayed on
  /// the spinner until the network returned — felt like a slow "fetch". Persist
  /// defaults in the background instead; UI reads from prefs only.
  Future<void> init() async {
    _isLoading = true;
    notifyListeners();
    try {
      user = userProvider.getCurrentUser();

      if (user == null) {
        return;
      }

      if (user!.availability != null) {
        availability = user!.availability!;
      } else {
        final timeZone =
            (await FlutterTimezone.getLocalTimezone()).identifier;
        availability = Availability(
          defaultFrom: defaultFrom,
          defaultTo: defaultTo,
          timeZone: timeZone,
          days: [],
        );
        unawaited(_persistDefaultAvailability());
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _persistDefaultAvailability() async {
    final u = user;
    if (u == null) return;
    await userProvider.updateUser(
      model: u.copyWith(availability: availability),
      silent: true,
    );
  }
}
