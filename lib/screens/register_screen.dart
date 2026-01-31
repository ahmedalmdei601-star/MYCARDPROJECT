import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  bool _isPasswordVisible = false;

  // Helper to convert phone to a valid email format for Firebase Auth
  String _identifierToEmail(String identifier) {
    if (identifier.contains('@')) return identifier.trim();
    return '${identifier.trim()}@mycardproject.app';
  }

  Future<void> createClient() async {
    if (nameController.text.isEmpty || phoneController.text.isEmpty || passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('الرجاء إكمال جميع الحقول'),
          behavior: SnackBarBehavior.floating,
        ),
      );
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
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم إنشاء حساب البقالة بنجاح'),
              backgroundColor: primaryColor,
              behavior: SnackBarBehavior.floating,
            ),
          );
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: errorColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('حدث خطأ: $e'),
          backgroundColor: errorColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
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
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('إضافة بقالة'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: primaryColor),
                  SizedBox(width: 15),
                  Expanded(
                    child: Text(
                      "سيتم إنشاء حساب جديد للبقالة، ويمكن لصاحب البقالة تسجيل الدخول باستخدام رقم الهاتف وكلمة المرور المحددة.",
                      style: TextStyle(fontSize: 13, color: primaryColor, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Form Section
            Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'اسم البقالة',
                        hintText: 'مثلاً: بقالة الخير',
                        prefixIcon: Icon(Icons.storefront, color: primaryColor),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'رقم الهاتف',
                        hintText: '7xxxxxxxx',
                        prefixIcon: Icon(Icons.phone_android, color: primaryColor),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: passwordController,
                      obscureText: !_isPasswordVisible,
                      decoration: InputDecoration(
                        labelText: 'كلمة المرور',
                        prefixIcon: const Icon(Icons.lock_outline, color: primaryColor),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                            color: Colors.grey,
                          ),
                          onPressed: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: loading ? null : createClient,
                        icon: loading 
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Icon(Icons.person_add_alt_1_outlined),
                        label: const Text('إنشاء حساب Client'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
