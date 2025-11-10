import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'design_tokens.dart';

class AppTheme {
  const AppTheme({required this.primaryColor});

  final Color primaryColor;

  ThemeData buildLightTheme() {
    final base = ThemeData.light(useMaterial3: false);
    final textTheme = GoogleFonts.urbanistTextTheme(base.textTheme).copyWith(
      displayLarge: GoogleFonts.urbanist(
        fontSize: DesignTokens.display,
        fontWeight: FontWeight.w700,
        color: DesignTokens.textPrimary,
      ),
      headlineLarge: GoogleFonts.urbanist(
        fontSize: DesignTokens.h1,
        fontWeight: FontWeight.w700,
        color: DesignTokens.textPrimary,
      ),
      headlineMedium: GoogleFonts.inter(
        fontSize: DesignTokens.h2,
        fontWeight: FontWeight.w600,
        color: DesignTokens.textPrimary,
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: DesignTokens.body,
        fontWeight: FontWeight.w500,
        color: DesignTokens.textPrimary,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: DesignTokens.body,
        color: DesignTokens.textSecondary,
      ),
      labelSmall: GoogleFonts.inter(
        fontSize: DesignTokens.caption,
        color: DesignTokens.textSecondary,
      ),
    );

    return base.copyWith(
      colorScheme: ColorScheme.light(
        primary: primaryColor,
        secondary: DesignTokens.accentSky,
        surface: DesignTokens.surface,
        background: DesignTokens.surfaceAlt,
        onPrimary: Colors.white,
        onSurface: DesignTokens.textPrimary,
      ),
      scaffoldBackgroundColor: DesignTokens.surfaceAlt,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        elevation: 0,
        backgroundColor: DesignTokens.surfaceAlt,
        foregroundColor: DesignTokens.textPrimary,
      ),
      cardTheme: CardTheme(
        color: DesignTokens.surface,
        elevation: DesignTokens.elevationCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
        ),
      ),
      dividerColor: DesignTokens.divider,
      useMaterial3: false,
    );
  }

  ThemeData buildDarkTheme() {
    final base = ThemeData.dark(useMaterial3: false);
    final textTheme = GoogleFonts.ibmPlexSansArabicTextTheme(
      GoogleFonts.urbanistTextTheme(base.textTheme),
    ).copyWith(
      displayLarge: GoogleFonts.urbanist(
        fontSize: DesignTokens.display,
        fontWeight: FontWeight.w700,
        color: DesignTokens.darkText,
      ),
    );

    return base.copyWith(
      colorScheme: ColorScheme.dark(
        primary: primaryColor,
        secondary: DesignTokens.accentLime,
        surface: DesignTokens.darkSurface,
        background: DesignTokens.darkBg,
        onSurface: DesignTokens.darkText,
        onPrimary: Colors.white,
      ),
      scaffoldBackgroundColor: DesignTokens.darkBg,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        elevation: 0,
        backgroundColor: DesignTokens.darkBg,
        foregroundColor: DesignTokens.darkText,
      ),
      cardTheme: CardTheme(
        color: DesignTokens.darkSurface,
        elevation: DesignTokens.elevationCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
        ),
      ),
      dividerColor: DesignTokens.divider.withOpacity(0.15),
      useMaterial3: false,
    );
  }
}
