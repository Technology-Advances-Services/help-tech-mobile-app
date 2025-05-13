import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
              'you can reconfigure this by running the FlutterFire CLI again.'
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
              'you can reconfigure this by running the FlutterFire CLI again.'
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
              'you can reconfigure this by running the FlutterFire CLI again.'
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.'
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyD0M6iBW-6i_DycAi532rfFe362pX4i2Xg',
    appId: '1:562711702986:web:e67ab10da4ca9de157f333',
    messagingSenderId: '180154492305',
    projectId: 'helptech-74d24',
    authDomain: 'helptech-74d24.firebaseapp.com',
    storageBucket: 'helptech-74d24.appspot.com'
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBglH78QsbP3A4YhEpYQaHZC-4i7v6fM9U',
    appId: '1:562711702986:android:3388c076890b5ced57f333',
    messagingSenderId: '562711702986',
    projectId: 'helptech-74d24',
    storageBucket: 'helptech-74d24.appspot.com'
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCQFhFi3TOa4yfIR_deksSFwYgznynd7zc',
    appId: '1:562711702986:ios:12772f2f3b3b725f57f333',
    messagingSenderId: '562711702986',
    projectId: 'helptech-74d24',
    storageBucket: 'helptech-74d24.appspot.com',
    iosBundleId: 'com.helptech.helptechmobileapp'
  );
}