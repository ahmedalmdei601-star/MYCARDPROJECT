import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import '../../providers/card_state.dart';
import '../../theme.dart';

class AddCardsScreen extends StatefulWidget {
  const AddCardsScreen({super.key});

  @override
  State<AddCardsScreen> createState() => _AddCardsScreenState();
}

class _AddCardsScreenState extends State<AddCardsScreen> {
  final TextEditingController _cardNumberController = TextEditingController();
  
  // القيمة الافتراضية للكرت
  int _selectedCardValue = 100;
  bool _loading = false;

  // القيم المسموح بها فقط
  final List<int> _allowedValues = [100, 200, 500, 1000];

  @override
  void dispose() {
    _cardNumberController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['txt'],
      );

      if (result != null && result.files.single.path != null) {
        setState(() => _loading = true);
        final file = File(result.files.single.path!);
        final content = await file.readAsString();
        
        final codes = content
            .split(RegExp(r'[\n\r\s,]+'))
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty && s.length > 5)
            .toList();

        if (codes.isEmpty) {
          _showMessage('لم يتم العثور على أكواد صالحة في الملف', isError: true);
        } else {
          // استخدام الـ Provider المتاح في شجرة الودجت
          final cardState = Provider.of<CardState>(context, listen: false);
          
          // إضافة timeout لضمان عدم التعليق
          int added = await cardState.addCardsBatch(
            codes, 
            'Default', // قيمة افتراضية بما أنه تم حذف الحقل
            _selectedCardValue
          ).timeout(
            const Duration(seconds: 30),
            onTimeout: () => throw 'انتهت مهلة الاتصال، يرجى التحقق من الإنترنت',
          );
          
          _showMessage('تمت معالجة ${codes.length} كود. تم إضافة $added كرت جديد بنجاح');
        }
      }
    } catch (e) {
      _showMessage('خطأ في معالجة الملف: $e', isError: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _saveCard() async {
    final cardNumber = _cardNumberController.text.trim();

    if (cardNumber.isEmpty) {
      _showMessage('الرجاء إدخال رقم الكرت', isError: true);
      return;
    }

    setState(() => _loading = true);
    
    try {
      final cardState = Provider.of<CardState>(context, listen: false);

      await cardState.addCard(
        cardNumber: cardNumber,
        provider: 'Default', // قيمة افتراضية بما أنه تم حذف الحقل
        value: _selectedCardValue,
      ).timeout(
        const Duration(seconds: 20),
        onTimeout: () => throw 'انتهت مهلة الاتصال بالخادم',
      );

      _cardNumberController.clear();
      _showMessage('تم إضافة الكرت بنجاح');
    } catch (e) {
      if (e.toString().contains('CARD_ALREADY_EXISTS')) {
        _showMessage('هذا الكرت موجود مسبقاً', isError: true);
      } else {
        _showMessage('حدث خطأ أثناء الحفظ: $e', isError: true);
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showMessage(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(fontFamily: 'Cairo')),
        backgroundColor: isError ? errorColor : primaryColor,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إدخال كروت الشبكة'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Manual Add Section
            _buildSectionTitle('إضافة يدوية', Icons.edit_note),
            const SizedBox(height: 20),
            Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    TextField(
                      controller: _cardNumberController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'رقم الكرت',
                        prefixIcon: Icon(Icons.credit_card, color: primaryColor),
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<int>(
                      value: _selectedCardValue,
                      items: _allowedValues.map((val) => DropdownMenuItem(
                        value: val, 
                        child: Text('$val ريال')
                      )).toList(),
                      onChanged: (v) => setState(() => _selectedCardValue = v!),
                      decoration: const InputDecoration(
                        labelText: 'قيمة الكرت',
                        prefixIcon: Icon(Icons.payments_outlined, color: primaryColor),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _loading ? null : _saveCard,
                        icon: _loading 
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Icon(Icons.check_circle_outline),
                        label: const Text('حفظ الكرت في النظام'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 40),
            
            // File Upload Section
            _buildSectionTitle('إضافة عبر ملف (TXT)', Icons.file_upload_outlined),
            const SizedBox(height: 20),
            Card(
              margin: EdgeInsets.zero,
              color: Colors.green.shade50,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: primaryColor.withOpacity(0.2)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Text(
                      'ارفع ملف نصي يحتوي على الأكواد مفصولة بأسطر. سيتم تطبيق القيمة المحددة أعلاه على جميع الأكواد.',
                      style: TextStyle(fontSize: 13, color: Colors.black54, height: 1.5),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _loading ? null : _pickFile,
                        icon: const Icon(Icons.upload_file),
                        label: const Text('اختيار ملف الأكواد'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: const BorderSide(color: primaryColor),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            if (_loading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(30),
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        ),
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
