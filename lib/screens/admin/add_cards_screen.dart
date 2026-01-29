import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../../services/card_services.dart';

class AddCardsScreen extends StatefulWidget {
  const AddCardsScreen({super.key});

  @override
  State<AddCardsScreen> createState() => _AddCardsScreenState();
}

class _AddCardsScreenState extends State<AddCardsScreen> {
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _valueController = TextEditingController();

  String _selectedCategory = 'YemenMobile';
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
    if (valueText.isEmpty) {
      _showMessage('الرجاء إدخال قيمة الكروت أولاً');
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
        
        // تحسين منطق استخراج الأكواد: تقسيم بناءً على أسطر أو فواصل أو مسافات
        final codes = content
            .split(RegExp(r'[\n\r\s,]+'))
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty && s.length > 5) // استبعاد النصوص القصيرة جداً
            .toList();

        if (codes.isEmpty) {
          _showMessage('لم يتم العثور على أكواد صالحة في الملف');
        } else {
          final cardService = CardService();
          int added = await cardService.addCardsBatch(codes, _selectedCategory, int.parse(valueText));
          _showMessage('تمت معالجة ${codes.length} كود. تم إضافة $added كرت جديد بنجاح');
        }
      }
    } catch (e) {
      _showMessage('خطأ في معالجة الملف: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _saveCard() async {
    final cardNumber = _cardNumberController.text.trim();
    final valueText = _valueController.text.trim();

    if (cardNumber.isEmpty || valueText.isEmpty) {
      _showMessage('الرجاء إدخال جميع الحقول');
      return;
    }

    final value = int.tryParse(valueText);
    if (value == null) {
      _showMessage('قيمة الكرت غير صحيحة');
      return;
    }

    setState(() => _loading = true);
    final CardService cardService = CardService();

    try {
      await cardService.addCard(
        cardNumber: cardNumber,
        category: _selectedCategory,
        value: value,
      );
      _cardNumberController.clear();
      _showMessage('تم إضافة الكرت بنجاح');
    } catch (e) {
      if (e.toString().contains('CARD_ALREADY_EXISTS')) {
        _showMessage('هذا الكرت موجود مسبقاً');
      } else {
        _showMessage('خطأ: $e');
      }
    } finally {
      setState(() => _loading = false);
    }
  }

  void _showMessage(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إضافة كروت'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'إضافة يدوية',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _cardNumberController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'رقم الكرت',
                prefixIcon: Icon(Icons.credit_card),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _valueController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'قيمة الكرت',
                prefixIcon: Icon(Icons.money),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: (v) => setState(() => _selectedCategory = v!),
              decoration: const InputDecoration(
                labelText: 'الشركة',
                prefixIcon: Icon(Icons.business),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _loading ? null : _saveCard,
                icon: const Icon(Icons.save),
                label: const Text('حفظ الكرت'),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 30),
              child: Divider(thickness: 1.5),
            ),
            const Text(
              'إضافة عبر ملف (TXT)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
            ),
            const SizedBox(height: 10),
            const Text(
              'تأكد من أن الملف يحتوي على الأكواد مفصولة بمسافات أو أسطر جديدة. سيتم استخدام "قيمة الكرت" و "الشركة" المحددة أعلاه لجميع الأكواد في الملف.',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 15),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                onPressed: _loading ? null : _pickFile,
                icon: const Icon(Icons.upload_file),
                label: const Text('رفع ملف TXT ومعالجة الأكواد'),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.green),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
            if (_loading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 10),
                      Text('جاري المعالجة...'),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
