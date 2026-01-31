import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createUser(UserModel user) async {
    await _firestore.collection('users').doc(user.id).set(user.toMap());
  }

  Future<void> updateLastLogin(String userId) async {
    await _firestore.collection('users').doc(userId).update({
      'lastLogin': FieldValue.serverTimestamp(),
    });
  }

  Future<UserModel?> getUser(String id) async {
    final doc = await _firestore.collection('users').doc(id).get();
    if (doc.exists && doc.data() != null) {
      return UserModel.fromMap(doc.data()!, doc.id);
    }
    return null;
  }

  Stream<List<UserModel>> getClients() {
    return _firestore
        .collection('users')
        .where('role', isEqualTo: 'client')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => UserModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  /// حذف المستخدم نهائياً من Firestore.
  /// ملاحظة: حذف المستخدم من Firebase Auth يتطلب صلاحيات إدارية (Admin SDK) أو أن يكون المستخدم مسجلاً دخوله حالياً.
  /// في تطبيقات الـ Client-side، نقوم بحذف الوثيقة من Firestore أولاً.
  Future<void> deleteUser(String id) async {
    // حذف بيانات المستخدم من Firestore
    await _firestore.collection('users').doc(id).delete();
    
    // ملاحظة: إذا كان العميل المراد حذفه هو المستخدم الحالي، يمكننا حذف حسابه من Auth أيضاً.
    // لكن بما أن الأدمن هو من يحذف، فإن حذف حساب الـ Auth يتطلب عادة Cloud Function.
    // سنكتفي حالياً بحذف وثيقة المستخدم مما يمنعه من الدخول للنظام (لأن النظام يتحقق من وجود الوثيقة).
  }
}
