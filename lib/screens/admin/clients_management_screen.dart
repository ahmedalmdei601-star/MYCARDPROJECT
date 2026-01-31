import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user_model.dart';
import '../../services/user_services.dart';
import '../../providers/user_state.dart';
import '../../theme.dart';
import '../register_screen.dart';

class ClientsManagementScreen extends StatefulWidget {
  const ClientsManagementScreen({super.key});

  @override
  State<ClientsManagementScreen> createState() => _ClientsManagementScreenState();
}

class _ClientsManagementScreenState extends State<ClientsManagementScreen> {
  final UserService _userService = UserService();

  void _confirmDelete(UserModel client, bool isArabic) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(
          isArabic ? 'تأكيد الحذف' : 'Confirm Delete', 
          textAlign: TextAlign.center, 
          style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(
              isArabic 
                ? 'هل أنت متأكد من حذف بقالة "${client.name}"؟\nسيتم حذفها نهائياً من النظام.'
                : 'Are you sure you want to delete "${client.name}"?\nThis action is permanent.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontFamily: 'Cairo'),
            ),
          ],
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(isArabic ? 'إلغاء' : 'Cancel', style: const TextStyle(fontFamily: 'Cairo', color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              _showLoadingDialog();
              try {
                await _userService.deleteUser(client.id);
                if (mounted) {
                  Navigator.pop(context); // إغلاق لودينج
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(isArabic ? 'تم حذف البقالة بنجاح' : 'Client deleted successfully', style: const TextStyle(fontFamily: 'Cairo')),
                      backgroundColor: Colors.green,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  Navigator.pop(context); // إغلاق لودينج
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(isArabic ? 'فشل الحذف: $e' : 'Delete failed: $e', style: const TextStyle(fontFamily: 'Cairo')),
                      backgroundColor: Colors.red,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(isArabic ? 'حذف نهائي' : 'Delete', style: const TextStyle(fontFamily: 'Cairo', color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator(color: primaryColor)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = Provider.of<UserState>(context).locale.languageCode == 'ar';

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(isArabic ? 'إدارة البقالات' : 'Manage Clients', style: const TextStyle(fontFamily: 'Cairo')),
      ),
      body: StreamBuilder<List<UserModel>>(
        stream: _userService.getClients(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text(isArabic ? 'خطأ في جلب البيانات' : 'Error fetching data', style: const TextStyle(fontFamily: 'Cairo')));
          }

          final clients = snapshot.data ?? [];

          if (clients.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.storefront_outlined, size: 100, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text(
                    isArabic ? 'لا توجد بقالات مسجلة' : 'No registered clients',
                    style: const TextStyle(fontSize: 18, color: Colors.grey, fontFamily: 'Cairo'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: clients.length,
            itemBuilder: (context, index) {
              final client = clients[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: CircleAvatar(
                    backgroundColor: primaryColor.withOpacity(0.1),
                    child: const Icon(Icons.storefront, color: primaryColor),
                  ),
                  title: Text(client.name, style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Cairo')),
                  subtitle: Text(client.phone, style: const TextStyle(fontFamily: 'Cairo')),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () => _confirmDelete(client, isArabic),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen())),
        backgroundColor: primaryColor,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(isArabic ? 'إضافة بقالة' : 'Add Client', style: const TextStyle(fontFamily: 'Cairo', color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
