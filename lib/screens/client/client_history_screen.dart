import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart' as intl;
import '../../services/auth_service.dart';
import '../../theme.dart';

class ClientHistoryScreen extends StatelessWidget {
  const ClientHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = AuthService.currentUser;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(title: const Text('سجل المبيعات')),
      body: currentUser == null
          ? const Center(child: Text('يرجى تسجيل الدخول'))
          : StreamBuilder<QuerySnapshot>(
              // الاستعلام الأصلي الذي قد يفشل إذا لم يكن الفهرس المركب (clientId + timestamp) جاهزاً
              stream: FirebaseFirestore.instance
                  .collection('transactions')
                  .where('clientId', isEqualTo: currentUser.uid)
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                // في حال حدوث خطأ (مثل الفهرس المفقود)، نقوم بتنفيذ استعلام بديل بدون orderBy
                // ثم نقوم بالترتيب يدوياً داخل الكود (Client-side) لضمان ظهور البيانات دائماً.
                if (snapshot.hasError) {
                  return StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('transactions')
                        .where('clientId', isEqualTo: currentUser.uid)
                        .snapshots(),
                    builder: (context, fallbackSnapshot) {
                      if (fallbackSnapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      
                      if (fallbackSnapshot.hasError) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.error_outline, color: Colors.red, size: 60),
                                const SizedBox(height: 16),
                                Text(
                                  'حدث خطأ في جلب البيانات: ${fallbackSnapshot.error}',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(color: Colors.red),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      // جلب الوثائق وترتيبها يدوياً لضمان ظهور الأحدث أولاً
                      final docs = List<QueryDocumentSnapshot>.from(fallbackSnapshot.data!.docs);
                      docs.sort((a, b) {
                        final aTime = (a.data() as Map<String, dynamic>)['timestamp'] as Timestamp?;
                        final bTime = (b.data() as Map<String, dynamic>)['timestamp'] as Timestamp?;
                        if (aTime == null || bTime == null) return 0;
                        return bTime.compareTo(aTime); // ترتيب تنازلي (الأحدث أولاً)
                      });

                      return _buildTransactionList(docs);
                    },
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return _buildEmptyState();
                }

                return _buildTransactionList(snapshot.data!.docs);
              },
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_outlined, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 20),
          const Text(
            'لا توجد عمليات بيع مسجلة',
            style: TextStyle(fontSize: 18, color: Colors.grey, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const Text(
            'ستظهر هنا العمليات التي تقوم بها لزبائنك',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionList(List<QueryDocumentSnapshot> docs) {
    if (docs.isEmpty) return _buildEmptyState();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'إجمالي المبيعات: ${docs.length} عملية',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final date = (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now();
              return _buildTransactionItem(
                customerPhone: data['customerPhone'] ?? 'غير معروف',
                cardId: data['cardId'] ?? '---',
                date: date,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionItem({required String customerPhone, required String cardId, required DateTime date}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_outline, color: primaryColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'زبون: $customerPhone',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'رقم الكرت: $cardId',
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  intl.DateFormat('HH:mm').format(date),
                  style: const TextStyle(fontWeight: FontWeight.bold, color: primaryColor),
                ),
                Text(
                  intl.DateFormat('yyyy-MM-dd').format(date),
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
