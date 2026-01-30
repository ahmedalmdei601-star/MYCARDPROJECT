import 'package:flutter/material.dart';
import '../../services/card_services.dart';
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
  String _selectedProvider = 'YemenMobile';
  int? _selectedValue;
  final _countController = TextEditingController();
  bool _loading = false;

  final List<String> _providers = ['YemenMobile', 'Sabafon', 'MTN', 'YOU'];
  final List<int> _values = [100, 200, 500, 1000];

  @override
  void dispose() {
    _countController.dispose();
    super.dispose();
  }

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
                  decoration: const InputDecoration(labelText: 'البقالة المستلمة'),
                );
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selectedProvider,
              items: _providers.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: (v) => setState(() => _selectedProvider = v!),
              decoration: const InputDecoration(labelText: 'الشركة'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<int>(
              value: _selectedValue,
              items: _values.map((v) => DropdownMenuItem(value: v, child: Text(v.toString()))).toList(),
              onChanged: (v) => setState(() => _selectedValue = v),
              decoration: const InputDecoration(labelText: 'قيمة الكرت'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _countController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'عدد الكروت'),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _distribute,
                child: _loading ? const CircularProgressIndicator(color: Colors.white) : const Text('توزيع الآن'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _distribute() async {
    if (_selectedClientId == null || _countController.text.isEmpty || _selectedValue == null) {
      _showMsg('الرجاء إكمال البيانات');
      return;
    }

    setState(() => _loading = true);
    try {
      final cardState = Provider.of<CardState>(context, listen: false);
      await cardState.distributeCards(
        clientId: _selectedClientId!,
        provider: _selectedProvider,
        value: _selectedValue!,
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
