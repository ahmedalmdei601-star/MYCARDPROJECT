import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_state.dart';
import '../../services/auth_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _passwordController = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    if (_passwordController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("كلمة المرور يجب أن تكون 6 أحرف على الأقل")),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      await AuthService.changePassword(_passwordController.text.trim());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("تم تغيير كلمة المرور بنجاح")),
        );
        _passwordController.clear();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("خطأ: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userState = Provider.of<UserState>(context);
    final isArabic = userState.locale.languageCode == 'ar';

    return Scaffold(
      appBar: AppBar(
        title: const Text("الإعدادات"),
        backgroundColor: const Color(0xFF2E7D32),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            "التفضيلات",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32)),
          ),
          const SizedBox(height: 12),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.language, color: Color(0xFF2E7D32)),
                  title: const Text("اللغة / Language"),
                  subtitle: Text(isArabic ? "العربية" : "English"),
                  trailing: Switch(
                    value: !isArabic,
                    onChanged: (val) {
                      // استخدام Future.microtask لتجنب الخطأ الأحمر (Assertion Error)
                      Future.microtask(() => userState.toggleLanguage());
                    },
                    activeColor: const Color(0xFF2E7D32),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.dark_mode, color: Color(0xFF2E7D32)),
                  title: const Text("الوضع الداكن"),
                  subtitle: Text(userState.themeMode == ThemeMode.dark ? "مفعل" : "معطل"),
                  trailing: Switch(
                    value: userState.themeMode == ThemeMode.dark,
                    onChanged: (val) => userState.toggleTheme(val),
                    activeColor: const Color(0xFF2E7D32),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            "تغيير كلمة المرور",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32)),
          ),
          const SizedBox(height: 12),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: "كلمة المرور الجديدة",
                      prefixIcon: Icon(Icons.lock_outline, color: Color(0xFF2E7D32)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E7D32),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: _loading ? null : _changePassword,
                      child: _loading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text("تحديث كلمة المرور"),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
