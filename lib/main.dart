import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';
import 'providers/user_state.dart';
import 'screens/admin/admin_dashboard.dart';
import 'screens/client/client_dashboard.dart';
import 'screens/login_screen.dart';
import 'theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  bool firebaseInitialized = false;
  try {
    // التأكد من تهيئة Firebase بالخيارات الصحيحة للمنصة
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    firebaseInitialized = true;
    
    // محاولة إنشاء الأدمن فقط إذا نجحت التهيئة
    await _ensureAdminUser();
    
  } catch (e) {
    debugPrint("Firebase Initialization Critical Error: $e");
    // يمكن هنا عرض شاشة خطأ للمستخدم بدلاً من تعليق التطبيق
  }

  runApp(
    ChangeNotifierProvider(
      create: (context) => UserState(),
      child: MyApp(isFirebaseReady: firebaseInitialized),
    ),
  );
}

Future<void> _ensureAdminUser() async {
  // استخدام البريد المحول من الرقم (نفس المنطق المستخدم في AuthService)
  const adminPhone = "781475757";
  const adminEmail = "$adminPhone@mycardproject.app"; 
  const adminPassword = "password123"; 
  
  try {
    // 1. محاولة تسجيل الدخول
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: adminEmail,
      password: adminPassword,
    );
    debugPrint("Admin authenticated successfully.");
  } on FirebaseAuthException catch (e) {
    // 2. إذا لم يكن موجوداً، نقوم بإنشائه
    if (e.code == 'user-not-found' || e.code == 'invalid-credential') {
      try {
        UserCredential cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: adminEmail,
          password: adminPassword,
        );
        
        if (cred.user != null) {
          await FirebaseFirestore.instance.collection('users').doc(cred.user!.uid).set({
            'id': cred.user!.uid,
            'name': 'Admin User',
            'phone': adminPhone,
            'role': 'admin',
            'createdAt': FieldValue.serverTimestamp(),
          });
          debugPrint("New Admin user created.");
        }
      } catch (createError) {
        debugPrint("Failed to create admin: $createError");
      }
    } else {
      debugPrint("Auth Error: ${e.code}");
    }
  } catch (e) {
    debugPrint("General Error in _ensureAdminUser: $e");
  }
}

class MyApp extends StatelessWidget {
  final bool isFirebaseReady;
  const MyApp({super.key, required this.isFirebaseReady});

  @override
  Widget build(BuildContext context) {
    if (!isFirebaseReady) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: appTheme,
        home: const Scaffold(
          body: Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, color: Colors.red, size: 60),
                  SizedBox(height: 20),
                  Text(
                    'خطأ في الاتصال بـ Firebase\nيرجى التحقق من إعدادات الـ API Key وملف google-services.json',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Consumer<UserState>(
      builder: (context, userState, child) {
        if (userState.isLoading) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: appTheme,
            home: const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        if (!userState.isAuthenticated) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: appTheme,
            home: const LoginScreen(),
            builder: _errorWidgetBuilder,
          );
        }

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: appTheme,
          home: userState.isAdmin ? const AdminDashboard() : const ClientDashboard(),
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
