import 'package:flutter/material.dart';

// الألوان الرسمية للهوية البصرية الجديدة (Green Brand Style)
const Color primaryColor = Color(0xFF2E7D32); // Green (اللون الأساسي)
const Color secondaryColor = Color(0xFF4CAF50); // Light Green
const Color accentColor = Color(0xFF81C784); // Accent Green
const Color backgroundColor = Color(0xFFF8FAF9); // Off-White (خلفية فاتحة جداً)
const Color errorColor = Color(0xFFD32F2F); // Red
const Color cardColor = Colors.white;

final ThemeData appTheme = ThemeData(
  useMaterial3: true,
  fontFamily: 'Cairo',

  // الألوان الأساسية
  primaryColor: primaryColor,
  colorScheme: ColorScheme.light(
    primary: primaryColor,
    secondary: secondaryColor,
    surface: cardColor,
    error: errorColor,
    onPrimary: Colors.white,
    onSecondary: Colors.white,
  ),
  scaffoldBackgroundColor: backgroundColor,

  // AppBar Theme
  appBarTheme: const AppBarTheme(
    backgroundColor: primaryColor,
    foregroundColor: Colors.white,
    elevation: 0,
    centerTitle: true,
    titleTextStyle: TextStyle(
      fontFamily: 'Cairo',
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
    iconTheme: IconThemeData(color: Colors.white),
  ),

  // Button Theme
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      textStyle: const TextStyle(
        fontFamily: 'Cairo',
        fontWeight: FontWeight.bold,
        fontSize: 16,
      ),
    ),
  ),

  // Input Decoration Theme
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: Colors.grey, width: 0.2),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: primaryColor, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: errorColor, width: 1),
    ),
    labelStyle: const TextStyle(color: Colors.grey, fontFamily: 'Cairo'),
    hintStyle: const TextStyle(color: Colors.grey, fontFamily: 'Cairo'),
  ),

  // Card Theme
  cardTheme: CardTheme(
    color: cardColor,
    elevation: 2,
    shadowColor: Colors.black.withOpacity(0.1),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
    ),
    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
  ),

  // Text Theme
  textTheme: const TextTheme(
    headlineMedium: TextStyle(
      fontFamily: 'Cairo',
      fontWeight: FontWeight.bold,
      color: Colors.black87,
    ),
    titleLarge: TextStyle(
      fontFamily: 'Cairo',
      fontWeight: FontWeight.bold,
      color: Colors.black87,
    ),
    bodyLarge: TextStyle(
      fontFamily: 'Cairo',
      color: Colors.black87,
    ),
    bodyMedium: TextStyle(
      fontFamily: 'Cairo',
      color: Colors.black54,
    ),
  ),
);
