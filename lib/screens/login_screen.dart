import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../providers/user_state.dart';
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
  bool _isPasswordVisible = false;

  Future<void> login() async {
    if (identifierController.text.isEmpty || passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('الرجاء إدخال اسم المستخدم وكلمة المرور', style: TextStyle(fontFamily: 'Cairo')),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => loading = true);
    
    final userState = Provider.of<UserState>(context, listen: false);
    userState.clearState();

    try {
      await AuthService.login(
        identifierController.text.trim(),
        passwordController.text.trim(),
      );
      // Navigation is handled automatically by RootScreen in main.dart
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', ''), style: const TextStyle(fontFamily: 'Cairo')),
            backgroundColor: errorColor,
            behavior: SnackBarBehavior.floating,
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
    final userState = Provider.of<UserState>(context);
    final isArabic = userState.locale.languageCode == 'ar';

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.wifi_tethering, size: 80, color: primaryColor),
                ),
                const SizedBox(height: 30),
                Text(
                  isArabic ? 'مرحباً بك' : 'Welcome Back',
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, fontFamily: 'Cairo', color: primaryColor),
                ),
                const SizedBox(height: 10),
                Text(
                  isArabic ? 'قم بتسجيل الدخول لإدارة شبكتك' : 'Sign in to manage your network',
                  style: const TextStyle(fontSize: 16, color: Colors.black54, fontFamily: 'Cairo'),
                ),
                const SizedBox(height: 50),

                // Identifier Input (Phone or Email)
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: TextField(
                    controller: identifierController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: isArabic ? 'رقم الهاتف أو البريد' : 'Phone or Email',
                      prefixIcon: const Icon(Icons.person_outline, color: primaryColor),
                      hintText: '777xxxxxx',
                      hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                    style: const TextStyle(fontFamily: 'Cairo'),
                  ),
                ),
                const SizedBox(height: 20),
                
                // Password Input
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: TextField(
                    controller: passwordController,
                    obscureText: !_isPasswordVisible,
                    decoration: InputDecoration(
                      labelText: isArabic ? 'كلمة المرور' : 'Password',
                      prefixIcon: const Icon(Icons.lock_outline, color: primaryColor),
                      suffixIcon: IconButton(
                        icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off, color: Colors.grey),
                        onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                      ),
                    ),
                    style: const TextStyle(fontFamily: 'Cairo'),
                  ),
                ),
                const SizedBox(height: 40),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: loading ? null : login,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: loading
                        ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : Text(isArabic ? 'تسجيل الدخول' : 'Login', style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
                const SizedBox(height: 40),
                Text(
                  isArabic ? 'نظام إدارة الشبكات المحلية للبقالات' : 'Local Network Management System',
                  style: const TextStyle(color: Colors.grey, fontSize: 12, fontFamily: 'Cairo'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
