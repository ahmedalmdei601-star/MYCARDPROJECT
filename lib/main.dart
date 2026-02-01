import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'firebase_options.dart';
import 'providers/user_state.dart';
import 'providers/card_state.dart';
import 'screens/login_screen.dart';
import 'screens/admin/admin_dashboard.dart';
import 'screens/client/client_dashboard.dart';
import 'theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

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
    final userState = Provider.of<UserState>(context);

    return MaterialApp(
      title: 'MyCard',
      debugShowCheckedModeBanner: false,
      themeMode: userState.themeMode,
      theme: ThemeData(
        useMaterial3: true,
        primarySwatch: Colors.green,
        colorScheme: ColorScheme.fromSeed(seedColor: primaryColor),
        scaffoldBackgroundColor: backgroundColor,
        fontFamily: 'Cairo',
        appBarTheme: const AppBarTheme(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          centerTitle: true,
          elevation: 0,
        ),
      ),
      darkTheme: ThemeData.dark().copyWith(
        primaryColor: primaryColor,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryColor, 
          brightness: Brightness.dark
        ),
        textTheme: ThemeData.dark().textTheme.apply(fontFamily: 'Cairo'),
      ),
      locale: userState.locale,
      supportedLocales: const [
        Locale('ar', ''),
        Locale('en', ''),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const RootScreen(),
    );
  }
}

class RootScreen extends StatelessWidget {
  const RootScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userState = Provider.of<UserState>(context);

    // 1. If not authenticated in Firebase Auth, ALWAYS show LoginScreen.
    if (!userState.isAuthenticated) {
      return const LoginScreen();
    }

    // 2. If authenticated but Firestore data is still loading or missing, show Loading/Error.
    // This state is reached ONLY if Firebase Auth success is true.
    if (userState.isLoading || userState.user == null) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(color: primaryColor),
                const SizedBox(height: 24),
                Text(
                  userState.locale.languageCode == 'ar' ? 'جاري جلب بيانات الحساب...' : 'Fetching account data...',
                  style: const TextStyle(fontSize: 16),
                ),
                if (userState.errorMessage != null) ...[
                  const SizedBox(height: 24),
                  Text(
                    userState.errorMessage!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => userState.refresh(),
                    child: Text(userState.locale.languageCode == 'ar' ? 'إعادة المحاولة' : 'Retry'),
                  ),
                  TextButton(
                    onPressed: () => userState.signOut(),
                    child: Text(userState.locale.languageCode == 'ar' ? 'تسجيل الخروج' : 'Logout'),
                  ),
                ]
              ],
            ),
          ),
        ),
      );
    }

    // 3. Role-based navigation once data is ready.
    if (userState.isAdmin) {
      return const AdminDashboard();
    } else if (userState.isClient) {
      return const ClientDashboard();
    } else {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.warning_amber_rounded, size: 64, color: Colors.orange),
              const SizedBox(height: 16),
              const Text('Unknown Role', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('Your account has no assigned role.'),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => userState.signOut(),
                child: const Text('Logout'),
              ),
            ],
          ),
        ),
      );
    }
  }
}
