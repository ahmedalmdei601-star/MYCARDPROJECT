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
      backgroundColor: backgroundColor,
      appBar: AppBar(title: const Text('مخزون الكروت')),
      body: currentUser == null
          ? const Center(child: Text('يرجى تسجيل الدخول'))
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('cards')
                  .where('ownerId', isEqualTo: currentUser.uid)
                  .where('status', isEqualTo: 'distributed')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey.shade300),
                        const SizedBox(height: 20),
                        const Text(
                          'مخزنك فارغ حالياً',
                          style: TextStyle(fontSize: 18, color: Colors.grey, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'تواصل مع المسؤول لتزويدك بالكروت',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                final docs = snapshot.data!.docs;

                // تجميع الكروت حسب الشركة والقيمة
                Map<String, Map<String, dynamic>> stats = {};
                for (var doc in docs) {
                  String provider = doc['provider'] ?? 'Unknown';
                  int value = doc['value'] ?? 0;
                  String key = '$provider-$value';
                  
                  if (!stats.containsKey(key)) {
                    stats[key] = {
                      'provider': provider,
                      'value': value,
                      'count': 0,
                    };
                  }
                  stats[key]!['count'] += 1;
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        'إجمالي الكروت المتاحة: ${docs.length}',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        itemCount: stats.length,
                        itemBuilder: (context, index) {
                          final item = stats.values.elementAt(index);
                          return _buildInventoryCard(
                            provider: item['provider'],
                            value: item['value'].toString(),
                            count: item['count'].toString(),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }

  Widget _buildInventoryCard({required String provider, required String value, required String count}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.style_outlined, color: primaryColor, size: 28),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    provider,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'فئة $value ريال',
                    style: const TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  count,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: primaryColor),
                ),
                const Text(
                  'كرت',
                  style: TextStyle(fontSize: 12, color: Colors.black45),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
