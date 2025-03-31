import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default Firebase configuration options for the current platform
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

  // Note: These are placeholder values. You should replace them with your actual Firebase configuration
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAgUhHU8wSJgO5MVNy95tMT07NEjzMOfz0',
    appId: '1:448618578101:web:a8ebc6ab8b9c4da3',
    messagingSenderId: '448618578101',
    projectId: 'bond-app-dev',
    authDomain: 'bond-app-dev.firebaseapp.com',
    storageBucket: 'bond-app-dev.appspot.com',
    measurementId: 'G-MEASUREMENT_ID',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAgUhHU8wSJgO5MVNy95tMT07NEjzMOfz0',
    appId: '1:448618578101:android:a8ebc6ab8b9c4da3',
    messagingSenderId: '448618578101',
    projectId: 'bond-app-dev',
    storageBucket: 'bond-app-dev.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAgUhHU8wSJgO5MVNy95tMT07NEjzMOfz0',
    appId: '1:448618578101:ios:a8ebc6ab8b9c4da3',
    messagingSenderId: '448618578101',
    projectId: 'bond-app-dev',
    storageBucket: 'bond-app-dev.appspot.com',
    iosClientId: '448618578101-a8ebc6ab8b9c4da3.apps.googleusercontent.com',
    iosBundleId: 'com.example.freshBondApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAgUhHU8wSJgO5MVNy95tMT07NEjzMOfz0',
    appId: '1:448618578101:ios:a8ebc6ab8b9c4da3',
    messagingSenderId: '448618578101',
    projectId: 'bond-app-dev',
    storageBucket: 'bond-app-dev.appspot.com',
    iosClientId: '448618578101-a8ebc6ab8b9c4da3.apps.googleusercontent.com',
    iosBundleId: 'com.bond.app',
  );
}
