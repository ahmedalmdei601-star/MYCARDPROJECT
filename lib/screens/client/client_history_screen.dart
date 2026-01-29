import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart' as intl;
import '../../services/auth_service.dart';

class ClientHistoryScreen extends StatelessWidget {
  const ClientHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = AuthService.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('سجل العمليات')),
      body: currentUser == null
          ? const Center(child: Text('يرجى تسجيل الدخول'))
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('transactions')
                  .where('clientId', isEqualTo: currentUser.uid)
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) return Center(child: Text('خطأ: ${snapshot.error}'));
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                final docs = snapshot.data!.docs;
                if (docs.isEmpty) return const Center(child: Text('لا توجد عمليات سابقة'));

                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    final date = (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now();
                    return ListTile(
                      leading: const Icon(Icons.check_circle, color: Colors.green),
                      title: Text('إرسال إلى: ${data['customerPhone']}'),
                      subtitle: Text('رقم الكرت: ${data['cardId']}'),
                      trailing: Text(intl.DateFormat('MM-dd HH:mm').format(date)),
                    );
                  },
                );
              },
            ),
    );
  }
}
