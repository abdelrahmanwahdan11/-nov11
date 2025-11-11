import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationsController {
  NotificationsController() {
    muteMarketingNotifier = ValueNotifier<bool>(false);
    disabledNotifier = ValueNotifier<Set<String>>(<String>{});
  }

  late final ValueNotifier<bool> muteMarketingNotifier;
  late final ValueNotifier<Set<String>> disabledNotifier;

  SharedPreferences? _prefs;

  Future<void> load() async {
    final prefs = await _ensurePrefs();
    muteMarketingNotifier.value =
        prefs.getBool('notificationsMuteMarketing') ?? false;
    final disabled = prefs.getStringList('notificationsDisabled') ?? <String>[];
    disabledNotifier.value = disabled.toSet();
  }

  Future<void> setMuteMarketing(bool value) async {
    muteMarketingNotifier.value = value;
    final prefs = await _ensurePrefs();
    await prefs.setBool('notificationsMuteMarketing', value);
  }

  Future<void> setNotificationEnabled(String id, bool enabled) async {
    final next = disabledNotifier.value.toSet();
    if (enabled) {
      next.remove(id);
    } else {
      next.add(id);
    }
    disabledNotifier.value = next;
    final prefs = await _ensurePrefs();
    await prefs.setStringList('notificationsDisabled', next.toList());
  }

  bool isNotificationEnabled(String id) {
    return !disabledNotifier.value.contains(id);
  }

  Future<SharedPreferences> _ensurePrefs() async {
    if (_prefs != null) {
      return _prefs!;
    }
    _prefs = await SharedPreferences.getInstance();
    return _prefs!;
  }
}
