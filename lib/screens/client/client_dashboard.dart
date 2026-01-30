# DO NOT EDIT MANUS-GENERATED CODE

import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../login_screen.dart';
import 'package:provider/provider.dart';
import '../../providers/user_state.dart';
import '../../theme.dart';
import 'send_card_screen.dart';
import 'client_inventory_screen.dart';
import 'client_history_screen.dart';

class ClientDashboard extends StatelessWidget {
  const ClientDashboard({super.key});

  void _showChangePasswordDialog(BuildContext context) {
    final passwordController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("تغيير كلمة المرور"),
        content: TextField(
          controller: passwordController,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: "كلمة المرور الجديدة",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("إلغاء"),
          ),
          ElevatedButton(
            onPressed: () async {
              if (passwordController.text.length < 6) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("كلمة المرور يجب أن تكون 6 أحرف على الأقل")),
                );
                return;
              }
              try {
                await AuthService.changePassword(passwordController.text.trim());
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("تم تغيير كلمة المرور بنجاح")),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("خطأ: $e")),
                  );
                }
              }
            },
            child: const Text("تغيير"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("لوحة تحكم البقالة"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await Provider.of<UserState>(context, listen: false).signOut();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            _buildMenuCard(
              context,
              title: "إرسال كرت",
              icon: Icons.send_to_mobile,
              color: secondaryColor,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SendCardScreen())),
            ),
            _buildMenuCard(
              context,
              title: "الكروت المتاحة",
              icon: Icons.inventory,
              color: primaryColor,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ClientInventoryScreen())),
            ),
            _buildMenuCard(
              context,
              title: "سجل العمليات",
              icon: Icons.history,
              color: accentColor,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ClientHistoryScreen())),
            ),
            _buildMenuCard(
              context,
              title: "تغيير كلمة المرور",
              icon: Icons.lock_reset,
              color: errorColor,
              onTap: () => _showChangePasswordDialog(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard(BuildContext context, {required String title, required IconData icon, required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
        child: Card(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: color),
            const SizedBox(height: 10),
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
