# DO NOT EDIT MANUS-GENERATED CODE

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../theme.dart';
// تم إزالة home_screen.dart

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final identifierController = TextEditingController();
  final passwordController = TextEditingController();
  bool loading = false;

  String _getArabicErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'invalid-credential':
        return 'بيانات الدخول غير صحيحة. تأكد من الرقم/البريد وكلمة المرور.';
      case 'user-not-found':
        return 'هذا الحساب غير موجود.';
      case 'wrong-password':
        return 'كلمة المرور غير صحيحة.';
      case 'too-many-requests':
        return 'تم حظر المحاولات مؤقتاً بسبب نشاط مشبوه. يرجى المحاولة لاحقاً.';
      case 'network-request-failed':
        return 'فشل الاتصال بالإنترنت. يرجى التحقق من الشبكة.';
      case 'invalid-email':
        return 'تنسيق البريد الإلكتروني أو الرقم غير صحيح.';
      default:
        return 'حدث خطأ غير متوقع: $errorCode';
    }
  }

  Future<void> login() async {
    if (identifierController.text.isEmpty || passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء إدخال رقم الهاتف/البريد وكلمة المرور')),
      );
      return;
    }

    setState(() => loading = true);
    try {
        final user = await AuthService.login(
        identifierController.text.trim(),
        passwordController.text.trim(),
      );

      if (user != null && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_getArabicErrorMessage(e.code)),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ غير متوقع: $e')),
        );
      }
    }
    if (mounted) setState(() => loading = false);
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
                  // تم تطبيق الثيم الجديد تلقائياً
                  child: loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('دخول'),
                ),
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
