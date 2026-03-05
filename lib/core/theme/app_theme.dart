import 'package:fitflow/core/constants/app_colors.dart';
import 'package:fitflow/utils/extensions/color_extension.dart';
import 'package:flutter/material.dart';

class AppTheme {
  ThemeData theme;
  AppTheme(this.theme);
  bool isDarkMode = false;
  static const String fontFamily = 'Geist';

  // Helper method to create text theme
  static TextTheme _createTextTheme() {
    return const TextTheme(
      displayLarge: TextStyle(
        fontFamily: fontFamily, 
        fontSize: 57, 
        fontWeight: FontWeight.w800, 
        height: 1.12
      ),
      displayMedium: TextStyle(
        fontFamily: fontFamily, 
        fontSize: 45, 
        fontWeight: FontWeight.w800, 
        height: 1.16
      ),
      displaySmall: TextStyle(
        fontFamily: fontFamily, 
        fontSize: 36, 
        fontWeight: FontWeight.w700, 
        height: 1.22
      ),
      headlineLarge: TextStyle(
        fontFamily: fontFamily, 
        fontSize: 32, 
        fontWeight: FontWeight.w800, 
        height: 1.25
      ),
      headlineMedium: TextStyle(
        fontFamily: fontFamily, 
        fontSize: 28, 
        fontWeight: FontWeight.w800, 
        height: 1.29
      ),
      headlineSmall: TextStyle(
        fontFamily: fontFamily, 
        fontSize: 24, 
        fontWeight: FontWeight.w700, 
        height: 1.33
      ),
      titleLarge: TextStyle(
        fontFamily: fontFamily, 
        fontSize: 22, 
        fontWeight: FontWeight.w700, 
        height: 1.27
      ),
      titleMedium: TextStyle(
        fontFamily: fontFamily, 
        fontSize: 16, 
        fontWeight: FontWeight.w700, 
        height: 1.50
      ),
      titleSmall: TextStyle(
        fontFamily: fontFamily, 
        fontSize: 14, 
        fontWeight: FontWeight.w700, 
        height: 1.43
      ),
      bodyLarge: TextStyle(
        fontFamily: fontFamily, 
        fontSize: 16, 
        fontWeight: FontWeight.w500, 
        height: 1.50
      ),
      bodyMedium: TextStyle(
        fontFamily: fontFamily, 
        fontSize: 14, 
        fontWeight: FontWeight.w500, 
        height: 1.43
      ),
      bodySmall: TextStyle(
        fontFamily: fontFamily, 
        fontSize: 12, 
        fontWeight: FontWeight.w500, 
        height: 1.33
      ),
      labelLarge: TextStyle(
        fontFamily: fontFamily, 
        fontSize: 14, 
        fontWeight: FontWeight.w700, 
        height: 1.43
      ),
      labelMedium: TextStyle(
        fontFamily: fontFamily, 
        fontSize: 12, 
        fontWeight: FontWeight.w700, 
        height: 1.33
      ),
      labelSmall: TextStyle(
        fontFamily: fontFamily, 
        fontSize: 11, 
        fontWeight: FontWeight.w700, 
        height: 1.45
      ),
    );
  }

  factory AppTheme.light(BuildContext context) {
    return AppTheme(ThemeData(
      fontFamily: fontFamily,
      useMaterial3: true,
      textTheme: _createTextTheme(),
      scaffoldBackgroundColor: AppColors.backgroundColor,
      colorScheme: const ColorScheme.light().copyWith(
          primary: AppColors.primaryColor,
          secondary: AppColors.accentColor,
          tertiary: AppColors.premiumGold,
          surface: AppColors.secondaryColor,
          outline: AppColors.borderColor,
          error: AppColors.errorColor,
          onError: AppColors.secondaryColor),
      dividerTheme: const DividerThemeData(color: AppColors.borderColor),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.backgroundColor,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: Color(0xFF0F172A),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: AppColors.borderColor, width: 0.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontFamily: fontFamily,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF1F5F9),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryColor, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.primaryColor,
        unselectedItemColor: Color(0xFF94A3B8),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    ))
      ..isDarkMode = false;
  }

  factory AppTheme.dark(BuildContext context) {
    return AppTheme(ThemeData(
      fontFamily: fontFamily,
      useMaterial3: true,
      textTheme: _createTextTheme(),
      scaffoldBackgroundColor: AppColors.darkBackgroundColor,
      dividerTheme: const DividerThemeData(color: AppColors.darkBorderColor),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkBackgroundColor,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: AppColors.darkBorderColor, width: 0.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.darkPrimaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontFamily: fontFamily,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF1E293B),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.darkPrimaryColor, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.darkSecondaryColor,
        selectedItemColor: AppColors.darkPrimaryColor,
        unselectedItemColor: const Color(0xFF64748B),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      colorScheme: const ColorScheme.dark().copyWith(
          primary: AppColors.darkPrimaryColor,
          secondary: AppColors.darkAccentColor,
          tertiary: AppColors.premiumGold,
          surface: AppColors.darkBackgroundColor.brighten(0.06),
          outline: AppColors.darkBorderColor,
          error: AppColors.darkErrorColor,
          onError: AppColors.secondaryColor),
    ))
      ..isDarkMode = true;
  }
}