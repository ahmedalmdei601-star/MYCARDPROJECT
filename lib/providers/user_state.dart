import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
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
  
  bool get isAdmin => _user?.role == 'admin';
  bool get isClient => _user?.role == 'client';
  bool get isAuthenticated => _user != null;

  UserState() {
    // الاستماع لحالة المصادقة
    _auth.authStateChanges().listen((firebaseUser) {
      if (firebaseUser != null) {
        _loadUser(firebaseUser.uid);
      } else {
        _user = null;
        _isLoading = false;
        notifyListeners();
      }
    });
  }

  Future<void> _loadUser(String uid) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final userData = await _userService.getUser(uid);
      if (userData != null && (userData.role == 'admin' || userData.role == 'client')) {
        _user = userData;
      } else {
        // إذا لم يوجد مستند أو الدور غير معرف
        _user = null;
        _errorMessage = 'صلاحيات المستخدم غير معرفة. يرجى التواصل مع المسؤول.';
        await _auth.signOut();
      }
    } catch (e) {
      debugPrint('Error loading user data: $e');
      _user = null;
      _errorMessage = 'حدث خطأ أثناء جلب بيانات الصلاحيات.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();
    try {
      await _auth.signOut();
      _user = null;
      _errorMessage = null;
    } catch (e) {
      debugPrint('Error during sign out: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
