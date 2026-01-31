import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../providers/user_state.dart';
import '../theme.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  bool loading = false;

  Future<void> _updatePassword() async {
    final isArabic = Provider.of<UserState>(context, listen: false).locale.languageCode == 'ar';

    if (currentPasswordController.text.isEmpty || newPasswordController.text.isEmpty) {
      _showSnackBar(isArabic ? 'الرجاء ملء جميع الحقول' : 'Please fill all fields', isError: true);
      return;
    }

    if (newPasswordController.text != confirmPasswordController.text) {
      _showSnackBar(isArabic ? 'كلمات المرور غير متطابقة' : 'Passwords do not match', isError: true);
      return;
    }

    if (newPasswordController.text.length < 6) {
      _showSnackBar(isArabic ? 'كلمة المرور يجب أن تكون 6 أحرف على الأقل' : 'Password must be at least 6 characters', isError: true);
      return;
    }

    setState(() => loading = true);

    try {
      await AuthService.changePassword(
        currentPasswordController.text,
        newPasswordController.text,
      );
      
      if (mounted) {
        _showSnackBar(isArabic ? 'تم تغيير كلمة المرور بنجاح' : 'Password changed successfully');
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar(e.toString().replaceAll('Exception: ', ''), isError: true);
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontFamily: 'Cairo')),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = Provider.of<UserState>(context).locale.languageCode == 'ar';

    return Scaffold(
      appBar: AppBar(
        title: Text(isArabic ? 'تغيير كلمة المرور' : 'Change Password', style: const TextStyle(fontFamily: 'Cairo')),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Icon(Icons.security_outlined, size: 80, color: primaryColor),
            const SizedBox(height: 30),
            _buildTextField(
              controller: currentPasswordController,
              label: isArabic ? 'كلمة المرور الحالية' : 'Current Password',
              isArabic: isArabic,
            ),
            const SizedBox(height: 20),
            _buildTextField(
              controller: newPasswordController,
              label: isArabic ? 'كلمة المرور الجديدة' : 'New Password',
              isArabic: isArabic,
            ),
            const SizedBox(height: 20),
            _buildTextField(
              controller: confirmPasswordController,
              label: isArabic ? 'تأكيد كلمة المرور الجديدة' : 'Confirm New Password',
              isArabic: isArabic,
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: loading ? null : _updatePassword,
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                child: loading 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(isArabic ? 'تحديث كلمة المرور' : 'Update Password', style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({required TextEditingController controller, required String label, required bool isArabic}) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: TextField(
        controller: controller,
        obscureText: true,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(fontFamily: 'Cairo'),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}
