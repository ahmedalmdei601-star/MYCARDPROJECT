import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_state.dart';
import '../../theme.dart';
import 'add_cards_screen.dart';
import 'distribute_screen.dart';
import 'reports_screen.dart';
import '../register_screen.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text("لوحة التحكم"),
        leading: IconButton(
          icon: const Icon(Icons.settings_outlined),
          onPressed: () {
            // سنضيف شاشة الإعدادات لاحقاً
            _showSettingsDialog(context);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () async {
              await Provider.of<UserState>(context, listen: false).signOut();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Welcome Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "مرحباً المسؤول",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  "إليك ملخص إدارة الشبكة اليوم",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
              padding: const EdgeInsets.all(24),
              children: [
                _buildMenuCard(
                  context,
                  title: "إضافة بقالة",
                  subtitle: "إنشاء حساب Client",
                  icon: Icons.storefront_outlined,
                  color: Colors.blue,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen())),
                ),
                _buildMenuCard(
                  context,
                  title: "إضافة كروت",
                  subtitle: "إدخال كروت الشبكة",
                  icon: Icons.add_card_outlined,
                  color: Colors.orange,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddCardsScreen())),
                ),
                _buildMenuCard(
                  context,
                  title: "توزيع كروت",
                  subtitle: "توزيع على البقالات",
                  icon: Icons.move_to_inbox_outlined,
                  color: Colors.teal,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DistributeScreen())),
                ),
                _buildMenuCard(
                  context,
                  title: "التقارير",
                  subtitle: "المبيعات والاستخدام",
                  icon: Icons.analytics_outlined,
                  color: Colors.purple,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ReportsScreen())),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: Colors.grey.withOpacity(0.1)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 32, color: color),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.black45,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('الإعدادات', textAlign: TextAlign.center),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.language, color: primaryColor),
              title: const Text('لغة التطبيق'),
              subtitle: const Text('العربية'),
              onTap: () {
                Navigator.pop(context);
                _showMessage(context, 'سيتم دعم تغيير اللغة قريباً');
              },
            ),
            ListTile(
              leading: const Icon(Icons.lock_outline, color: primaryColor),
              title: const Text('تغيير كلمة المرور'),
              onTap: () {
                Navigator.pop(context);
                // سنضيف شاشة تغيير كلمة المرور لاحقاً
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showMessage(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg, style: const TextStyle(fontFamily: 'Cairo'))),
    );
  }
}
