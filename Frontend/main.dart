import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'auth/screen/googel_login_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MaterialApp(home: GoogleLoginScreen()));
}

