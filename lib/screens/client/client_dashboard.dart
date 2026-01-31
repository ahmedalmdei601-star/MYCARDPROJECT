import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_state.dart';
import '../../theme.dart';
import 'send_card_screen.dart';
import 'client_inventory_screen.dart';
import 'client_history_screen.dart';
import '../settings_screen.dart';

class ClientDashboard extends StatelessWidget {
  const ClientDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final userState = Provider.of<UserState>(context);
    final isArabic = userState.locale.languageCode == 'ar';

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(isArabic ? "لوحة العميل" : "Client Dashboard", style: const TextStyle(fontFamily: 'Cairo')),
      ),
      drawer: _buildDrawer(context, isArabic),
      body: SingleChildScrollView(
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
                    isArabic ? "مرحباً ${userState.user?.name ?? ''}" : "Hello ${userState.user?.name ?? ''}",
                    style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, fontFamily: 'Cairo'),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isArabic ? "يمكنك بيع الكروت ومتابعة مبيعاتك" : "You can sell cards and track your sales",
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
                childAspectRatio: 0.9,
                children: [
                  _buildMenuCard(
                    context,
                    title: isArabic ? "بيع كرت" : "Sell Card",
                    icon: Icons.send_to_mobile_outlined,
                    color: Colors.green,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SendCardScreen())),
                  ),
                  _buildMenuCard(
                    context,
                    title: isArabic ? "المخزون" : "Inventory",
                    icon: Icons.inventory_2_outlined,
                    color: Colors.blue,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ClientInventoryScreen())),
                  ),
                  _buildMenuCard(
                    context,
                    title: isArabic ? "السجل" : "History",
                    icon: Icons.history_outlined,
                    color: Colors.orange,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ClientHistoryScreen())),
                  ),
                ],
              ),
            ),
          ],
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
              child: Icon(Icons.storefront, color: primaryColor, size: 40),
            ),
            accountName: Text(isArabic ? "صاحب البقالة" : "Store Owner", style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Cairo')),
            accountEmail: Text(isArabic ? "إدارة المبيعات" : "Sales Management", style: const TextStyle(fontFamily: 'Cairo')),
          ),
          ListTile(
            leading: const Icon(Icons.settings_outlined, color: primaryColor),
            title: Text(isArabic ? "الإعدادات" : "Settings", style: const TextStyle(fontFamily: 'Cairo')),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
            },
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
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24), side: BorderSide(color: Colors.grey.withOpacity(0.1))),
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
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Cairo'), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
