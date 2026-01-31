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

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAdmin => _user?.role == 'admin';
  bool get isClient => _user?.role == 'client';
  bool get isAuthenticated => _user != null;

  UserState() {
    // الاستماع لحالة المصادقة من Firebase
    _auth.authStateChanges().listen((firebaseUser) {
      if (firebaseUser != null) {
        _loadUser(firebaseUser.uid);
      } else {
        // عند تسجيل الخروج أو عدم وجود مستخدم
        _user = null;
        _isLoading = false;
        notifyListeners();
      }
    });
  }

  Future<void> _loadUser(String uid) async {
    _isLoading = true;
    notifyListeners();
    try {
      _user = await _userService.getUser(uid);
    } catch (e) {
      debugPrint('Error loading user data: $e');
      _user = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // دالة تسجيل الخروج التي تعيد ضبط كل شيء
  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();
    try {
      await AuthService.signOut();
      _user = null;
    } catch (e) {
      debugPrint('Error during sign out: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // لتحميل البيانات يدوياً إذا لزم الأمر
  Future<void> loadUserData() async {
    if (_auth.currentUser != null) {
      await _loadUser(_auth.currentUser!.uid);
    } else {
      _user = null;
      _isLoading = false;
      notifyListeners();
    }
  }
}
