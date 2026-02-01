import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../services/user_services.dart';

class UserState extends ChangeNotifier {
  final UserService _userService = UserService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  UserModel? _user;
  bool _isLoading = true;
  String? _errorMessage;
  
  // لغة التطبيق والسمة
  Locale _locale = const Locale('ar');
  ThemeMode _themeMode = ThemeMode.light;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _auth.currentUser != null; // Use Firebase Auth as the source of truth for auth
  Locale get locale => _locale;
  ThemeMode get themeMode => _themeMode;
  bool get isAdmin => _user?.role == 'admin';
  bool get isClient => _user?.role == 'client';

  UserState() {
    _init();
    _loadPreferences();
  }

  // تحميل تفضيلات المستخدم (اللغة والمظهر)
  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    
    // اللغة
    final langCode = prefs.getString('language_code') ?? 'ar';
    _locale = Locale(langCode);
    
    // المظهر
    final isDark = prefs.getBool('is_dark') ?? false;
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    
    notifyListeners();
  }

  // تغيير اللغة وحفظها
  Future<void> setLocale(Locale locale) async {
    _locale = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', locale.languageCode);
    notifyListeners();
  }

  // تغيير المظهر وحفظه
  Future<void> toggleTheme(bool isDark) async {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_dark', isDark);
    notifyListeners();
  }

  // الاستماع لتغيرات حالة المصادقة
  void _init() {
    _auth.authStateChanges().listen((firebaseUser) async {
      if (firebaseUser != null) {
        await _loadUser(firebaseUser.uid);
      } else {
        _user = null;
        _isLoading = false;
        notifyListeners();
      }
    });
  }

  // جلب بيانات المستخدم من Firestore
  Future<void> _loadUser(String uid) async {
    _isLoading = true;
    notifyListeners();
    try {
      final userData = await _userService.getUser(uid);
      if (userData != null) {
        _user = userData;
        _errorMessage = null;
      } else {
        // If doc doesn't exist in Firestore but exists in Auth, we might need to handle it
        _user = null;
        _errorMessage = "بيانات المستخدم غير موجودة في قاعدة البيانات.";
      }
    } catch (e) {
      // Don't nullify _user if it's just a temporary fetch error, 
      // but here it's safer to clear to avoid showing wrong data.
      _errorMessage = "خطأ في تحميل البيانات: $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // تسجيل الخروج
  Future<void> signOut() async {
    await _auth.signOut();
    _user = null;
    _errorMessage = null;
    notifyListeners();
  }

  // تصفير الحالة يدوياً (للتأكيد قبل تسجيل دخول جديد)
  void clearState() {
    _user = null;
    _errorMessage = null;
    // We don't set _isLoading = true here to avoid showing spinner on login screen
    notifyListeners();
  }

  // تحديث بيانات المستخدم الحالي
  Future<void> refresh() async {
    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      await _loadUser(currentUser.uid);
    }
  }
}
