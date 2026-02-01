import 'package:firebase_auth/firebase_auth.dart';
import 'user_services.dart';
import '../models/user_model.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final UserService _userService = UserService();

  // Helper to convert phone or identifier to a valid email format for Firebase Auth
  // This logic is only used for creating NEW accounts. 
  // For login, we will try the identifier as-is first, then try the dummy email format.
  static String _identifierToEmail(String identifier) {
    identifier = identifier.trim();
    if (identifier.contains('@')) {
      return identifier;
    }
    return '$identifier@mycard.com';
  }

  // Admin-only function to create client accounts
  static Future<User?> createClientAccount({
    required String phone,
    required String password,
    required String name,
  }) async {
    try {
      final email = _identifierToEmail(phone);
      final UserCredential cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (cred.user != null) {
        await _userService.createUser(UserModel(
          id: cred.user!.uid,
          name: name,
          phone: phone,
          role: 'client',
          createdAt: DateTime.now(),
        ));
        return cred.user;
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'خطأ في إنشاء الحساب.';
      if (e.code == 'email-already-in-use') {
        errorMessage = 'رقم الهاتف أو الحساب مسجل بالفعل.';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'صيغة الحساب غير صحيحة.';
      } else if (e.code == 'weak-password') {
        errorMessage = 'كلمة المرور ضعيفة جداً.';
      }
      throw Exception(errorMessage);
    } catch (e) {
      throw Exception('حدث خطأ غير متوقع: $e');
    }
    return null;
  }

  // Login for all users
  static Future<User?> login(String identifier, String password) async {
    identifier = identifier.trim();
    
    try {
      // 1. Try signing in with the identifier as-is (for users with real emails or old formats)
      try {
        final cred = await _auth.signInWithEmailAndPassword(
          email: identifier.contains('@') ? identifier : _identifierToEmail(identifier),
          password: password,
        );
        if (cred.user != null) {
          // Attempt to update last login, but don't fail the whole login if this background task fails
          _userService.updateLastLogin(cred.user!.uid).catchError((_) => null);
        }
        return cred.user;
      } on FirebaseAuthException catch (e) {
        // If the first attempt fails with 'invalid-email' and it wasn't an email, 
        // it's possible it's an old account format (e.g. just phone as email).
        // However, the current standard is dummy email. 
        // We catch common auth errors here.
        if (e.code == 'user-not-found' || e.code == 'wrong-password' || e.code == 'invalid-credential') {
          throw Exception('اسم المستخدم أو كلمة المرور غير صحيحة.');
        }
        rethrow;
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'خطأ في تسجيل الدخول.';
      if (e.code == 'too-many-requests') {
        errorMessage = 'تم حظر المحاولات مؤقتاً. حاول لاحقاً.';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'صيغة اسم المستخدم غير صحيحة.';
      }
      throw Exception(errorMessage);
    } catch (e) {
      // Catch-all for any other errors, ensuring we don't accidentally hide the real cause
      if (e.toString().contains('Exception:')) rethrow;
      throw Exception('حدث خطأ أثناء الاتصال: $e');
    }
  }

  // Function for users to change their own password
  static Future<void> changePassword(String currentPassword, String newPassword) async {
    User? user = _auth.currentUser;
    if (user != null && user.email != null) {
      try {
        // Re-authenticate user before changing password
        AuthCredential credential = EmailAuthProvider.credential(
          email: user.email!,
          password: currentPassword,
        );
        await user.reauthenticateWithCredential(credential);
        await user.updatePassword(newPassword);
      } on FirebaseAuthException catch (e) {
        String errorMessage = 'فشل تغيير كلمة المرور.';
        if (e.code == 'wrong-password') {
          errorMessage = 'كلمة المرور الحالية غير صحيحة.';
        } else if (e.code == 'weak-password') {
          errorMessage = 'كلمة المرور الجديدة ضعيفة جداً.';
        }
        throw Exception(errorMessage);
      }
    } else {
      throw Exception('لم يتم العثور على جلسة مستخدم نشطة.');
    }
  }

  static Future<void> signOut() async {
    await _auth.signOut();
  }

  static User? get currentUser => _auth.currentUser;
}
