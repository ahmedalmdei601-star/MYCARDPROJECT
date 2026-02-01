import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // جلب بيانات مستخدم واحد
  Future<UserModel?> getUser(String id) async {
    final doc = await _firestore.collection('users').doc(id).get();
    if (doc.exists && doc.data() != null) {
      return UserModel.fromMap(doc.data()!, doc.id);
    }
    return null;
  }

  // جلب قائمة العمال (البقالات)
  Stream<List<UserModel>> getClients() {
    return _firestore
        .collection('users')
        .where('role', isEqualTo: 'client')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => UserModel.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }


  // تحديث آخر ظهور
  Future<void> updateLastLogin(String userId) async {
    await _firestore.collection('users').doc(userId).update({
      'lastLogin': FieldValue.serverTimestamp(),
    });
  }

  // حذف مستخدم (بقالة) من Firestore
  Future<void> deleteUser(String id) async {
    // 1. حذف بيانات المستخدم من Firestore
    await _firestore.collection('users').doc(id).delete();
    
    // 2. يمكن هنا إضافة حذف البيانات المرتبطة (مثل سجل العمليات الخاص به إذا كان مطلوباً)
    // حالياً سنكتفي بحذف وثيقة المستخدم الأساسية
  }

  // إنشاء مستخدم جديد (يستخدم في شاشة التسجيل)
  Future<void> createUser(UserModel user) async {
    await _firestore.collection('users').doc(user.id).set(user.toMap());
  }
}