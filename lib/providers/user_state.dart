import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../services/user_services.dart';

class UserState extends ChangeNotifier {
  final UserService _userService = UserService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  UserModel? _user;
  bool _isLoading = true;
  String? _errorMessage;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
  // هذه الخصائص تعتمد كلياً على الكائن _user الحالي
  bool get isAdmin => _user?.role == 'admin';
  bool get isClient => _user?.role == 'client';
  bool get isAuthenticated => _user != null;

  UserState() {
    // الاستماع لحالة المصادقة
    _auth.authStateChanges().listen((firebaseUser) {
      if (firebaseUser != null) {
        _loadUser(firebaseUser.uid);
      } else {
        _resetState();
      }
    });
  }

  // دالة خاصة لإعادة تعيين الحالة بالكامل
  void _resetState() {
    _user = null;
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> _loadUser(String uid) async {
    // التأكد من تصفير الدور الحالي قبل جلب الجديد
    _user = null;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // جلب وثيقة المستخدم حصرياً من Firestore
      final userData = await _userService.getUser(uid);
      
      if (userData != null && (userData.role == 'admin' || userData.role == 'client')) {
        _user = userData;
      } else {
        // إذا لم يوجد مستند أو الدور غير معرف في Firestore
        _user = null;
        _errorMessage = 'صلاحيات المستخدم غير معرفة في النظام.';
        await _auth.signOut();
      }
    } catch (e) {
      debugPrint('Error loading user data from Firestore: $e');
      _user = null;
      _errorMessage = 'فشل جلب بيانات الصلاحيات من الخادم.';
      await _auth.signOut();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
      _resetState();
    } catch (e) {
      debugPrint('Error during sign out: $e');
    }
  }

  // دالة لتنظيف الحالة يدوياً وفورياً (تستخدم عند تغيير كلمة المرور)
  void clearState() {
    _resetState();
  }
  
  // دالة مساعدة لإعادة تحميل البيانات يدوياً إذا لزم الأمر
  Future<void> refresh() async {
    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      await _loadUser(currentUser.uid);
    } else {
      _resetState();
    }
  }
}
