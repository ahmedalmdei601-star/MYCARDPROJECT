import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/user_services.dart';

class UserState extends ChangeNotifier {
  final UserService _userService = UserService();
  UserModel? _user;
  bool _isLoading = true;

  // خصائص اللغة والوضع الداكن
  Locale _locale = const Locale('ar');
  ThemeMode _themeMode = ThemeMode.light;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAdmin => _user?.role == 'admin';
  bool get isClient => _user?.role == 'client';
  bool get isAuthenticated => _user != null;
  
  Locale get locale => _locale;
  ThemeMode get themeMode => _themeMode;

  UserState() {
    _auth.authStateChanges().listen((user) {
      if (user != null) {
        _loadUser(user.uid);
      } else {
        _user = null;
        _isLoading = false;
        notifyListeners();
      }
    });
  }

  static final FirebaseAuth _auth = FirebaseAuth.instance;

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

  // دالة تبديل اللغة
  void toggleLanguage() {
    if (_locale.languageCode == 'ar') {
      _locale = const Locale('en');
    } else {
      _locale = const Locale('ar');
    }
    notifyListeners();
  }

  // دالة تبديل الوضع (داكن/فاتح)
  void toggleTheme(bool isDark) {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  Future<void> reloadUser() async {
    if (_auth.currentUser != null) {
      await _loadUser(_auth.currentUser!.uid);
    }
  }

  Future<void> loadUserData() async {
    if (_auth.currentUser != null) {
      await _loadUser(_auth.currentUser!.uid);
    }
  }

  Future<void> signOut() async {
    await AuthService.signOut();
    _user = null;
    notifyListeners();
  }
}
