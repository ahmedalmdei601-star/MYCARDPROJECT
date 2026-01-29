import 'package:flutter/material.dart';
import '../../services/card_services.dart';
import '../../services/user_services.dart';
import '../../models/user_model.dart';

class DistributeScreen extends StatefulWidget {
  const DistributeScreen({super.key});

  @override
  State<DistributeScreen> createState() => _DistributeScreenState();
}

class _DistributeScreenState extends State<DistributeScreen> {
  final _cardService = CardService();
  final _userService = UserService();
  
  String? _selectedClientId;
  String _selectedCategory = 'YemenMobile';
  final _countController = TextEditingController();
  bool _loading = false;

  final List<String> _categories = ['YemenMobile', 'Sabafon', 'MTN', 'YOU'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('توزيع الكروت')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            StreamBuilder<List<UserModel>>(
              stream: _userService.getClients(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const CircularProgressIndicator();
                final clients = snapshot.data!;
                return DropdownButtonFormField<String>(
                  value: _selectedClientId,
                  hint: const Text('اختر البقالة'),
                  items: clients.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
                  onChanged: (v) => setState(() => _selectedClientId = v),
                  decoration: const InputDecoration(border: OutlineInputBorder()),
                );
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: (v) => setState(() => _selectedCategory = v!),
              decoration: const InputDecoration(labelText: 'الفئة/الشركة', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _countController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'عدد الكروت', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _distribute,
                child: _loading ? const CircularProgressIndicator() : const Text('توزيع الآن'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _distribute() async {
    if (_selectedClientId == null || _countController.text.isEmpty) {
      _showMsg('الرجاء إكمال البيانات');
      return;
    }

    setState(() => _loading = true);
    try {
      await _cardService.distributeCards(
        clientId: _selectedClientId!,
        category: _selectedCategory,
        count: int.parse(_countController.text),
      );
      _showMsg('تم التوزيع بنجاح');
      _countController.clear();
    } catch (e) {
      _showMsg('خطأ: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  void _showMsg(String m) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));
}
