

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBZuhqzxazoep5AyFjztNUXjWEXhOLjcQ4',
    appId: '1:71088167133:android:cc826e5477390c5005e334',
    messagingSenderId: '71088167133',
    projectId: 'castflow-5ce2b',
    storageBucket: 'castflow-5ce2b.firebasestorage.app',
  );
}
