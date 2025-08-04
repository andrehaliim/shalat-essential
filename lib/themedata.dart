import 'package:flutter/material.dart';

import 'colors.dart';

// Dark THEME
final ThemeData appDarkTheme = ThemeData(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: AppColors.background,
  primaryColor: AppColors.highlightBlue,
  cardColor: AppColors.cardBackground,
  dividerColor: AppColors.borderColor,
  iconTheme: const IconThemeData(color: AppColors.primaryText),
  textTheme: const TextTheme(
    headlineLarge: TextStyle(color: AppColors.primaryText, fontSize: 28, fontWeight: FontWeight.bold),
    headlineMedium: TextStyle(color: AppColors.primaryText, fontSize: 22),
    bodyLarge: TextStyle(color: AppColors.secondaryText, fontSize: 16),
    bodyMedium: TextStyle(color: AppColors.secondaryText, fontSize: 14),
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.background,
    iconTheme: IconThemeData(color: AppColors.primaryText),
    titleTextStyle: TextStyle(color: AppColors.primaryText, fontSize: 20),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.buttonBackground,
      foregroundColor: AppColors.primaryText,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  ),
);

// LIGHT THEME
final ThemeData appLightTheme = ThemeData(
  brightness: Brightness.light,
  scaffoldBackgroundColor: Colors.white,
  primaryColor: AppColors.highlightBlue,
  cardColor: const Color(0xFFF3F6F9),
  dividerColor: Colors.grey.shade300,
  iconTheme: const IconThemeData(color: Colors.black87),
  textTheme: const TextTheme(
    headlineLarge: TextStyle(color: Colors.black, fontSize: 28, fontWeight: FontWeight.bold),
    headlineMedium: TextStyle(color: Colors.black87, fontSize: 22),
    bodyLarge: TextStyle(color: Colors.black54, fontSize: 16),
    bodyMedium: TextStyle(color: Colors.black45, fontSize: 14),
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.white,
    iconTheme: IconThemeData(color: Colors.black),
    titleTextStyle: TextStyle(color: Colors.black, fontSize: 20),
    elevation: 1,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.highlightBlue,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  ),
);

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode =>
      _themeMode == ThemeMode.dark ||
          (_themeMode == ThemeMode.system &&
              WidgetsBinding.instance.window.platformBrightness == Brightness.dark);

  void toggleTheme() {
    _themeMode = isDarkMode ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
  }
}
