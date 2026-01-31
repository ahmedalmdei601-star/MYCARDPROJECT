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
  bool _initializingAuth = true;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
  bool get isAdmin => _user?.role == 'admin';
  bool get isClient => _user?.role == 'client';
  bool get isAuthenticated => _user != null;

  UserState() {
    _init();
  }

  void _init() {
    // الاستماع لحالة المصادقة
    _auth.authStateChanges().listen((firebaseUser) async {
      if (firebaseUser != null) {
        // إذا كان هناك مستخدم، نجلب بياناته دون تصفير مسبق مفرط
        await _loadUser(firebaseUser.uid);
      } else {
        // تصفير الحالة فقط عند تسجيل الخروج الفعلي
        if (!_initializingAuth) {
          _user = null;
          _errorMessage = null;
          _isLoading = false;
          notifyListeners();
        }
      }
      _initializingAuth = false;
    });
  }

  Future<void> _loadUser(String uid) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // جلب وثيقة المستخدم من Firestore
      final userData = await _userService.getUser(uid);
      
      if (userData != null && (userData.role == 'admin' || userData.role == 'client')) {
        _user = userData;
      } else {
        // إذا لم يوجد مستند أو الدور غير معرف
        _user = null;
        _errorMessage = 'صلاحيات المستخدم غير معرفة في النظام.';
        // لا نسجل الخروج تلقائياً هنا فوراً لمنع الحلقة المفرغة، بل نترك المستخدم يرى الخطأ
      }
    } catch (e) {
      debugPrint('Error loading user data from Firestore: $e');
      _user = null;
      _errorMessage = 'فشل جلب بيانات الصلاحيات من الخادم.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
      _user = null;
      _errorMessage = null;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error during sign out: $e');
    }
  }

  // تصفير الحالة يدوياً عند الحاجة (مثل قبل تسجيل دخول جديد)
  void clearState() {
    _user = null;
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }

  // دالة مساعدة لإعادة تحميل البيانات يدوياً
  Future<void> refresh() async {
    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      await _loadUser(currentUser.uid);
    } else {
      _user = null;
      notifyListeners();
    }
  }
}
