import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:evBookingOperators/screens/home_screen.dart';
import 'package:evBookingOperators/services/auth_service.dart';
import 'package:evBookingOperators/widgets/button_widget.dart';
import 'package:evBookingOperators/widgets/error_widget.dart';
import 'package:evBookingOperators/widgets/text_field_widget.dart';
import 'package:evBookingOperators/widgets/square_tile_widget.dart';
import 'package:evBookingOperators/services/logger_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  bool _obscureText = true;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> gmailLogin() async {
    _showLoadingIndicator();
    LoggerService.info('Attempting Gmail login');

    try {
      await _googleSignIn.signOut();
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        LoggerService.info('Google sign-in cancelled by user');
        return;
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final User? user = await _authService.signInWithCredential(credential);

      if (!mounted) return;
      Navigator.pop(context);

      if (user != null && user.email!.endsWith('@bitsathy.ac.in')) {
        LoggerService.info('User logged in successfully: ${user.email}');
        _navigateToHomePage();
      } else {
        LoggerService.warning('Login attempt with non-Bitsathy email');
        await _authService.signOut();
        await _googleSignIn.signOut();
        if (!mounted) return;
        setState(() {
          _errorMessage = 'Sign in restricted to Bitsathy domain';
        });
      }
    } on FirebaseAuthException catch (e) {
      LoggerService.error('Firebase Auth Exception during Gmail login', e);
      Navigator.pop(context);
      setState(() {
        _errorMessage = e.code;
      });
    }
  }

  void signUserIn() async {
    _showLoadingIndicator();
    LoggerService.info('Attempting user sign in');

    try {
      final String email = _emailController.text;
      final String password = _passwordController.text;
      final User? user = await _authService.signIn(email, password);

      if (!mounted) return;

      Navigator.pop(context);
      if (user != null) {
        LoggerService.info('User signed in successfully: ${user.email}');
        _navigateToHomePage();
      } else {
        LoggerService.warning('Sign in failed: No user returned');
      }
    } on FirebaseAuthException catch (e) {
      LoggerService.error('Firebase Auth Exception during sign in', e);
      Navigator.pop(context);
      setState(() {
        _errorMessage = e.code;
      });
    }
  }

  void _navigateToHomePage() {
    _googleSignIn.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );
  }

  void _showLoadingIndicator() {
    showDialog(
      context: context,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 50),
                const Icon(
                  Icons.lock,
                  size: 100,
                ),
                const SizedBox(height: 50),
                Text(
                  'Welcome back you\'ve been missed!',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 25),
                MyTextField(
                  controller: _emailController,
                  hintText: 'Email',
                  obscureText: false,
                ),
                const SizedBox(height: 10),
                MyTextField(
                  controller: _passwordController,
                  hintText: 'Password',
                  obscureText: _obscureText,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'Forgot Password?',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 25),
                MyButton(
                  onTap: signUserIn,
                ),
                if (_errorMessage != null) ...[
                  const SizedBox(height: 20),
                  buildErrorMessage(_errorMessage!),
                ],
                const SizedBox(height: 50),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Divider(
                          thickness: 0.5,
                          color: Colors.grey[400],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Text(
                          'Sign in only using your bitsathy mail id',
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          thickness: 0.5,
                          color: Colors.grey[400],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 50),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: gmailLogin,
                      child:
                          const SquareTile(imagePath: 'lib/images/google.png'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
