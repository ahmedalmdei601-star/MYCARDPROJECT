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

          // About Section
          _buildSectionHeader(isArabic ? 'حول التطبيق' : 'About', isArabic),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: ListTile(
              leading: const Icon(Icons.info_outline, color: primaryColor),
              title: Text(isArabic ? 'الإصدار' : 'Version', style: const TextStyle(fontFamily: 'Cairo')),
              trailing: const Text('1.0.0', style: TextStyle(fontWeight: FontWeight.bold)),
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
