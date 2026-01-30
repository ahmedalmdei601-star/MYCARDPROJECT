import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../login_screen.dart';
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
      appBar: AppBar(
        title: const Text("لوحة تحكم الأدمن"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await Provider.of<UserState>(context, listen: false).signOut();
            },
          ),
        ],
      ),
      body: GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildMenuCard(
            context,
            title: "إضافة بقالة",
            icon: Icons.person_add,
            color: primaryColor,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen())),
          ),
          _buildMenuCard(
            context,
            title: "إضافة كروت",
            icon: Icons.add_card,
            color: accentColor,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddCardsScreen())),
          ),
          _buildMenuCard(
            context,
            title: "توزيع كروت",
            icon: Icons.send,
            color: secondaryColor,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DistributeScreen())),
          ),
          _buildMenuCard(
            context,
            title: "التقارير",
            icon: Icons.bar_chart,
            color: errorColor,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ReportsScreen())),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: color),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}