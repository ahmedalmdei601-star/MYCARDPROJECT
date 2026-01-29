import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/card_services.dart';
import '../../services/auth_service.dart';

class SendCardScreen extends StatefulWidget {
  const SendCardScreen({super.key});

  @override
  State<SendCardScreen> createState() => _SendCardScreenState();
}

class _SendCardScreenState extends State<SendCardScreen> {
  String _selectedCategory = 'YemenMobile';
  final _phoneController = TextEditingController();
  final _cardService = CardService();
  bool _loading = false;

  final List<String> _categories = ['YemenMobile', 'Sabafon', 'MTN', 'YOU'];

  Future<void> _sendCard() async {
    final phone = _phoneController.text.trim();
    final currentUser = AuthService.currentUser;

    if (phone.isEmpty || currentUser == null) {
      _showMsg('أدخل رقم الزبون');
      return;
    }

    setState(() => _loading = true);
    try {
      final card = await _cardService.getAvailableCard(currentUser.uid, _selectedCategory);
      
      if (card == null) {
        _showMsg('لا توجد كروت متاحة لهذه الفئة');
        return;
      }

      final String cardCode = card['cardNumber'];
      final String message = 'كرت فئة $_selectedCategory\nرقم الكرت: $cardCode';

      final Uri smsUri = Uri(
        scheme: 'sms',
        path: phone,
        queryParameters: {'body': message},
      );

      if (await canLaunchUrl(smsUri)) {
        await launchUrl(smsUri, mode: LaunchMode.externalApplication);
        // تحديث حالة الكرت في قاعدة البيانات
        await _cardService.markCardAsUsed(cardCode, phone, currentUser.uid);
        _showMsg('تم فتح تطبيق الرسائل بنجاح');
        _phoneController.clear();
      } else {
        _showMsg('فشل فتح تطبيق الرسائل');
      }
    } catch (e) {
      _showMsg('خطأ: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  void _showMsg(String m) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('إرسال كرت')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: (v) => setState(() => _selectedCategory = v!),
              decoration: const InputDecoration(labelText: 'الفئة/الشركة', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'رقم الزبون',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _loading ? null : _sendCard,
                icon: const Icon(Icons.send),
                label: _loading ? const CircularProgressIndicator() : const Text('إرسال الكرت للزبون'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
