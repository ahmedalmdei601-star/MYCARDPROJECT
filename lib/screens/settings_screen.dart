import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_state.dart';
import '../theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userState = Provider.of<UserState>(context);
    final isArabic = userState.locale.languageCode == 'ar';
    final isDark = userState.themeMode == ThemeMode.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(isArabic ? 'الإعدادات' : 'Settings', style: const TextStyle(fontFamily: 'Cairo')),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Language Section
          _buildSectionHeader(isArabic ? 'اللغة' : 'Language', isArabic),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Column(
              children: [
                RadioListTile<String>(
                  title: const Text('العربية', style: TextStyle(fontFamily: 'Cairo')),
                  value: 'ar',
                  groupValue: userState.locale.languageCode,
                  onChanged: (val) => userState.setLocale(const Locale('ar')),
                  activeColor: primaryColor,
                ),
                const Divider(height: 1),
                RadioListTile<String>(
                  title: const Text('English', style: TextStyle(fontFamily: 'Cairo')),
                  value: 'en',
                  groupValue: userState.locale.languageCode,
                  onChanged: (val) => userState.setLocale(const Locale('en')),
                  activeColor: primaryColor,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Appearance Section
          _buildSectionHeader(isArabic ? 'المظهر' : 'Appearance', isArabic),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: SwitchListTile(
              title: Text(
                isArabic ? 'الوضع الداكن' : 'Dark Mode',
                style: const TextStyle(fontFamily: 'Cairo'),
              ),
              secondary: Icon(isDark ? Icons.dark_mode : Icons.light_mode, color: primaryColor),
              value: isDark,
              onChanged: (val) => userState.toggleTheme(val),
              activeColor: primaryColor,
            ),
          ),
          const SizedBox(height: 24),

          // Account Info Section
          _buildSectionHeader(isArabic ? 'معلومات الحساب' : 'Account Info', isArabic),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.person_outline, color: primaryColor),
                  title: Text(isArabic ? 'الاسم' : 'Name', style: const TextStyle(fontFamily: 'Cairo')),
                  subtitle: Text(userState.user?.name ?? '', style: const TextStyle(fontFamily: 'Cairo')),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.phone_outlined, color: primaryColor),
                  title: Text(isArabic ? 'رقم الهاتف' : 'Phone', style: const TextStyle(fontFamily: 'Cairo')),
                  subtitle: Text(userState.user?.phone ?? '', style: const TextStyle(fontFamily: 'Cairo')),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          
          // Version Info
          Center(
            child: Text(
              isArabic ? 'إصدار التطبيق 1.0.0' : 'App Version 1.0.0',
              style: const TextStyle(color: Colors.grey, fontSize: 12, fontFamily: 'Cairo'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isArabic) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 8, right: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: primaryColor,
          fontFamily: 'Cairo',
        ),
      ),
    );
  }
}
