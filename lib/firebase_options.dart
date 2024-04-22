import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Default [FirebaseOptions] for use with your Firebase apps.
/// firebase
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
final webKey = dotenv.env['WEBAPI_KEY'] ?? "";
final androidKey = dotenv.env['ANDROIDAPI_KEY'] ?? "";
final iosKey = dotenv.env['IOSAPI_KEY'] ?? "";

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

  static FirebaseOptions web = FirebaseOptions(
    apiKey: webKey,
    appId: '1:407173202142:web:e25b270440389f142a424f',
    messagingSenderId: '407173202142',
    projectId: 'viblify',
    authDomain: 'viblify.firebaseapp.com',
    storageBucket: 'viblify.appspot.com',
    measurementId: 'G-K8WS42818Z',
  );

  static FirebaseOptions android = FirebaseOptions(
    apiKey: androidKey,
    appId: '1:407173202142:android:44631f6984852c442a424f',
    messagingSenderId: '407173202142',
    projectId: 'viblify',
    storageBucket: 'viblify.appspot.com',
  );

  static FirebaseOptions ios = FirebaseOptions(
    apiKey: iosKey,
    appId: '1:407173202142:ios:8dabfeaa669c19a02a424f',
    messagingSenderId: '407173202142',
    projectId: 'viblify',
    storageBucket: 'viblify.appspot.com',
    iosBundleId: 'com.example.viblifyApp',
  );
}
