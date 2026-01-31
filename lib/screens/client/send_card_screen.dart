import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/card_services.dart';
import '../../services/auth_service.dart';
import '../../theme.dart';

class SendCardScreen extends StatefulWidget {
  const SendCardScreen({super.key});

  @override
  State<SendCardScreen> createState() => _SendCardScreenState();
}

class _SendCardScreenState extends State<SendCardScreen> {
  final _phoneController = TextEditingController();
  final _cardService = CardService();
  bool _loading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _sendCard() async {
    final phone = _phoneController.text.trim();
    final currentUser = AuthService.currentUser;

    if (phone.isEmpty || currentUser == null) {
      _showMsg('الرجاء إدخال رقم هاتف الزبون', isError: true);
      return;
    }

    setState(() => _loading = true);
    try {
      // يتم جلب الكرت المتاح تلقائياً من مخزن المستخدم
      // المنطق البرمجي في CardService سيتولى جلب الكرت المناسب
      final card = await _cardService.getAvailableCard(currentUser.uid);
      
      if (card == null) {
        _showMsg('عذراً، لا توجد كروت متاحة حالياً في مخزنك', isError: true);
        return;
      }

      final String cardCode = card['cardNumber'];
      final String provider = card['provider'];
      final String value = card['value'].toString();
      
      final String message = 'تم شراء كرت $provider فئة $value\nرقم الكرت: $cardCode\nشكراً لتعاملك معنا.';

      final Uri smsUri = Uri(
        scheme: 'sms',
        path: phone,
        queryParameters: {'body': message},
      );

      if (await canLaunchUrl(smsUri)) {
        await launchUrl(smsUri, mode: LaunchMode.externalApplication);
        // تحديث حالة الكرت في قاعدة البيانات
        await _cardService.markCardAsUsed(cardCode, phone, currentUser.uid);
        _showMsg('تم تجهيز الرسالة وفتح تطبيق الرسائل');
        _phoneController.clear();
      } else {
        _showMsg('فشل فتح تطبيق الرسائل، يرجى التأكد من صلاحيات التطبيق', isError: true);
      }
    } catch (e) {
      _showMsg('حدث خطأ غير متوقع: $e', isError: true);
    } finally {
      if (mounted) setState(() => _loading = false);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(title: const Text('إرسال كرت لعميل')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('بيانات الزبون', Icons.send_to_mobile_outlined),
                const SizedBox(height: 20),
                Card(
                  margin: EdgeInsets.zero,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                    side: BorderSide(color: Colors.grey.withOpacity(0.1)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        // Helpful Info about the process
                        const Text(
                          'سيتم سحب كرت واحد متاح من مخزنك تلقائياً وإرساله للرقم أدناه',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 14, color: Colors.black54, fontFamily: 'Cairo'),
                        ),
                        const SizedBox(height: 30),
                        
                        // Customer Phone Input
                        TextField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(
                            labelText: 'رقم هاتف الزبون',
                            hintText: '7xxxxxxxx',
                            prefixIcon: Icon(Icons.person_outline, color: primaryColor),
                          ),
                        ),
                        const SizedBox(height: 30),
                        
                        // Action Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _loading ? null : _sendCard,
                            icon: _loading 
                              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                              : const Icon(Icons.send_rounded),
                            label: const Text('إرسال الكرت الآن', style: TextStyle(fontFamily: 'Cairo')),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 30),
                
                // Helpful Tip
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.green.shade100),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.lightbulb_outline, color: primaryColor),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'عند الضغط على إرسال، سيتم فتح تطبيق الرسائل في هاتفك مع نص الرسالة جاهزاً للإرسال.',
                          style: TextStyle(fontSize: 12, color: Colors.black54, height: 1.4, fontFamily: 'Cairo'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
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
            fontFamily: 'Cairo',
          ),
        ),
      ],
    );
  }
}
