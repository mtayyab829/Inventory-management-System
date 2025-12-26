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
    apiKey: "AIzaSyA80JvPBiMxs3jIfEiIEJpXNyu7wThSXb8",
    authDomain: "inventory-management-app-11a90.firebaseapp.com",
    projectId: "inventory-management-app-11a90",
    storageBucket: "inventory-management-app-11a90.firebasestorage.app",
    messagingSenderId: "65165469986",
    appId: "1:65165469986:web:c89a272605fdcc2b22dd7b",
    measurementId: "G-5NQ0PXJ4NE",
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: "AIzaSyA80JvPBiMxs3jIfEiIEJpXNyu7wThSXb8",
    authDomain: "inventory-management-app-11a90.firebaseapp.com",
    projectId: "inventory-management-app-11a90",
    storageBucket: "inventory-management-app-11a90.firebasestorage.app",
    messagingSenderId: "65165469986",
    appId: "1:65165469986:android:c89a272605fdcc2b22dd7b",
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'demo-key-for-university-project',
    appId: '1:demo:ios:demo',
    messagingSenderId: 'demo',
    projectId: 'inventory-management-demo',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'demo-key-for-university-project',
    appId: '1:demo:macos:demo',
    messagingSenderId: 'demo',
    projectId: 'inventory-management-demo',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'demo-key-for-university-project',
    appId: '1:demo:windows:demo',
    messagingSenderId: 'demo',
    projectId: 'inventory-management-demo',
  );
}
