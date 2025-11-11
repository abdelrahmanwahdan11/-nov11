import 'package:flutter/material.dart';

class DesignTokens {
  DesignTokens._();

  static const Color primaryDefault = Color(0xFF0A0A0A);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceAlt = Color(0xFFF6F7F9);
  static const Color accentLime = Color(0xFFC9FF4D);
  static const Color accentSky = Color(0xFFBDE6FF);
  static const Color textPrimary = Color(0xFF0B0B0B);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color divider = Color(0xFFE5E7EB);
  static const Color darkBg = Color(0xFF0C0C0E);
  static const Color darkSurface = Color(0xFF151518);
  static const Color darkText = Color(0xFFECECEC);

  static const Color defaultPrimary = accentLime;

  static const List<Color> primaryPalette = <Color>[
    accentLime,
    accentSky,
    Color(0xFFFFC857),
    Color(0xFF9FA8DA),
    Color(0xFF6EE7B7),
  ];

  static const double radiusXl = 28;
  static const double radiusLg = 20;
  static const double radiusMd = 14;

  static const double elevationCard = 12;
  static const double elevationOverlay = 24;

  static const List<double> spacing = [8, 12, 16, 20, 24, 32];

  static const display = 40.0;
  static const h1 = 32.0;
  static const h2 = 24.0;
  static const body = 16.0;
  static const caption = 12.0;

  static Color colorContrastFor(Color background) {
    final luminance = background.computeLuminance();
    return luminance > 0.55 ? Colors.black : Colors.white;
  }
}
