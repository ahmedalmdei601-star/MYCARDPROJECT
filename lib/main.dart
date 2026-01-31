import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'providers/user_state.dart';
import 'providers/card_state.dart';
import 'screens/login_screen.dart';
import 'screens/admin/admin_dashboard.dart';
import 'screens/client/client_dashboard.dart';
import 'theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint("Firebase initialized successfully");
  } catch (e) {
    debugPrint("Firebase Initialization error: $e");
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserState()),
        ChangeNotifierProvider(create: (_) => CardState()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'تطبيق إدارة الكروت',
      debugShowCheckedModeBanner: false,
      theme: appTheme,
      home: const RootScreen(),
      builder: _errorWidgetBuilder,
    );
  }
}

class RootScreen extends StatelessWidget {
  const RootScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userState = Provider.of<UserState>(context);

    // 1. إذا كان التطبيق في حالة تحميل البيانات
    if (userState.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // 2. فرض شاشة تسجيل الدخول عند التشغيل لأول مرة أو عند طلب تسجيل دخول يدوي
    if (userState.requireManualLogin || !userState.isAuthenticated) {
      return const LoginScreen();
    }

    // 3. التوجيه بناءً على الدور (Role) بعد نجاح تسجيل الدخول اليدوي
    if (userState.isAdmin) {
      return const AdminDashboard();
    }

    if (userState.isClient) {
      return const ClientDashboard();
    }

    // 4. حالة احتياطية إذا كان مسجلاً ولكن لا توجد بيانات في Firestore
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text(
                'خطأ في جلب بيانات الصلاحيات.\nيرجى التواصل مع الإدارة.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, fontFamily: 'Cairo'),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => userState.signOut(),
                child: const Text('العودة لتسجيل الدخول'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _errorWidgetBuilder(BuildContext context, Widget? widget) {
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            'حدث خطأ غير متوقع:\n${details.exception}',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.red),
          ),
        ),
      ),
    );
  };
  return widget!;
}
