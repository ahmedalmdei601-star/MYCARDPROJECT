import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../services/user_services.dart';
import '../models/user_model.dart';
import '../theme.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  bool loading = false;

  // Helper to convert phone to a valid email format for Firebase Auth
  String _identifierToEmail(String identifier) {
    if (identifier.contains('@')) return identifier.trim();
    return '${identifier.trim()}@mycardproject.app';
  }

  Future<void> createClient() async {
    if (nameController.text.isEmpty || phoneController.text.isEmpty || passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('الرجاء إكمال جميع الحقول')));
      return;
    }

    setState(() => loading = true);
    
    try {
      // To prevent the Admin from being logged out when creating a new user,
      // we use a secondary Firebase App instance for the creation process.
      FirebaseApp secondaryApp = await Firebase.initializeApp(
        name: 'SecondaryApp',
        options: Firebase.app().options,
      );

      FirebaseAuth secondaryAuth = FirebaseAuth.instanceFor(app: secondaryApp);
      
      UserCredential cred = await secondaryAuth.createUserWithEmailAndPassword(
        email: _identifierToEmail(phoneController.text.trim()),
        password: passwordController.text.trim(),
      );

      if (cred.user != null) {
        // Create user document in Firestore using the main app's Firestore instance
        await UserService().createUser(UserModel(
          id: cred.user!.uid,
          name: nameController.text.trim(),
          phone: phoneController.text.trim(),
          role: 'client',
          createdAt: DateTime.now(),
        ));

        // Clean up the secondary app
        await secondaryApp.delete();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم إنشاء حساب البقالة بنجاح')));
          Navigator.pop(context);
        }
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'خطأ في إنشاء الحساب.';
      if (e.code == 'email-already-in-use') {
        errorMessage = 'رقم الهاتف هذا مسجل بالفعل.';
      } else if (e.code == 'weak-password') {
        errorMessage = 'كلمة المرور ضعيفة جداً.';
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMessage)));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('حدث خطأ: $e')));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('إضافة حساب بقالة جديد')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "ملاحظة: هذا الحساب سيكون بصلاحية (صاحب بقالة) فقط.",
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'اسم البقالة / صاحب البقالة',
                prefixIcon: Icon(Icons.store),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'رقم الهاتف (سيستخدم لتسجيل الدخول)',
                prefixIcon: Icon(Icons.phone),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'كلمة المرور الأولية',
                prefixIcon: Icon(Icons.lock),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: loading ? null : createClient,
                child: loading ? const CircularProgressIndicator(color: Colors.white) : const Text('إنشاء الحساب'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
