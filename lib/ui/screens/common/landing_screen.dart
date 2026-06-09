import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:horti_vige/core/exceptions/app_exception.dart';
import 'package:horti_vige/core/utils/helpers/preference_manager.dart';
import 'package:horti_vige/data/repositories/user_repository.dart';
import 'package:horti_vige/generated/assets.dart';
import 'package:horti_vige/ui/screens/auth/animated_authenticated_landing.dart';
import 'package:horti_vige/ui/screens/auth/login_screen.dart';
import 'package:horti_vige/ui/widgets/app_nav_drawer.dart';
import 'package:horti_vige/ui/widgets/exit_bottom_sheet.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});
  static String routeName = 'Landing';

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  Future<bool> checkUserAuthState() async {
    final prefs = PreferenceManager.getInstance();
    final authUser = FirebaseAuth.instance.currentUser;

    if (authUser == null) {
      await prefs.deleteUser();
      return false;
    }

    final email = authUser.email;
    if (email == null || email.isEmpty) {
      await prefs.deleteUser();
      await FirebaseAuth.instance.signOut();
      return false;
    }

    final localUser = prefs.getCurrentUser();
    final matches = localUser != null &&
        localUser.email.toLowerCase() == email.toLowerCase();

    if (matches) {
      return true;
    }

    // Signed in with Firebase but prefs missing or another account — refresh.
    try {
      final appUser = await UserRepository.get(email);
      if (appUser == null) {
        await prefs.deleteUser();
        await FirebaseAuth.instance.signOut();
        return false;
      }
      await prefs.saveUserModelInPref(appUser);
      return true;
    } on AppException {
      await prefs.deleteUser();
      await FirebaseAuth.instance.signOut();
      return false;
    } catch (_) {
      await prefs.deleteUser();
      await FirebaseAuth.instance.signOut();
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: checkUserAuthState(),
      builder: (context, snapshot) {
        // Show splash message until Firebase completes checking auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: SvgPicture.asset(
              Assets.assetsImagesBottomLeafs,
              color: const Color.fromARGB(255, 5, 110, 8),
            ),
          );
        }

        // Once Firebase is done loading, navigate based on authentication state
        if (snapshot.data == true) {
          return const AnimatedLandingScreen(); // User is authenticated
        } else {
          return const LoginScreen(); // User is not authenticated
        }
      },
    );
  }
}
