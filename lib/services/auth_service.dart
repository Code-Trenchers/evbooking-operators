import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:evbooking_operators/services/logger_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<User?> gmailLogin() async {
    LoggerService.info('Attempting Gmail login');

    try {
      await _googleSignIn.signOut();
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        LoggerService.info('Google sign-in cancelled by user');
        return null;
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      return await signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      LoggerService.error('Firebase Auth Exception during Gmail login', e);
      return null;
    }
  }

  Future<User?> signIn(String email, String password) async {
    try {
      LoggerService.info('Attempting to sign in user with email: $email');
      UserCredential result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      LoggerService.info('User signed in successfully: ${result.user?.uid}');
      return result.user;
    } catch (e) {
      LoggerService.error('Error signing in', e);
      return null;
    }
  }

  Future<User?> signInWithCredential(AuthCredential credential) async {
    try {
      LoggerService.info('Attempting to sign in with credential');
      UserCredential result = await _auth.signInWithCredential(credential);
      LoggerService.info('User signed in successfully: ${result.user?.uid}');
      return result.user;
    } catch (e) {
      LoggerService.error('Error signing in with credential', e);
      return null;
    }
  }

  Future<void> signOut() async {
    try {
      LoggerService.info('Attempting to sign out user');
      await _auth.signOut();
      await _googleSignIn.signOut();
      LoggerService.info('User signed out successfully');
    } catch (e) {
      LoggerService.error('Error signing out', e);
    }
  }

  // Get current user
  User? get currentUser => _auth.currentUser;

  Future<User?> getCurrentUser() async {
    return _auth.currentUser;
  }
}
