// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'you can reconfigure this by running the FlutterFire CLI again.',
      );
    }
    // ignore: missing_enum_constant_in_switch
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
    }

    throw UnsupportedError(
      'DefaultFirebaseOptions are not supported for this platform.',
    );
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCSEbw64-hz0V3RrMYSY2tXG2BCUCw_5p4',
    appId: '1:374256029252:android:d199221591d07eb85e7611',
    messagingSenderId: '374256029252',
    projectId: 'guardian-app-dev',
    storageBucket: 'guardian-app-dev.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDvJyxd2Ao-DCYTb7imy7bUgP30SL0qXuA',
    appId: '1:374256029252:ios:ed065bb3118109365e7611',
    messagingSenderId: '374256029252',
    projectId: 'guardian-app-dev',
    storageBucket: 'guardian-app-dev.appspot.com',
    iosClientId: '374256029252-icd3l6377cgbi8ri6fsdmjfck6jte3rm.apps.googleusercontent.com',
    iosBundleId: 'com.milewski.guardian',
  );
}