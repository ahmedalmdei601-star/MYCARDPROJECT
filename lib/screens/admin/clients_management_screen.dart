import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../services/user_services.dart';
import '../../theme.dart';
import '../register_screen.dart';

class ClientsManagementScreen extends StatefulWidget {
  const ClientsManagementScreen({super.key});

  @override
  State<ClientsManagementScreen> createState() => _ClientsManagementScreenState();
}

class _ClientsManagementScreenState extends State<ClientsManagementScreen> {
  final UserService _userService = UserService();

  void _confirmDelete(UserModel client) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف', textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Cairo')),
        content: Text(
          'هل أنت متأكد من حذف بقالة "${client.name}"؟\nسيتم حذف بيانات المستخدم من النظام فقط.',
          textAlign: TextAlign.center,
          style: const TextStyle(fontFamily: 'Cairo'),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء', style: TextStyle(fontFamily: 'Cairo')),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await _userService.deleteUser(client.id);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('تم حذف البقالة بنجاح', style: TextStyle(fontFamily: 'Cairo'))),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('خطأ في الحذف: $e', style: const TextStyle(fontFamily: 'Cairo')),
                      backgroundColor: errorColor,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('حذف', style: TextStyle(fontFamily: 'Cairo', color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('إدارة البقالات'),
      ),
      body: StreamBuilder<List<UserModel>>(
        stream: _userService.getClients(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('خطأ: ${snapshot.error}', style: const TextStyle(fontFamily: 'Cairo')));
          }

          final clients = snapshot.data ?? [];

          if (clients.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.storefront_outlined, size: 80, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  const Text(
                    'لا توجد بقالات مسجلة حالياً',
                    style: TextStyle(fontSize: 18, color: Colors.grey, fontFamily: 'Cairo'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: clients.length,
            itemBuilder: (context, index) {
              final client = clients[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: CircleAvatar(
                    backgroundColor: primaryColor.withOpacity(0.1),
                    child: const Icon(Icons.storefront, color: primaryColor),
                  ),
                  title: Text(
                    client.name,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Cairo'),
                  ),
                  subtitle: Text(
                    client.phone,
                    style: const TextStyle(fontFamily: 'Cairo'),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () => _confirmDelete(client),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const RegisterScreen()),
          );
        },
        backgroundColor: primaryColor,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('إضافة بقالة جديدة', style: TextStyle(fontFamily: 'Cairo', color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
