import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/user_services.dart';
import '../models/user_model.dart';
import 'login_screen.dart';
import 'admin/admin_dashboard.dart';
import 'client/client_dashboard.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _loading = true;
  UserModel? _user;

  @override
  void initState() {
    super.initState();
    // استخدام WidgetsBinding للتأكد من أن السياق (context) جاهز قبل التنقل
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserData();
    });
  }

  Future<void> _loadUserData() async {
    try {
      final currentUser = AuthService.currentUser;
      if (currentUser == null) {
        _goToLogin();
        return;
      }

      final userService = UserService();
      final user = await userService.getUser(currentUser.uid);
      
      if (user == null) {
        await AuthService.signOut();
        _goToLogin();
        return;
      }

      if (mounted) {
        setState(() {
          _user = user;
          _loading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading user data: $e');
      _goToLogin();
    }
  }

  void _goToLogin() {
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    // إذا كان لا يزال يحمل، نعرض مؤشر تحميل بدلاً من شاشة سوداء
    if (_loading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 20),
              Text('جاري التحميل...', style: TextStyle(fontFamily: 'Cairo')),
            ],
          ),
        ),
      );
    }

    // التحقق من وجود المستخدم قبل عرض لوحة التحكم
    if (_user == null) {
      return const LoginScreen();
    }

    if (_user!.role == 'admin') {
      return const AdminDashboard();
    } else {
      return const ClientDashboard();
    }
  }
}
