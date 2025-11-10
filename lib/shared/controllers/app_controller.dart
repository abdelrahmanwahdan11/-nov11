import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_prefs.dart';
import '../models/user.dart';

class AppController {
  AppController() {
    prefsNotifier = ValueNotifier<AppPrefs>(AppPrefs.defaults());
    userNotifier = ValueNotifier<User?>(null);
  }

  late final ValueNotifier<AppPrefs> prefsNotifier;
  late final ValueNotifier<User?> userNotifier;

  Future<void> loadPrefs() async {
    final pref = await SharedPreferences.getInstance();
    final colorValue = pref.getInt('primaryColor');
    final darkMode = pref.getBool('darkMode');
    final localeCode = pref.getString('localeCode');
    prefsNotifier.value = AppPrefs.defaults().copyWith(
      primaryColor: colorValue != null ? Color(colorValue) : null,
      darkMode: darkMode,
      localeCode: localeCode,
    );
  }

  Future<void> updateColor(Color color) async {
    final pref = await SharedPreferences.getInstance();
    await pref.setInt('primaryColor', color.value);
    prefsNotifier.value = prefsNotifier.value.copyWith(primaryColor: color);
  }

  Future<void> updateDarkMode(bool dark) async {
    final pref = await SharedPreferences.getInstance();
    await pref.setBool('darkMode', dark);
    prefsNotifier.value = prefsNotifier.value.copyWith(darkMode: dark);
  }

  Future<void> updateLocale(String code) async {
    final pref = await SharedPreferences.getInstance();
    await pref.setString('localeCode', code);
    prefsNotifier.value = prefsNotifier.value.copyWith(localeCode: code);
  }

  Future<void> clearPrefs() async {
    final pref = await SharedPreferences.getInstance();
    await pref.remove('primaryColor');
    await pref.remove('darkMode');
    await pref.remove('localeCode');
    prefsNotifier.value = AppPrefs.defaults();
  }

  void setUser(User user) {
    userNotifier.value = user;
  }

  void signOut() {
    userNotifier.value = null;
  }
}
