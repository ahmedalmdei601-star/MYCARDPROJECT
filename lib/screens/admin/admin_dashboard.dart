import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../login_screen.dart';
import 'package:provider/provider.dart';
import '../../providers/user_state.dart';
import '../../theme.dart';
import 'add_cards_screen.dart';
import 'distribute_screen.dart';
import 'reports_screen.dart';
import 'manage_stores_screen.dart';
import 'settings_screen.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("لوحة تحكم الأدمن"),
        backgroundColor: const Color(0xFF2E7D32),
        elevation: 0,
      ),
      drawer: _buildDrawer(context),
      body: Column(
        children: [
          // Header الأخضر
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 40),
            decoration: const BoxDecoration(
              color: Color(0xFF2E7D32),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
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
                  "إدارة الشبكة المحلية",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          
          // شبكة الخيارات
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              padding: const EdgeInsets.all(20),
              children: [
                _buildMenuCard(
                  context,
                  title: "إدارة البقالات",
                  subtitle: "عرض وحذف البقالات",
                  icon: Icons.storefront_outlined,
                  iconColor: Colors.blue,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ManageStoresScreen())),
                ),
                _buildMenuCard(
                  context,
                  title: "إضافة كروت",
                  subtitle: "إدخال كروت الشبكة",
                  icon: Icons.add_card_outlined,
                  iconColor: Colors.orange,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddCardsScreen())),
                ),
                _buildMenuCard(
                  context,
                  title: "توزيع كروت",
                  subtitle: "توزيع على البقالات",
                  icon: Icons.send_to_mobile_outlined,
                  iconColor: Colors.teal,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DistributeScreen())),
                ),
                _buildMenuCard(
                  context,
                  title: "التقارير",
                  subtitle: "المبيعات والاستخدام",
                  icon: Icons.bar_chart_outlined,
                  iconColor: Colors.purple,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ReportsScreen())),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: Color(0xFF2E7D32)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                CircleAvatar(
                  radius: 35,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.admin_panel_settings, size: 45, color: Color(0xFF2E7D32)),
                ),
                SizedBox(height: 10),
                Text(
                  "المسؤول",
                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(
                  "إدارة الشبكة المحلية",
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.store, color: Color(0xFF2E7D32)),
            title: const Text("إدارة البقالات"),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ManageStoresScreen()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.add_card, color: Color(0xFF2E7D32)),
            title: const Text("إضافة كروت"),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const AddCardsScreen()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.send, color: Color(0xFF2E7D32)),
            title: const Text("توزيع كروت"),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const DistributeScreen()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.bar_chart, color: Color(0xFF2E7D32)),
            title: const Text("التقارير"),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ReportsScreen()));
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings, color: Color(0xFF2E7D32)),
            title: const Text("الإعدادات"),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.info_outline, color: Color(0xFF2E7D32)),
            title: const Text("حولنا"),
            onTap: () => Navigator.pop(context),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text("تسجيل الخروج", style: TextStyle(color: Colors.red)),
            onTap: () async {
              Navigator.pop(context);
              await Provider.of<UserState>(context, listen: false).signOut();
            },
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
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 32, color: iconColor),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
