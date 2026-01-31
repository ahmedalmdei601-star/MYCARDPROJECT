import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
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
        title: const Text("تغيير كلمة المرور", textAlign: TextAlign.center),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "أدخل كلمة المرور الجديدة الخاصة بك",
              style: TextStyle(fontSize: 14, color: Colors.black54),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "كلمة المرور الجديدة",
                prefixIcon: Icon(Icons.lock_outline, color: primaryColor),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              passwordController.dispose();
            },
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
                  
                  // إظهار تنبيه النجاح
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text("تم تغيير كلمة المرور بنجاح"),
                      backgroundColor: primaryColor,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  );
                  
                  // محاكاة صوت تنبيه النجاح (برمجياً عبر Feedback)
                  Feedback.forTap(context);
                  
                  passwordController.dispose();
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("خطأ: $e"), backgroundColor: errorColor),
                  );
                }
              }
            },
            child: const Text("تحديث"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userState = Provider.of<UserState>(context);
    final userName = userState.user?.name ?? "صاحب البقالة";

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text("متجري"),
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
          // Client Header
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "مرحباً، $userName",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "إليك نظرة سريعة على كروتك وعملياتك",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
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
                  title: "إرسال كرت",
                  subtitle: "بيع كرت لعميل",
                  icon: Icons.send_to_mobile_outlined,
                  color: Colors.orange,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SendCardScreen())),
                ),
                _buildMenuCard(
                  context,
                  title: "كروتي",
                  subtitle: "الكروت المتاحة لديك",
                  icon: Icons.inventory_2_outlined,
                  color: Colors.teal,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ClientInventoryScreen())),
                ),
                _buildMenuCard(
                  context,
                  title: "السجل",
                  subtitle: "عمليات البيع السابقة",
                  icon: Icons.history_edu_outlined,
                  color: Colors.blue,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ClientHistoryScreen())),
                ),
                _buildMenuCard(
                  context,
                  title: "الأمان",
                  subtitle: "تغيير كلمة المرور",
                  icon: Icons.security_outlined,
                  color: Colors.redAccent,
                  onTap: () => _showChangePasswordDialog(context),
                ),
              ],
            ),
          ),
          
          // Settings shortcut
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: TextButton.icon(
              onPressed: () {
                // شاشة الإعدادات
              },
              icon: const Icon(Icons.settings, size: 18, color: Colors.grey),
              label: const Text(
                "إعدادات التطبيق",
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
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
}
