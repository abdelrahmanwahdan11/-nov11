import 'package:flutter/material.dart';

import '../models/app_prefs.dart';

class SettingsController {
  SettingsController({required AppPrefs prefs})
      : darkMode = ValueNotifier<bool>(prefs.darkMode),
        primaryColor = ValueNotifier<Color>(prefs.primaryColor),
        localeCode = ValueNotifier<String>(prefs.localeCode);

  final ValueNotifier<bool> darkMode;
  final ValueNotifier<Color> primaryColor;
  final ValueNotifier<String> localeCode;

  void dispose() {
    darkMode.dispose();
    primaryColor.dispose();
    localeCode.dispose();
  }
}
