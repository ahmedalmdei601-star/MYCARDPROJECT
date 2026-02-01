import 'package:flutter/material.dart';
import '../../services/user_services.dart';
import '../../models/user_model.dart';
import '../../theme.dart';
import '../register_screen.dart';

class ManageStoresScreen extends StatelessWidget {
  const ManageStoresScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final UserService userService = UserService();

    return Scaffold(
      appBar: AppBar(
        title: const Text("إدارة البقالات"),
        backgroundColor: const Color(0xFF2E7D32),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const RegisterScreen()),
            ),
          ),
        ],
      ),
      body: StreamBuilder<List<UserModel>>(
        stream: userService.getClients(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("حدث خطأ: ${snapshot.error}"));
          }
          final clients = snapshot.data ?? [];
          if (clients.isEmpty) {
            return const Center(child: Text("لا توجد بقالات مضافة بعد."));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: clients.length,
            itemBuilder: (context, index) {
              final client = clients[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                elevation: 3,
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFF2E7D32),
                    child: Icon(Icons.store, color: Colors.white),
                  ),
                  title: Text(client.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(client.phone),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_forever, color: Colors.red),
                    onPressed: () => _confirmDelete(context, client),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _confirmDelete(BuildContext context, UserModel client) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("حذف نهائي"),
        content: Text("هل أنت متأكد من حذف البقالة '${client.name}' نهائياً من النظام ومن Firebase؟"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("إلغاء"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await UserService().deleteUser(client.id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("تم الحذف بنجاح")),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("خطأ في الحذف: $e")),
                  );
                }
              }
            },
            child: const Text("حذف نهائي", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
