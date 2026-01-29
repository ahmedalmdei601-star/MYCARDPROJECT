import 'package:firebase_auth/firebase_auth.dart';
import 'user_services.dart';
import '../models/user_model.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final UserService _userService = UserService();

  // Helper to convert phone to a valid email format for Firebase Auth
  static String _identifierToEmail(String identifier) {
    if (identifier.contains('@')) {
      return identifier.trim();
    }
    // If it's just a phone number or digits, convert to dummy email
    return '${identifier.trim()}@mycardproject.app';
  }

  // Admin-only function to create client accounts
  static Future<User?> createClientAccount({
    required String phone,
    required String password,
    required String name,
  }) async {
    try {
      // Create user in Firebase Auth
      final UserCredential cred = await _auth.createUserWithEmailAndPassword(
        email: _identifierToEmail(phone),
        password: password,
      );

      if (cred.user != null) {
        // Create user document in Firestore
        await _userService.createUser(UserModel(
          id: cred.user!.uid,
          name: name,
          phone: phone,
          role: 'client', // Always create as 'client'
        ));
        return cred.user;
      }
    } on FirebaseAuthException catch (e) {
      print('Error creating client account: ${e.message}');
      rethrow;
    }
    return null;
  }

  // Login for all users (supports phone or email)
  static Future<User?> login(
    String identifier,
    String password,
  ) async {
    try {
      final email = _identifierToEmail(identifier);
      final cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return cred.user;
    } on FirebaseAuthException catch (e) {
      print('Login Error: ${e.code} - ${e.message}');
      rethrow;
    }
  }

  // Function for users to change their own password
  static Future<void> changePassword(String newPassword) async {
    User? user = _auth.currentUser;
    if (user != null) {
      await user.updatePassword(newPassword);
    } else {
      throw Exception('No authenticated user found.');
    }
  }

  // Sign out
  static Future<void> signOut() async {
    await _auth.signOut();
  }

  // Get current authenticated user
  static User? get currentUser => _auth.currentUser;
}
