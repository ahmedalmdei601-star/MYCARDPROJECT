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
      
      // Theme Settings
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
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: primaryColor),
          ),
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

      // Localization Settings
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

    if (userState.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: primaryColor)),
      );
    }

    if (!userState.isAuthenticated) {
      return const LoginScreen();
    }

    if (userState.isAdmin) {
      return const AdminDashboard();
    } else if (userState.isClient) {
      return const ClientDashboard();
    } else {
      return const LoginScreen();
    }
  }
}
