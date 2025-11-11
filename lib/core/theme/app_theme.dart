import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'design_tokens.dart';

class AppTheme {
  const AppTheme({required this.primaryColor});

  final Color primaryColor;

  ThemeData buildLightTheme() {
    final base = ThemeData.light(useMaterial3: false);
    final onPrimary = DesignTokens.colorContrastFor(primaryColor);
    final textTheme = GoogleFonts.urbanistTextTheme(base.textTheme).apply(
      bodyColor: DesignTokens.textPrimary,
      displayColor: DesignTokens.textPrimary,
    );
    final labelTheme = GoogleFonts.interTextTheme(base.textTheme).apply(
      bodyColor: DesignTokens.textSecondary,
      displayColor: DesignTokens.textSecondary,
    );
    final mergedTextTheme = textTheme.copyWith(
      displayLarge: textTheme.displayLarge?.copyWith(
        fontSize: DesignTokens.display,
        fontWeight: FontWeight.w700,
      ),
      headlineLarge: textTheme.headlineLarge?.copyWith(
        fontSize: DesignTokens.h1,
        fontWeight: FontWeight.w700,
      ),
      headlineMedium: labelTheme.headlineMedium?.copyWith(
        fontSize: DesignTokens.h2,
        fontWeight: FontWeight.w600,
        color: DesignTokens.textPrimary,
      ),
      bodyLarge: labelTheme.bodyLarge?.copyWith(
        fontSize: DesignTokens.body,
        fontWeight: FontWeight.w500,
        color: DesignTokens.textPrimary,
      ),
      bodyMedium: labelTheme.bodyMedium?.copyWith(
        fontSize: DesignTokens.body,
        color: DesignTokens.textSecondary,
      ),
      labelSmall: labelTheme.labelSmall?.copyWith(
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
        onPrimary: onPrimary,
        onSurface: DesignTokens.textPrimary,
      ),
      scaffoldBackgroundColor: DesignTokens.surfaceAlt,
      textTheme: mergedTextTheme,
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
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: onPrimary,
          minimumSize: const Size.fromHeight(52),
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
      ),
      chipTheme: base.chipTheme.copyWith(
        selectedColor: primaryColor.withOpacity(0.12),
        side: BorderSide(color: primaryColor.withOpacity(0.2)),
        labelStyle: mergedTextTheme.bodyMedium,
      ),
      floatingActionButtonTheme: base.floatingActionButtonTheme.copyWith(
        backgroundColor: primaryColor,
        foregroundColor: onPrimary,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: DesignTokens.surfaceAlt,
        selectedItemColor: primaryColor,
        unselectedItemColor: DesignTokens.textPrimary.withOpacity(0.55),
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
      ),
      dividerColor: DesignTokens.divider,
      useMaterial3: false,
    );
  }

  ThemeData buildDarkTheme() {
    final base = ThemeData.dark(useMaterial3: false);
    final onPrimary = DesignTokens.colorContrastFor(primaryColor);
    final urbanistTheme = GoogleFonts.urbanistTextTheme(base.textTheme).apply(
      bodyColor: DesignTokens.darkText,
      displayColor: DesignTokens.darkText,
    );
    final cairoTheme = GoogleFonts.cairoTextTheme(base.textTheme).apply(
      bodyColor: DesignTokens.darkText,
      displayColor: DesignTokens.darkText,
    );
    final merged = urbanistTheme.copyWith(
      displayLarge: urbanistTheme.displayLarge?.copyWith(
        fontSize: DesignTokens.display,
        fontWeight: FontWeight.w700,
      ),
      headlineLarge: urbanistTheme.headlineLarge?.copyWith(
        fontSize: DesignTokens.h1,
        fontWeight: FontWeight.w700,
      ),
      headlineMedium: cairoTheme.headlineMedium?.copyWith(
        fontSize: DesignTokens.h2,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: cairoTheme.bodyLarge?.copyWith(
        fontSize: DesignTokens.body,
        fontWeight: FontWeight.w500,
      ),
      bodyMedium: cairoTheme.bodyMedium?.copyWith(
        fontSize: DesignTokens.body,
        color: DesignTokens.darkText.withOpacity(0.78),
      ),
      labelSmall: cairoTheme.labelSmall?.copyWith(
        fontSize: DesignTokens.caption,
        color: DesignTokens.darkText.withOpacity(0.72),
      ),
    );

    return base.copyWith(
      colorScheme: ColorScheme.dark(
        primary: primaryColor,
        secondary: DesignTokens.accentLime,
        surface: DesignTokens.darkSurface,
        background: DesignTokens.darkBg,
        onSurface: DesignTokens.darkText,
        onPrimary: onPrimary,
      ),
      scaffoldBackgroundColor: DesignTokens.darkBg,
      textTheme: merged,
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
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: onPrimary,
          minimumSize: const Size.fromHeight(52),
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: DesignTokens.accentSky,
          textStyle: GoogleFonts.cairo(fontWeight: FontWeight.w600),
        ),
      ),
      chipTheme: base.chipTheme.copyWith(
        selectedColor: primaryColor.withOpacity(0.2),
        side: BorderSide(color: primaryColor.withOpacity(0.24)),
        labelStyle: merged.bodyMedium,
      ),
      floatingActionButtonTheme: base.floatingActionButtonTheme.copyWith(
        backgroundColor: primaryColor,
        foregroundColor: onPrimary,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: DesignTokens.darkBg,
        selectedItemColor: primaryColor,
        unselectedItemColor: DesignTokens.darkText.withOpacity(0.55),
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
      ),
      dividerColor: DesignTokens.divider.withOpacity(0.15),
      useMaterial3: false,
    );
  }
}
