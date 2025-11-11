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

  SharedPreferences? _prefs;

  Future<void> loadPrefs() async {
    final prefs = await _ensurePrefs();
    final primaryHex = prefs.getString('primaryColorHex');
    final color = primaryHex != null ? _colorFromHex(primaryHex) : AppPrefs.defaults().primaryColor;
    final darkMode = prefs.getBool('isDark') ?? false;
    final localeCode = prefs.getString('locale') ?? 'en';
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    final isGuest = prefs.getBool('isGuest') ?? false;
    final onboardingSeen = prefs.getBool('onboardingSeen') ?? false;
    final storedName = prefs.getString('userName');
    final preferredScene = prefs.getString('preferredScene') ?? AppPrefs.defaults().preferredScene;
    final name = storedName != null && storedName.isNotEmpty ? storedName : null;

    prefsNotifier.value = AppPrefs.defaults().copyWith(
      primaryColor: color,
      darkMode: darkMode,
      localeCode: localeCode,
      isLoggedIn: isLoggedIn,
      isGuest: isGuest,
      onboardingSeen: onboardingSeen,
      preferredScene: preferredScene,
      userName: name,
    );

    if (isLoggedIn || isGuest) {
      userNotifier.value = User(
        id: isGuest ? null : 'local-user',
        name: name,
        guest: isGuest,
      );
    }
  }

  Future<void> updateColor(Color color) async {
    final prefs = await _ensurePrefs();
    await prefs.setString('primaryColorHex', _colorToHex(color));
    prefsNotifier.value = prefsNotifier.value.copyWith(primaryColor: color);
  }

  Future<void> updateDarkMode(bool dark) async {
    final prefs = await _ensurePrefs();
    await prefs.setBool('isDark', dark);
    prefsNotifier.value = prefsNotifier.value.copyWith(darkMode: dark);
  }

  Future<void> updateLocale(String code) async {
    final prefs = await _ensurePrefs();
    await prefs.setString('locale', code);
    prefsNotifier.value = prefsNotifier.value.copyWith(localeCode: code);
  }

  Future<void> markOnboardingSeen() async {
    final prefs = await _ensurePrefs();
    await prefs.setBool('onboardingSeen', true);
    prefsNotifier.value = prefsNotifier.value.copyWith(onboardingSeen: true);
  }

  Future<void> updatePreferredScene(String sceneId) async {
    final prefs = await _ensurePrefs();
    await prefs.setString('preferredScene', sceneId);
    prefsNotifier.value = prefsNotifier.value.copyWith(preferredScene: sceneId);
  }

  Future<void> setUser(User user) async {
    final prefs = await _ensurePrefs();
    await prefs.setBool('isGuest', user.guest);
    await prefs.setBool('isLoggedIn', !user.guest);
    await prefs.setString('userName', user.name ?? '');
    userNotifier.value = user;
    prefsNotifier.value = prefsNotifier.value.copyWith(
      isGuest: user.guest,
      isLoggedIn: !user.guest,
      userName: user.name,
    );
  }

  Future<void> signOut() async {
    final prefs = await _ensurePrefs();
    await prefs.setBool('isGuest', false);
    await prefs.setBool('isLoggedIn', false);
    await prefs.remove('userName');
    userNotifier.value = null;
    prefsNotifier.value = prefsNotifier.value.copyWith(
      isGuest: false,
      isLoggedIn: false,
      clearUserName: true,
    );
  }

  Future<void> clearPrefs() async {
    final prefs = await _ensurePrefs();
    await prefs.remove('primaryColorHex');
    await prefs.remove('isDark');
    await prefs.remove('locale');
    await prefs.remove('isLoggedIn');
    await prefs.remove('isGuest');
    await prefs.remove('onboardingSeen');
    await prefs.remove('userName');
    await prefs.remove('preferredScene');
    await prefs.remove('maintenanceTasks');
    await prefs.remove('maintenanceRemindersEnabled');
    await prefs.remove('wellnessDismissed');
    await prefs.remove('wellnessPinned');
    await prefs.remove('wellnessFocus');
    prefsNotifier.value = AppPrefs.defaults();
    userNotifier.value = null;
  }

  Future<SharedPreferences> _ensurePrefs() async {
    if (_prefs != null) {
      return _prefs!;
    }
    _prefs = await SharedPreferences.getInstance();
    return _prefs!;
  }

  Color _colorFromHex(String hex) {
    final sanitized = hex.replaceFirst('#', '').replaceFirst('0x', '');
    final normalized = sanitized.length == 6 ? 'ff$sanitized' : sanitized;
    return Color(int.parse(normalized, radix: 16));
  }

  String _colorToHex(Color color) => color.value.toRadixString(16).padLeft(8, '0');
}
