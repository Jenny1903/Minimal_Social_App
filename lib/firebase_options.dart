import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBBlAaLFe_Sin4lGGnnM9_pEGkvM_oREUM',
    appId: '1:138399341757:android:64c216dbd5f6dcdaa26bd4',
    messagingSenderId: '138399341757',
    projectId: 'minimal-social-app-5b609',
    storageBucket: 'minimal-social-app-5b609.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAja5T2vWugYr9JR2omlet5iTXqe3pK8Ho',
    appId: '1:138399341757:ios:18dfae38d9994a7ea26bd4',
    messagingSenderId: '138399341757',
    projectId: 'minimal-social-app-5b609',
    storageBucket: 'minimal-social-app-5b609.firebasestorage.app',
    iosBundleId: 'com.minimalsocial.socialApp',
  );

}