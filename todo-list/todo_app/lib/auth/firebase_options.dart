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
        return macos;
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
    apiKey: 'AIzaSyCU2mqJme8TG8ejyATv12A9JbUsyPouT4s',
    appId: '1:705130551844:web:eb2d514139703d3ae456b1',
    messagingSenderId: '705130551844',
    projectId: 'buddybuddy-96544',
    authDomain: 'buddybuddy-96544.firebaseapp.com',
    storageBucket: 'buddybuddy-96544.appspot.com',
    measurementId: 'G-M8K9SM4L8W',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDZ9aR85IKtUabgEdyYqrU-faVbFOfDo1g',
    appId: '1:705130551844:android:ebfae13d71b59b2be456b1',
    messagingSenderId: '705130551844',
    projectId: 'buddybuddy-96544',
    storageBucket: 'buddybuddy-96544.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCDneyj1wWTnz5W2AfIO2Uea6KfTruEL5I',
    appId: '1:705130551844:ios:c3bda9c29271eaafe456b1',
    messagingSenderId: '705130551844',
    projectId: 'buddybuddy-96544',
    storageBucket: 'buddybuddy-96544.appspot.com',
    iosClientId: '705130551844-9m4pbhsc7q5l8b5qf6k582b5pg5l1gvi.apps.googleusercontent.com',
    iosBundleId: 'com.example.todoApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCDneyj1wWTnz5W2AfIO2Uea6KfTruEL5I',
    appId: '1:705130551844:ios:00bd4ed879a82080e456b1',
    messagingSenderId: '705130551844',
    projectId: 'buddybuddy-96544',
    storageBucket: 'buddybuddy-96544.appspot.com',
    iosClientId: '705130551844-6p412sihuabjik8nv35ql509reiuds45.apps.googleusercontent.com',
    iosBundleId: 'com.example.todoApp.RunnerTests',
  );
}
