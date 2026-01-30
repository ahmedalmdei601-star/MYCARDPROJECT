import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../services/user_services.dart';
import '../models/user_model.dart';
import '../theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final identifierController = TextEditingController();
  final passwordController = TextEditingController();
  bool loading = false;

  Future<void> login() async {
    if (identifierController.text.isEmpty || passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء إدخال رقم الهاتف/البريد وكلمة المرور')),
      );
      return;
    }

    setState(() => loading = true);
    try {
      await AuthService.login(
        identifierController.text.trim(),
        passwordController.text.trim(),
      );
      // No Navigator here — main.dart RootScreen will handle routing based on UserState
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  void dispose() {
    identifierController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.card_membership, size: 80, color: primaryColor),
              const SizedBox(height: 20),
              const Text(
                'تطبيق إدارة الكروت',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: primaryColor),
              ),
              const SizedBox(height: 10),
              const Text(
                'نظام إدارة الكروت مسبقة الدفع',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 40),

              TextField(
                controller: identifierController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'رقم الهاتف أو البريد الإلكتروني',
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'كلمة المرور',
                  prefixIcon: Icon(Icons.lock),
                ),
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: loading ? null : login,
                  child: loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('دخول'),
                ),
              ),

              // ===== زر إنشاء الأدمن المؤقت (للاستخدام الأول فقط) =====
              const SizedBox(height: 12),
              TextButton(
                onPressed: () async {
                  setState(() => loading = true);
                  try {
                    // Helper to convert phone to email
                    String email = identifierController.text.contains('@') 
                        ? identifierController.text.trim() 
                        : '${identifierController.text.trim()}@mycardproject.app';
                    
                    UserCredential cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
                      email: email,
                      password: passwordController.text.trim(),
                    );

                    if (cred.user != null) {
                      await UserService().createUser(UserModel(
                        id: cred.user!.uid,
                        name: 'مدير النظام',
                        phone: identifierController.text.trim(),
                        role: 'admin',
                        createdAt: DateTime.now(),
                      ));
                      
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('تم إنشاء حساب الأدمن بنجاح. يمكنك الدخول الآن.')),
                        );
                      }
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('خطأ: $e')),
                      );
                    }
                  } finally {
                    if (mounted) setState(() => loading = false);
                  }
                },
                child: const Text('إنشاء حساب أدمن بالبيانات أعلاه (لأول مرة فقط)'),
              ),

              const SizedBox(height: 30),
              const Text(
                'إذا لم يكن لديك حساب، يرجى التواصل مع الأدمن.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
