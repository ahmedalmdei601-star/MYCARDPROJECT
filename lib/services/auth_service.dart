import 'package:firebase_auth/firebase_auth.dart';
import 'user_services.dart';
import '../models/user_model.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final UserService _userService = UserService();

  // Helper to convert phone or identifier to a valid email format for Firebase Auth
  static String _identifierToEmail(String identifier) {
    identifier = identifier.trim();
    if (identifier.contains('@')) {
      return identifier;
    }
    // If it's just a phone number or digits, convert to a clean dummy email
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
    try {
      final email = _identifierToEmail(identifier);
      final cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (cred.user != null) {
        await _userService.updateLastLogin(cred.user!.uid);
      }
      return cred.user;
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'خطأ في تسجيل الدخول.';
      if (e.code == 'user-not-found' || e.code == 'wrong-password' || e.code == 'invalid-credential') {
        errorMessage = 'اسم المستخدم أو كلمة المرور غير صحيحة.';
      } else if (e.code == 'too-many-requests') {
        errorMessage = 'تم حظر المحاولات مؤقتاً. حاول لاحقاً.';
      }
      throw Exception(errorMessage);
    } catch (e) {
      throw Exception('حدث خطأ غير متوقع: $e');
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
