import 'package:firebase_auth/firebase_auth.dart';
import 'user_services.dart';
import '../models/user_model.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final UserService _userService = UserService();

  // ONLY for creating new accounts, we use a standard dummy email format.
  static String _identifierToEmail(String identifier) {
    identifier = identifier.trim();
    if (identifier.contains('@')) return identifier;
    return '$identifier@mycard.com';
  }

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

  // Pure Login Logic: No Firestore dependency, no mandatory conversions.
  static Future<User?> login(String identifier, String password) async {
    identifier = identifier.trim();
    
    try {
      // Step 1: Attempt raw login with identifier as-is (for old/custom formats)
      try {
        final cred = await _auth.signInWithEmailAndPassword(
          email: identifier,
          password: password,
        );
        return cred.user;
      } on FirebaseAuthException catch (e) {
        // Step 2: If raw login fails due to invalid-email or user-not-found, 
        // try the dummy email format (for newer accounts created via the app).
        if (e.code == 'invalid-email' || e.code == 'user-not-found') {
          if (!identifier.contains('@')) {
            final dummyEmail = _identifierToEmail(identifier);
            final cred = await _auth.signInWithEmailAndPassword(
              email: dummyEmail,
              password: password,
            );
            return cred.user;
          }
        }
        // If it's a real auth error (wrong-password), rethrow it.
        rethrow;
      }
    } on FirebaseAuthException catch (e) {
      // Map only AUTH errors. Role or Data errors belong elsewhere.
      if (e.code == 'wrong-password' || e.code == 'user-not-found' || e.code == 'invalid-credential') {
        throw Exception('كلمة المرور غير صحيحة أو الحساب غير موجود.');
      } else if (e.code == 'too-many-requests') {
        throw Exception('تم حظر المحاولات مؤقتاً لكثرة المحاولات الخاطئة.');
      } else if (e.code == 'invalid-email') {
        throw Exception('صيغة اسم المستخدم غير صحيحة.');
      }
      throw Exception('فشل تسجيل الدخول: ${e.message}');
    } catch (e) {
      throw Exception('حدث خطأ غير متوقع أثناء المصادقة.');
    }
  }

  static Future<void> changePassword(String currentPassword, String newPassword) async {
    User? user = _auth.currentUser;
    if (user != null && user.email != null) {
      try {
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
