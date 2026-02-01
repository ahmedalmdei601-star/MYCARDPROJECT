import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../services/user_services.dart';

class UserState extends ChangeNotifier {
  final UserService _userService = UserService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  UserModel? _user;
  bool _isLoadingData = false;
  String? _dataErrorMessage;
  
  Locale _locale = const Locale('ar');
  ThemeMode _themeMode = ThemeMode.light;

  UserModel? get user => _user;
  bool get isLoading => _isLoadingData;
  String? get errorMessage => _dataErrorMessage;
  
  // CRITICAL: Auth state depends ONLY on Firebase Auth current user.
  bool get isAuthenticated => _auth.currentUser != null;
  
  Locale get locale => _locale;
  ThemeMode get themeMode => _themeMode;
  bool get isAdmin => _user?.role == 'admin';
  bool get isClient => _user?.role == 'client';

  UserState() {
    _init();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final langCode = prefs.getString('language_code') ?? 'ar';
    _locale = Locale(langCode);
    final isDark = prefs.getBool('is_dark') ?? false;
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  Future<void> setLocale(Locale locale) async {
    _locale = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', locale.languageCode);
    notifyListeners();
  }

  Future<void> toggleTheme(bool isDark) async {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_dark', isDark);
    notifyListeners();
  }

  void _init() {
    _auth.authStateChanges().listen((firebaseUser) {
      if (firebaseUser != null) {
        _loadUser(firebaseUser.uid);
      } else {
        _user = null;
        _isLoadingData = false;
        notifyListeners();
      }
    });
  }

  // Fetch Firestore data separately. Success/Failure here DOES NOT affect isAuthenticated.
  Future<void> _loadUser(String uid) async {
    _isLoadingData = true;
    _dataErrorMessage = null;
    notifyListeners();
    
    try {
      final userData = await _userService.getUser(uid);
      if (userData != null) {
        _user = userData;
        // Background task: update last login without blocking
        _userService.updateLastLogin(uid).catchError((_) => null);
      } else {
        _dataErrorMessage = "بيانات الحساب غير مكتملة في قاعدة البيانات.";
      }
    } catch (e) {
      _dataErrorMessage = "حدث خطأ أثناء جلب بيانات المستخدم.";
    } finally {
      _isLoadingData = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    _user = null;
    _dataErrorMessage = null;
    notifyListeners();
  }

  void clearState() {
    _user = null;
    _dataErrorMessage = null;
    notifyListeners();
  }

  Future<void> refresh() async {
    if (_auth.currentUser != null) {
      await _loadUser(_auth.currentUser!.uid);
    }
  }
}
