import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/auth_service.dart';

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

                // تجميع الكروت حسب الفئة
                Map<String, int> stats = {};
                for (var doc in docs) {
                  String cat = doc['category'];
                  stats[cat] = (stats[cat] ?? 0) + 1;
                }

                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: stats.entries.map((e) {
                    return Card(
                      child: ListTile(
                        leading: const Icon(Icons.style, color: Colors.green),
                        title: Text('فئة ${e.key}'),
                        trailing: Text('${e.value} كرت متاح', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
    );
  }
}
