//-------------------------------------------------------------------------------------
// Theme LightTheme & Darktheme
//-------------------------------------------------------------------------------------
import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryRed = Color(0xFFE74C3C);
  //------------------------
  // LightTheme
  //------------------------
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: Colors.white,
    primaryColor: Colors.red,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.red,
      brightness: Brightness.light,
      ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryRed,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(30)),
        padding: const EdgeInsets.symmetric(vertical: 16),
      )
    )
  );
  //------------------------
  // DarkTheme
  //------------------------
  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF121212),
    primaryColor: primaryRed,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryRed,
      brightness: Brightness.dark,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryRed,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
    ),
  );
  
}
