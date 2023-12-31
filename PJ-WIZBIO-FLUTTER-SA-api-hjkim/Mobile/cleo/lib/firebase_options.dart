// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
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
    apiKey: 'AIzaSyCwMevWUd939SY408j8NezMBBVf0wPAGMw',
    appId: '1:786471741908:web:a164833d85cf6e0dd1ce41',
    messagingSenderId: '786471741908',
    projectId: 'cleo-one-c614e',
    authDomain: 'cleo-one-c614e.firebaseapp.com',
    storageBucket: 'cleo-one-c614e.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAaYtN-J5QufOpTwdFeN_ojNUviLkQN-Sc',
    appId: '1:786471741908:android:b5987ad24780f4f6d1ce41',
    messagingSenderId: '786471741908',
    projectId: 'cleo-one-c614e',
    storageBucket: 'cleo-one-c614e.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyD662ipew0l0Pq-GQOejlFiWjsEyKory5g',
    appId: '1:786471741908:ios:9e664cec740621c9d1ce41',
    messagingSenderId: '786471741908',
    projectId: 'cleo-one-c614e',
    storageBucket: 'cleo-one-c614e.appspot.com',
    androidClientId: '786471741908-ngtoptm94qos0o0ud2cfior6551emdl8.apps.googleusercontent.com',
    iosClientId: '786471741908-84450j70sfhcj2h5jj8tp86ar505n42c.apps.googleusercontent.com',
    iosBundleId: 'com.cleo.wizbio',
  );
}
