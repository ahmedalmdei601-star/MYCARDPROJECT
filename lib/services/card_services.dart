import 'package:cloud_firestore/cloud_firestore.dart';

class CardService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// إضافة كرت جديد
  Future<void> addCard({
    required String cardNumber,
    required String provider,
    required int value,
  }) async {
    final docRef = _firestore.collection('cards').doc(cardNumber);
    final doc = await docRef.get();

    if (doc.exists) {
      throw Exception('CARD_ALREADY_EXISTS');
    }

    await docRef.set({
      'cardNumber': cardNumber,
      'provider': provider,
      'value': value,
      'status': 'available', // available, distributed, used
      'ownerId': 'admin',
      'addedAt': FieldValue.serverTimestamp(),
      'usedAt': null,
      'customerPhone': null,
      'clientId': null,
    });
  }

  /// إضافة مجموعة كروت (Batch) مع التحقق من التكرار
  Future<int> addCardsBatch(List<String> codes, String provider, int value) async {
    int addedCount = 0;
    
    // تقسيم الكروت إلى مجموعات (كل مجموعة 500 كرت كحد أقصى لقيود Firestore Batch)
    for (var i = 0; i < codes.length; i += 500) {
      final end = (i + 500 < codes.length) ? i + 500 : codes.length;
      final currentBatchCodes = codes.sublist(i, end);
      
      final batch = _firestore.batch();
      
      for (var code in currentBatchCodes) {
        final trimmedCode = code.trim();
        if (trimmedCode.isEmpty) continue;
        
        final docRef = _firestore.collection('cards').doc(trimmedCode);
        
        batch.set(docRef, {
          'cardNumber': trimmedCode,
          'provider': provider,
          'value': value,
          'status': 'available',
          'ownerId': 'admin',
          'addedAt': FieldValue.serverTimestamp(),
          'usedAt': null,
          'customerPhone': null,
          'clientId': null,
        });
        addedCount++;
      }
      
      await batch.commit();
    }
    
    return addedCount;
  }

  /// توزيع الكروت لبقالة
  Future<void> distributeCards({
    required String clientId,
    required String provider,
    required int value,
    required int count,
  }) async {
    final query = await _firestore
        .collection('cards')
        .where('status', isEqualTo: 'available')
        .where('provider', isEqualTo: provider)
        .where('value', isEqualTo: value)
        .where('ownerId', isEqualTo: 'admin')
        .limit(count)
        .get();

    if (query.docs.length < count) {
      throw Exception('NOT_ENOUGH_CARDS');
    }

    final batch = _firestore.batch();
    for (var doc in query.docs) {
      batch.update(doc.reference, {
        'status': 'distributed',
        'ownerId': clientId,
        'distributedAt': FieldValue.serverTimestamp(),
      });
    }
    await batch.commit();
  }

  /// جلب الكروت الخاصة بالعميل
  Future<List<Map<String, dynamic>>> getClientCards(String clientId) async {
    final query = await _firestore
        .collection('cards')
        .where('ownerId', isEqualTo: clientId)
        .get();
    return query.docs.map((doc) => doc.data()).toList();
  }

  /// جلب كرت متاح للبقالة
  Future<Map<String, dynamic>?> getAvailableCard(String clientId, String provider) async {
    final query = await _firestore
        .collection('cards')
        .where('status', isEqualTo: 'distributed')
        .where('ownerId', isEqualTo: clientId)
        .where('provider', isEqualTo: provider)
        .limit(1)
        .get();

    if (query.docs.isEmpty) return null;
    return query.docs.first.data();
  }

  /// تحديث حالة الكرت إلى مستخدم
  Future<void> markCardAsUsed(String cardNumber, String customerPhone, String clientId) async {
    await _firestore.collection('cards').doc(cardNumber).update({
      'status': 'used',
      'usedAt': FieldValue.serverTimestamp(),
      'customerPhone': customerPhone,
      'clientId': clientId,
    });

    // تسجيل العملية في Transactions
    await _firestore.collection('transactions').add({
      'cardId': cardNumber,
      'clientId': clientId,
      'customerPhone': customerPhone,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}
