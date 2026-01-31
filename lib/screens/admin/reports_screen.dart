import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart' as intl;
import '../../theme.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          title: const Text('التقارير والإحصائيات'),
          bottom: const TabBar(
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            labelStyle: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold),
            unselectedLabelStyle: TextStyle(fontFamily: 'Cairo'),
            tabs: [
              Tab(text: 'إحصائيات الكروت'),
              Tab(text: 'سجل العمليات'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildCardStats(),
            _buildTransactionsList(),
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
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data!.docs;
        if (docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.history_toggle_off, size: 80, color: Colors.grey.shade300),
                const SizedBox(height: 20),
                const Text('لا توجد عمليات بيع مسجلة حالياً', style: TextStyle(color: Colors.grey)),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            final date = (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now();
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.shopping_cart_outlined, color: Colors.blue, size: 20),
                ),
                title: Text('زبون: ${data['customerPhone']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('كرت: ${data['cardId']}', style: const TextStyle(fontSize: 12)),
                    Text(intl.DateFormat('yyyy-MM-dd HH:mm').format(date), style: const TextStyle(fontSize: 11, color: Colors.grey)),
                  ],
                ),
                isThreeLine: true,
              ),
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
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data!.docs;
        int available = docs.where((d) => d['status'] == 'available').length;
        int distributed = docs.where((d) => d['status'] == 'distributed').length;
        int used = docs.where((d) => d['status'] == 'used').length;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'ملخص حالة الكروت',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 20),
              
              _buildModernStatCard('كروت متاحة (الأدمن)', available, Icons.inventory_2, Colors.green),
              const SizedBox(height: 16),
              _buildModernStatCard('كروت موزعة (البقالات)', distributed, Icons.storefront, Colors.orange),
              const SizedBox(height: 16),
              _buildModernStatCard('كروت مباعة (للزبائن)', used, Icons.sell, Colors.blue),
              
              const SizedBox(height: 40),
              
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [primaryColor, primaryColor.withOpacity(0.8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Text(
                      'إجمالي الكروت في النظام',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${docs.length}',
                      style: const TextStyle(color: Colors.white, fontSize: 42, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildModernStatCard(String title, int count, IconData icon, Color color) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: color.withOpacity(0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
            ),
            Text(
              '$count',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color),
            ),
          ],
        ),
      ),
    );
  }
}
