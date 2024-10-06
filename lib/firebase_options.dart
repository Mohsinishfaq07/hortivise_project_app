// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCHm6elP6VJtSwdHSE79Nq4vccgrwwFssg',
    appId: '1:157879166051:web:807f71987ffe7f9c280456',
    messagingSenderId: '157879166051',
    projectId: 'hortivige',
    authDomain: 'hortivige.firebaseapp.com',
    storageBucket: 'hortivige.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAU4QQmln4BYNl6Vs-kOdHLmlvimI5wfGw',
    appId: '1:157879166051:android:e8bd9320dad4a8c5280456',
    messagingSenderId: '157879166051',
    projectId: 'hortivige',
    storageBucket: 'hortivige.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDR8LubOQCRg6crPbXgZ8zLU-36F1yQjKo',
    appId: '1:157879166051:ios:a3d84115fc739371280456',
    messagingSenderId: '157879166051',
    projectId: 'hortivige',
    storageBucket: 'hortivige.appspot.com',
    iosClientId:
        '157879166051-jk3sb9iilpktefa8km08h04sh7nulnbd.apps.googleusercontent.com',
    iosBundleId: 'com.minimalmouse.hortivige.hortiVige',
  );
}
