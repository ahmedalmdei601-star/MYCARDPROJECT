import 'package:flutter/material.dart';

// الألوان الاحترافية المقترحة (Business Style)
// Primary: أزرق داكن (للقوة والثقة)
// Secondary: برتقالي (للطاقة والابتكار)
const Color primaryColor = Color(0xFF003366); // Dark Blue
const Color secondaryColor = Color(0xFFFF9900); // Orange
const Color accentColor = Color(0xFF00CC99); // Teal/Mint for accents
const Color backgroundColor = Color(0xFFF4F7F6); // Light Gray/Off-White
const Color errorColor = Color(0xFFD32F2F); // Red

final ThemeData appTheme = ThemeData(
  // استخدام خط Cairo (يجب التأكد من إضافته في pubspec.yaml)
  fontFamily: 'Cairo',
  
  // الألوان الأساسية
  primaryColor: primaryColor,
  colorScheme: ColorScheme.light(
    primary: primaryColor,
    secondary: secondaryColor,
    error: errorColor,
    background: backgroundColor,
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
    ),
  ),

  // Button Theme
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: secondaryColor,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
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
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Colors.grey, width: 0.5),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: primaryColor, width: 2),
    ),
    labelStyle: const TextStyle(color: primaryColor),
    hintStyle: const TextStyle(color: Colors.grey),
  ),

  // Card Theme
  cardTheme: CardTheme(
    elevation: 4,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
  ),
);
