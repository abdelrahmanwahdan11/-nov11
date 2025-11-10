import 'package:flutter/material.dart';

class AppPrefs {
  AppPrefs({
    required this.primaryColor,
    required this.darkMode,
    required this.localeCode,
  });

  factory AppPrefs.defaults() => AppPrefs(
        primaryColor: const Color(0xFFC9FF4D),
        darkMode: false,
        localeCode: 'en',
      );

  final Color primaryColor;
  final bool darkMode;
  final String localeCode;

  AppPrefs copyWith({Color? primaryColor, bool? darkMode, String? localeCode}) {
    return AppPrefs(
      primaryColor: primaryColor ?? this.primaryColor,
      darkMode: darkMode ?? this.darkMode,
      localeCode: localeCode ?? this.localeCode,
    );
  }
}
