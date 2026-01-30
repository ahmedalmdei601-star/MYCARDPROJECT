import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'screens/home_screen.dart';

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

  runApp(const MyApp());
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
    return MaterialApp(
      title: 'إدارة الكروت',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const HomeScreen(),
      builder: (context, widget) {
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
      },
    );
  }
}
