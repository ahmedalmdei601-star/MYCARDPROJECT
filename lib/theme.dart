import 'package:flutter/material.dart';

// ===== Brand Colors (Green Style) =====
const Color primaryColor = Color(0xFF2E7D32);
const Color secondaryColor = Color(0xFF4CAF50);
const Color accentColor = Color(0xFF81C784);
const Color backgroundColor = Color(0xFFF8FAF9);
const Color errorColor = Color(0xFFD32F2F);
const Color cardColor = Colors.white;

final ThemeData appTheme = ThemeData(
  useMaterial3: true,
  fontFamily: 'Cairo',

  // ===== Colors =====
  colorScheme: ColorScheme.fromSeed(
    seedColor: primaryColor,
    primary: primaryColor,
    secondary: secondaryColor,
    surface: cardColor,
    error: errorColor,
    onPrimary: Colors.white,
    onSecondary: Colors.white,
  ),

  scaffoldBackgroundColor: backgroundColor,

  // ===== AppBar =====
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

  // ===== Buttons =====
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

  // ===== Inputs =====
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
      borderSide: BorderSide(color: Colors.grey, width: 0.3),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: primaryColor, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: errorColor, width: 1),
    ),
    labelStyle: const TextStyle(fontFamily: 'Cairo', color: Colors.grey),
    hintStyle: const TextStyle(fontFamily: 'Cairo', color: Colors.grey),
  ),

  // ===== Cards (FIXED ✅) =====
  cardTheme: const CardThemeData(
    color: cardColor,
    elevation: 2,
    shadowColor: Colors.black12,
    margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(20)),
    ),
  ),

  // ===== Text =====
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