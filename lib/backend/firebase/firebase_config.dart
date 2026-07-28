import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

Future initFirebase() async {
  if (kIsWeb) {
    await Firebase.initializeApp(
        options: FirebaseOptions(
            apiKey: "AIzaSyDlQn7lds13yPKmt95Yu2vX09icvGqTWG8",
            authDomain: "deshmukh-steel-e-r-p-u5tg2l.firebaseapp.com",
            projectId: "deshmukh-steel-e-r-p-u5tg2l",
            storageBucket: "deshmukh-steel-e-r-p-u5tg2l.firebasestorage.app",
            messagingSenderId: "968817385855",
            appId: "1:968817385855:web:aa860003ba46b88c90ba4a"));
  } else {
    await Firebase.initializeApp();
  }
}
