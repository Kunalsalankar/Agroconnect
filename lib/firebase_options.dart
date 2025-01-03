// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
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
        return windows;
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
    apiKey: 'AIzaSyBTbw_aBSF51bAtyhhu56AUJMh2sWKetw8',
    appId: '1:544534557483:web:3a4d6abcddc930a9850b6e',
    messagingSenderId: '544534557483',
    projectId: 'timepass-dad79',
    authDomain: 'timepass-dad79.firebaseapp.com',
    storageBucket: 'timepass-dad79.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBx5F_u3xReuvU56_IxQabJg9vizCiztTw',
    appId: '1:544534557483:android:d3853297eefad66e850b6e',
    messagingSenderId: '544534557483',
    projectId: 'timepass-dad79',
    storageBucket: 'timepass-dad79.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCWEZrvEV_LdPxGMrgt3Xf4Tk-sZ07SY9k',
    appId: '1:544534557483:ios:3479d880a535f5d8850b6e',
    messagingSenderId: '544534557483',
    projectId: 'timepass-dad79',
    storageBucket: 'timepass-dad79.appspot.com',
    iosBundleId: 'com.example.googlemerr',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCWEZrvEV_LdPxGMrgt3Xf4Tk-sZ07SY9k',
    appId: '1:544534557483:ios:3479d880a535f5d8850b6e',
    messagingSenderId: '544534557483',
    projectId: 'timepass-dad79',
    storageBucket: 'timepass-dad79.appspot.com',
    iosBundleId: 'com.example.googlemerr',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBTbw_aBSF51bAtyhhu56AUJMh2sWKetw8',
    appId: '1:544534557483:web:202e8e578d2a5d9b850b6e',
    messagingSenderId: '544534557483',
    projectId: 'timepass-dad79',
    authDomain: 'timepass-dad79.firebaseapp.com',
    storageBucket: 'timepass-dad79.appspot.com',
  );
}
