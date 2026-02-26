import 'package:fitflow/utils/extensions/color_extension.dart';
import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  ///Light mode colors
  static const Color primaryColor = Color(
    0xFF1E88E5,
  ); // Blue - main primary theme color
  static const Color secondaryColor = Color(
    0xffffffff,
  ); //This would be card background color and fields background color
  static const Color backgroundColor = Color(0xFFF8FAFC); // Slate-50
  static const Color borderColor = Color(0xFFE2E8F0); // Slate-200
  static const Color errorColor = Color(0xffDB3D26);

  ///Dark mode colors
  static const Color darkPrimaryColor = Color(0xFF1E88E5); // Blue (same as light)
  static const Color darkSecondaryColor = Color(0xFF1E293B); // Slate-800 surface
  static const Color darkBackgroundColor = Color(0xFF0F172A); // Navy (matches website)
  static const Color darkBorderColor = Color(0xFF334155); // Slate-700
  static const Color darkErrorColor = Color(0xffDB3D26);

  ///Accent colors
  static const Color accentColor = Color(0xFFD4AF37); // Gold
  static const Color darkAccentColor = Color(0xFFD4AF37); // Gold (same in dark)

  ///Custom constant colors
  static const Color infoColor = Color(0xff0186D8);
  static const Color warningColor = Color(0xffE29512);
  static const Color darkColor = Color(0xff000000);
  static const Color successColor = Color(0xff34A853);
}

extension ThemeExtension on ColorScheme {
  Color get info => AppColors.infoColor;
  Color get warning => AppColors.warningColor;
  Color get success => AppColors.successColor;
  Color get darkColor => brightness == .dark
      ? AppColors.darkColor.getAdaptiveTextColor()
      : AppColors.darkColor;
}
