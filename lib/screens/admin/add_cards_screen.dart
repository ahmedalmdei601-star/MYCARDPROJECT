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
  final TextEditingController _valueController = TextEditingController();

  String _selectedProvider = 'YemenMobile';
  bool _loading = false;

  final List<String> _categories = [
    'YemenMobile',
    'Sabafon',
    'MTN',
    'YOU',
  ];

  @override
  void dispose() {
    _cardNumberController.dispose();
    _valueController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    final valueText = _valueController.text.trim();
    final value = int.tryParse(valueText);
    if (value == null) {
      _showMessage('الرجاء إدخال قيمة الكروت أولاً', isError: true);
      return;
    }

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
          final cardState = Provider.of<CardState>(context, listen: false);
          int added = await cardState.addCardsBatch(codes, _selectedProvider, value);
          _showMessage('تمت معالجة ${codes.length} كود. تم إضافة $added كرت جديد بنجاح');
        }
      }
    } catch (e) {
      _showMessage('خطأ في معالجة الملف: $e', isError: true);
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _saveCard() async {
    final cardNumber = _cardNumberController.text.trim();
    final valueText = _valueController.text.trim();

    if (cardNumber.isEmpty || valueText.isEmpty) {
      _showMessage('الرجاء إدخال جميع الحقول', isError: true);
      return;
    }

    final value = int.tryParse(valueText);
    if (value == null) {
      _showMessage('قيمة الكرت غير صحيحة', isError: true);
      return;
    }

    setState(() => _loading = true);
    final cardState = Provider.of<CardState>(context, listen: false);

    try {
      await cardState.addCard(
        cardNumber: cardNumber,
        provider: _selectedProvider,
        value: value,
      );
      _cardNumberController.clear();
      _showMessage('تم إضافة الكرت بنجاح');
    } catch (e) {
      if (e.toString().contains('CARD_ALREADY_EXISTS')) {
        _showMessage('هذا الكرت موجود مسبقاً', isError: true);
      } else {
        _showMessage('خطأ: $e', isError: true);
      }
    } finally {
      setState(() => _loading = false);
    }
  }

  void _showMessage(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(fontFamily: 'Cairo')),
        backgroundColor: isError ? errorColor : primaryColor,
        behavior: SnackBarBehavior.floating,
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
                    TextField(
                      controller: _valueController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'قيمة الكرت',
                        prefixIcon: Icon(Icons.payments_outlined, color: primaryColor),
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedProvider,
                      items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                      onChanged: (v) => setState(() => _selectedProvider = v!),
                      decoration: const InputDecoration(
                        labelText: 'الشركة المزودة',
                        prefixIcon: Icon(Icons.business, color: primaryColor),
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
                      'ارفع ملف نصي يحتوي على الأكواد مفصولة بأسطر. سيتم تطبيق القيمة والشركة المحددة أعلاه على جميع الأكواد.',
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
