import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Background - Deep rich purple-black to complement logo
  static const Color background = Color(0xFF0D0A14);
  static const Color surface = Color(0xFF1A1326);
  static const Color surfaceElevated = Color(0xFF241D35);

  // Sidebar & Navbar - Deep purple tones matching logo
  static const Color sidebar = Color(0xFF140F1C);
  static const Color navbar = Color(0xFF181223);

  // Primary - Deep purple from logo (#470E6F)
  static const Color primary = Color(0xFF5A1A8F);
  static const Color primaryLight = Color(0xFF722590);
  static const Color primaryDark = Color(0xFF470E6F);

  // Secondary - Vibrant orange/yellow from logo (#F19B21, #FDC90A)
  static const Color secondary = Color(0xFFF19B21);
  static const Color secondaryLight = Color(0xFFFDC90A);
  static const Color secondaryDark = Color(0xFFE5890F);

  // Accent - Purple gradient from logo
  static const Color accent = Color(0xFF8230AA);
  static const Color accentLight = Color(0xFF9B3FC4);

  // Status colors - Harmonious with theme
  static const Color success = Color(0xFF22C55E);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFFDC90A);
  static const Color info = Color(0xFF722590);

  // Text
  static const Color textPrimary = Color(0xFFFAFAFA);
  static const Color textSecondary = Color(0xFFE0D4EB);
  static const Color textMuted = Color(0xFF9B8FA8);

  // Gradients for buttons and accents
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [secondary, secondaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient logoGradient = LinearGradient(
    colors: [primaryDark, primary, accent, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
