import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/auth_service.dart';
import '../../theme.dart';

class ClientInventoryScreen extends StatelessWidget {
  const ClientInventoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = AuthService.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('الكروت المتاحة لديك')),
      body: currentUser == null
          ? const Center(child: Text('يرجى تسجيل الدخول'))
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('cards')
                  .where('ownerId', isEqualTo: currentUser.uid)
                  .where('status', isEqualTo: 'distributed')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                final docs = snapshot.data!.docs;
                if (docs.isEmpty) return const Center(child: Text('لا توجد كروت متاحة حالياً'));

                // تجميع الكروت حسب الشركة والقيمة
                Map<String, int> stats = {};
                for (var doc in docs) {
                  String provider = doc['provider'] ?? 'Unknown';
                  int value = doc['value'] ?? 0;
                  String key = '$provider - $value ريال';
                  stats[key] = (stats[key] ?? 0) + 1;
                }

                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: stats.entries.map((e) {
                    return Card(
                      elevation: 4,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        leading: const Icon(Icons.style, color: accentColor),
                        title: Text(e.key, style: const TextStyle(fontWeight: FontWeight.bold)),
                        trailing: Text('${e.value} كرت', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: primaryColor)),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
    );
  }
}
