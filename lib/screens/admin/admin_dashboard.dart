import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_state.dart';
import '../../theme.dart';
import 'add_cards_screen.dart';
import 'distribute_screen.dart';
import 'reports_screen.dart';
import 'clients_management_screen.dart';
import '../settings_screen.dart';
import '../change_password_screen.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final userState = Provider.of<UserState>(context);
    final isArabic = userState.locale.languageCode == 'ar';

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(isArabic ? "لوحة التحكم" : "Admin Dashboard", style: const TextStyle(fontFamily: 'Cairo')),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
          ),
        ],
      ),
      drawer: _buildDrawer(context, isArabic),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(32),
                    bottomRight: Radius.circular(32),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isArabic ? "مرحباً المسؤول" : "Hello Admin",
                      style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold, fontFamily: 'Cairo'),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isArabic ? "إليك ملخص إدارة الشبكة اليوم" : "Here is your network summary today",
                      style: const TextStyle(color: Colors.white70, fontSize: 14, fontFamily: 'Cairo'),
                    ),
                  ],
                ),
              ),
              
              Padding(
                padding: const EdgeInsets.all(24),
                child: GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                  childAspectRatio: 0.85,
                  children: [
                    _buildMenuCard(
                      context,
                      title: isArabic ? "إدارة البقالات" : "Manage Clients",
                      icon: Icons.manage_accounts_outlined,
                      color: Colors.blue,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ClientsManagementScreen())),
                    ),
                    _buildMenuCard(
                      context,
                      title: isArabic ? "إضافة كروت" : "Add Cards",
                      icon: Icons.add_card_outlined,
                      color: Colors.orange,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddCardsScreen())),
                    ),
                    _buildMenuCard(
                      context,
                      title: isArabic ? "توزيع كروت" : "Distribute",
                      icon: Icons.move_to_inbox_outlined,
                      color: Colors.teal,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DistributeScreen())),
                    ),
                    _buildMenuCard(
                      context,
                      title: isArabic ? "التقارير" : "Reports",
                      icon: Icons.analytics_outlined,
                      color: Colors.purple,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ReportsScreen())),
                    ),
                    _buildMenuCard(
                      context,
                      title: isArabic ? "الأمان" : "Security",
                      icon: Icons.security_outlined,
                      color: Colors.redAccent,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChangePasswordScreen())),
                    ),
                    _buildMenuCard(
                      context,
                      title: isArabic ? "الإعدادات" : "Settings",
                      icon: Icons.settings_outlined,
                      color: Colors.grey,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context, bool isArabic) {
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(color: primaryColor),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.admin_panel_settings, color: primaryColor, size: 40),
            ),
            accountName: Text(isArabic ? "المسؤول" : "Administrator", style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Cairo')),
            accountEmail: Text(isArabic ? "إدارة الشبكة المحلية" : "Local Network Management", style: const TextStyle(fontFamily: 'Cairo')),
          ),
          ListTile(
            leading: const Icon(Icons.manage_accounts_outlined, color: primaryColor),
            title: Text(isArabic ? "إدارة البقالات" : "Manage Clients", style: const TextStyle(fontFamily: 'Cairo')),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ClientsManagementScreen())),
          ),
          ListTile(
            leading: const Icon(Icons.security_outlined, color: primaryColor),
            title: Text(isArabic ? "الأمان" : "Security", style: const TextStyle(fontFamily: 'Cairo')),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChangePasswordScreen())),
          ),
          ListTile(
            leading: const Icon(Icons.settings_outlined, color: primaryColor),
            title: Text(isArabic ? "الإعدادات" : "Settings", style: const TextStyle(fontFamily: 'Cairo')),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
          ),
          const Spacer(),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout_rounded, color: Colors.red),
            title: Text(isArabic ? "تسجيل الخروج" : "Logout", style: const TextStyle(fontFamily: 'Cairo', color: Colors.red)),
            onTap: () async {
              final userState = Provider.of<UserState>(context, listen: false);
              await userState.signOut();
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildMenuCard(BuildContext context, {required String title, required IconData icon, required Color color, required VoidCallback onTap}) {
    return Card(
      elevation: 2,
      shadowColor: color.withOpacity(0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(icon, size: 32, color: color),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Cairo', fontSize: 13), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
      ),
    );
  }
}
