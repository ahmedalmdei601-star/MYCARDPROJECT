import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'screens/home_screen.dart';
import 'package:provider/provider.dart';
import 'providers/user_state.dart';
import 'screens/admin/admin_dashboard.dart';
import 'screens/client/client_dashboard.dart';
import 'screens/login_screen.dart';
import 'theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    
    // إنشاء حساب الأدمن تلقائياً إذا لم يكن موجوداً
    await _ensureAdminUser();
    
  } catch (e) {
    debugPrint("Firebase Initialization error: $e");
  }

  runApp(
    ChangeNotifierProvider(
      create: (context) => UserState(),
      child: const MyApp(),
    ),
  );
}

Future<void> _ensureAdminUser() async {
  const adminEmail = "781475757@mycard.project.app"; // البريد الإلكتروني المحول من الرقم
  const adminPassword = "password123"; // كلمة مرور افتراضية للأدمن
  
  try {
    // محاولة تسجيل الدخول للتأكد من وجود الحساب
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: adminEmail,
      password: adminPassword,
    );
    print("Admin user already exists.");
  } on FirebaseAuthException catch (e) {
    if (e.code == 'user-not-found' || e.code == 'invalid-credential' || e.code == 'wrong-password') {
      try {
        // إنشاء الحساب في Auth
        UserCredential cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: adminEmail,
          password: adminPassword,
        );
        
        // إضافة البيانات في Firestore
        if (cred.user != null) {
          await FirebaseFirestore.instance.collection('users').doc(cred.user!.uid).set({
            'id': cred.user!.uid,
            'name': 'Admin User',
            'phone': '781475757',
            'role': 'admin',
            'createdAt': FieldValue.serverTimestamp(),
          });
          print("Admin user created successfully.");
        }
      } catch (createError) {
        print("Error creating admin: $createError");
      }
    }
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<UserState>(
      builder: (context, userState, child) {
        // 1. Loading State
        if (userState.isLoading) {
          return MaterialApp(
            title: 'إدارة الكروت',
            debugShowCheckedModeBanner: false,
            theme: appTheme,
            home: const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        // 2. Not Authenticated State (Login Screen)
        if (!userState.isAuthenticated) {
          return MaterialApp(
            title: 'إدارة الكروت',
            debugShowCheckedModeBanner: false,
            theme: appTheme,
            home: const LoginScreen(),
            builder: _errorWidgetBuilder,
          );
        }

        // 3. Admin State
        if (userState.isAdmin) {
          return MaterialApp(
            title: 'إدارة الكروت - الأدمن',
            debugShowCheckedModeBanner: false,
            theme: appTheme,
            home: const AdminDashboard(),
            builder: _errorWidgetBuilder,
          );
        }

        // 4. Client State
        return MaterialApp(
          title: 'إدارة الكروت - البقالة',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primarySwatch: Colors.blue,
            useMaterial3: true,
          ),
          home: const ClientDashboard(),
          builder: _errorWidgetBuilder,
        );
      },
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
            'حدث خطأ غير متوقع: ${details.exception}',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.red),
          ),
        ),
      ),
    );
  };
  return widget!;
}
}
