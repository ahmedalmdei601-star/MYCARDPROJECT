import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/card_state.dart';
import '../../theme.dart';
import '../../services/user_services.dart';
import '../../models/user_model.dart';

class DistributeScreen extends StatefulWidget {
  const DistributeScreen({super.key});

  @override
  State<DistributeScreen> createState() => _DistributeScreenState();
}

class _DistributeScreenState extends State<DistributeScreen> {
  final _userService = UserService();
  
  String? _selectedClientId;
  int? _selectedValue;
  final _countController = TextEditingController();
  bool _loading = false;

  final List<int> _values = [100, 200, 500, 1000];

  @override
  void dispose() {
    _countController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(title: const Text('توزيع كروت')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('توزيع الكروت على البقالات', Icons.share_outlined),
            const SizedBox(height: 20),
            Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Client Selection
                    StreamBuilder<List<UserModel>>(
                      stream: _userService.getClients(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return const Text('لا يوجد بقالات مسجلة حالياً', style: TextStyle(color: Colors.red));
                        }
                        final clients = snapshot.data!;
                        return DropdownButtonFormField<String>(
                          value: _selectedClientId,
                          hint: const Text('اختر البقالة المستلمة'),
                          items: clients.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
                          onChanged: (v) => setState(() => _selectedClientId = v),
                          decoration: const InputDecoration(
                            labelText: 'البقالة',
                            prefixIcon: Icon(Icons.storefront, color: primaryColor),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    
                    // Value Selection
                    DropdownButtonFormField<int>(
                      value: _selectedValue,
                      hint: const Text('اختر قيمة الكرت'),
                      items: _values.map((v) => DropdownMenuItem(value: v, child: Text(v.toString()))).toList(),
                      onChanged: (v) => setState(() => _selectedValue = v),
                      decoration: const InputDecoration(
                        labelText: 'القيمة',
                        prefixIcon: Icon(Icons.payments_outlined, color: primaryColor),
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // Count Input
                    TextField(
                      controller: _countController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'عدد الكروت',
                        hintText: 'أدخل عدد الكروت المراد توزيعها',
                        prefixIcon: Icon(Icons.numbers, color: primaryColor),
                      ),
                    ),
                    const SizedBox(height: 30),
                    
                    // Action Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _loading ? null : _distribute,
                        icon: _loading 
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Icon(Icons.send_rounded),
                        label: const Text('إتمام عملية التوزيع'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 30),
            
            // Info Note
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.blue.shade100),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'سيتم نقل الكروت المتاحة في مخزن الأدمن إلى مخزن البقالة المحددة تلقائياً.',
                      style: TextStyle(fontSize: 12, color: Colors.blue, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _distribute() async {
    if (_selectedClientId == null || _countController.text.isEmpty || _selectedValue == null) {
      _showMsg('الرجاء إكمال جميع البيانات المطلوبة', isError: true);
      return;
    }

    final count = int.tryParse(_countController.text);
    if (count == null || count <= 0) {
      _showMsg('الرجاء إدخال عدد كروت صحيح', isError: true);
      return;
    }

    setState(() => _loading = true);
    try {
      final cardState = Provider.of<CardState>(context, listen: false);
      await cardState.distributeCards(
        clientId: _selectedClientId!,
        value: _selectedValue!,
        count: count,
      );
      _showMsg('تم توزيع الكروت بنجاح');
      _countController.clear();
    } catch (e) {
      String error = e.toString();
      if (error.contains('NOT_ENOUGH_CARDS')) {
        error = 'لا يوجد عدد كافٍ من الكروت المتاحة بهذه القيمة في المخزن';
      }
      _showMsg('خطأ: $error', isError: true);
    } finally {
      setState(() => _loading = false);
    }
  }

  void _showMsg(String m, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(m, style: const TextStyle(fontFamily: 'Cairo')),
        backgroundColor: isError ? errorColor : primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: primaryColor, size: 24),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}
