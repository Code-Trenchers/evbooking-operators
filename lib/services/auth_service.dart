import 'package:evBookingOperators/services/logger_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

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
