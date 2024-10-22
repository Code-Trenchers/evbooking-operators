import 'package:flutter/material.dart';
import 'package:evBookingOperators/screens/home_screen.dart';
import 'package:evBookingOperators/services/logger_service.dart';
import 'package:evBookingOperators/screens/login_screen.dart';
import 'package:evBookingOperators/services/auth_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  LoggerService.info('Initializing Firebase');
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  LoggerService.info('Firebase initialized successfully');
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final AuthService authService = AuthService();
  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FutureBuilder(
        future: authService.getCurrentUser(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else if (snapshot.hasData) {
            return const HomeScreen();
          } else {
            return const LoginScreen();
          }
        },
      ),
    );
  }
}
