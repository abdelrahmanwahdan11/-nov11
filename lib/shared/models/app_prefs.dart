import 'package:flutter/material.dart';

class AppPrefs {
  AppPrefs({
    required this.primaryColor,
    required this.darkMode,
    required this.localeCode,
    required this.isLoggedIn,
    required this.isGuest,
    required this.onboardingSeen,
    this.userName,
  });

  factory AppPrefs.defaults() => AppPrefs(
        primaryColor: const Color(0xFFC9FF4D),
        darkMode: false,
        localeCode: 'en',
        isLoggedIn: false,
        isGuest: false,
        onboardingSeen: false,
        userName: null,
      );

  final Color primaryColor;
  final bool darkMode;
  final String localeCode;
  final bool isLoggedIn;
  final bool isGuest;
  final bool onboardingSeen;
  final String? userName;

  AppPrefs copyWith({
    Color? primaryColor,
    bool? darkMode,
    String? localeCode,
    bool? isLoggedIn,
    bool? isGuest,
    bool? onboardingSeen,
    String? userName,
    bool clearUserName = false,
  }) {
    return AppPrefs(
      primaryColor: primaryColor ?? this.primaryColor,
      darkMode: darkMode ?? this.darkMode,
      localeCode: localeCode ?? this.localeCode,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      isGuest: isGuest ?? this.isGuest,
      onboardingSeen: onboardingSeen ?? this.onboardingSeen,
      userName: clearUserName ? null : (userName ?? this.userName),
    );
  }
}
