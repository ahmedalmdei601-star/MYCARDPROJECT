import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart' as intl;

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('التقارير والإحصائيات'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'سجل العمليات'),
              Tab(text: 'إحصائيات الكروت'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildTransactionsList(),
            _buildCardStats(),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionsList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('transactions')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return Center(child: Text('خطأ: ${snapshot.error}'));
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

        final docs = snapshot.data!.docs;
        if (docs.isEmpty) return const Center(child: Text('لا توجد عمليات مسجلة'));

        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            final date = (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now();
            return ListTile(
              leading: const Icon(Icons.history, color: Colors.blue),
              title: Text('رقم الزبون: ${data['customerPhone']}'),
              subtitle: Text('رقم الكرت: ${data['cardId']}'),
              trailing: Text(intl.DateFormat('yyyy-MM-dd HH:mm').format(date)),
            );
          },
        );
      },
    );
  }

  Widget _buildCardStats() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('cards').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

        final docs = snapshot.data!.docs;
        int available = docs.where((d) => d['status'] == 'available').length;
        int distributed = docs.where((d) => d['status'] == 'distributed').length;
        int used = docs.where((d) => d['status'] == 'used').length;

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildStatCard('كروت متاحة (عند الأدمن)', available, Colors.green),
              const SizedBox(height: 12),
              _buildStatCard('كروت موزعة (عند البقالات)', distributed, Colors.orange),
              const SizedBox(height: 12),
              _buildStatCard('كروت مستخدمة (تم إرسالها)', used, Colors.blue),
              const Divider(height: 40),
              const Text('إجمالي الكروت في النظام', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text('${docs.length}', style: const TextStyle(fontSize: 32, color: Colors.black)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard(String title, int count, Color color) {
    return Card(
      elevation: 2,
      child: ListTile(
        title: Text(title),
        trailing: Text('$count', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
      ),
    );
  }
}
