import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:login_page/screens/login_screen.dart';
import 'package:login_page/widgets/error_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  final User _user = FirebaseAuth.instance.currentUser!;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  String? _errorMessage; // State variable for error messages

  /// Signs the user out and navigates to the login screen
  Future<void> signUserOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      await _googleSignIn.signOut();

      if (!mounted) return; // Check if the widget is still mounted

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
            (Route<dynamic> route) => false,
      );
    } on FirebaseAuthException catch (e) {
      _errorMessage = e.code;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            onPressed: () => signUserOut(), // Call the function
            icon: const Icon(Icons.logout),
            tooltip: 'Sign Out',
          ),
        ],
      ),
      body: Center(
        child: Column(
          children: [
            Text(
              "LOGGED IN AS: ${_user.displayName!}",
              style: const TextStyle(fontSize: 18),
            ),

            if (_errorMessage != null) ...[
              const SizedBox(height: 20),
              buildErrorMessage(_errorMessage!), // Use the error message function
            ],
          ],
        ),
      ),
    );
  }
}
