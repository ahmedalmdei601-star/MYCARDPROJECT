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
  
  // فرض تسجيل الدخول اليدوي دائماً عند تشغيل التطبيق
  bool _requireManualLogin = true;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAdmin => _user?.role == 'admin';
  bool get isClient => _user?.role == 'client';
  
  // لا يتم اعتبار المستخدم authenticated إلا إذا تمت المصادقة يدوياً
  bool get isAuthenticated => _user != null && !_requireManualLogin;
  bool get requireManualLogin => _requireManualLogin;

  UserState() {
    // الاستماع لحالة المصادقة من Firebase
    _auth.authStateChanges().listen((firebaseUser) async {
      if (firebaseUser != null) {
        await _loadUser(firebaseUser.uid);
      } else {
        // عند تسجيل الخروج أو عدم وجود مستخدم
        _user = null;
        _isLoading = false;
        _requireManualLogin = true; // إعادة الضبط عند الخروج
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

  // دالة لتأكيد نجاح تسجيل الدخول اليدوي (يتم استدعاؤها بعد AuthService.login)
  Future<void> setManualLoginSuccess(String uid) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      // التأكد من تحميل أحدث البيانات من Firestore فوراً
      _user = await _userService.getUser(uid);
      _requireManualLogin = false;
    } catch (e) {
      debugPrint('Error during manual login sync: $e');
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
      _requireManualLogin = true;
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
      _requireManualLogin = true;
      notifyListeners();
    }
  }
}
