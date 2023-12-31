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
    apiKey: 'AIzaSyD2VM9dF6puS4wz0iRvcogYBuORV7abEmo',
    appId: '1:889692207830:web:a139bd09b046818533a777',
    messagingSenderId: '889692207830',
    projectId: 'mineria-95bea',
    authDomain: 'mineria-95bea.firebaseapp.com',
    storageBucket: 'mineria-95bea.appspot.com',
    measurementId: 'G-NRHE2650XW',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDGcuIZZpadxL5qyOH4NK1yOA5uqthr0C0',
    appId: '1:889692207830:android:75ca7693b134e99033a777',
    messagingSenderId: '889692207830',
    projectId: 'mineria-95bea',
    storageBucket: 'mineria-95bea.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDYkiSiPpK55Ne7weG3sdnYwkGwJTwJRjc',
    appId: '1:889692207830:ios:2ec03f033d73e6fa33a777',
    messagingSenderId: '889692207830',
    projectId: 'mineria-95bea',
    storageBucket: 'mineria-95bea.appspot.com',
    iosClientId: '889692207830-24vc6rgrg33fbfj8t8tbucno3rmr1t2j.apps.googleusercontent.com',
    iosBundleId: 'com.example.ejemplo',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDYkiSiPpK55Ne7weG3sdnYwkGwJTwJRjc',
    appId: '1:889692207830:ios:139b6e248492694d33a777',
    messagingSenderId: '889692207830',
    projectId: 'mineria-95bea',
    storageBucket: 'mineria-95bea.appspot.com',
    iosClientId: '889692207830-47h9l5ba6u6t1jg1gpcui35tgbbuvtiu.apps.googleusercontent.com',
    iosBundleId: 'com.example.ejemplo.RunnerTests',
  );
}
