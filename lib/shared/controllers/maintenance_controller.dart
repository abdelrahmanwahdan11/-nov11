import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/maintenance_task.dart';

class MaintenanceController {
  MaintenanceController() {
    tasksNotifier = ValueNotifier<List<MaintenanceTask>>([]);
    remindersEnabledNotifier = ValueNotifier<bool>(true);
  }

  late final ValueNotifier<List<MaintenanceTask>> tasksNotifier;
  late final ValueNotifier<bool> remindersEnabledNotifier;

  SharedPreferences? _prefs;

  Future<void> load() async {
    final prefs = await _ensurePrefs();
    final stored = prefs.getString('maintenanceTasks');
    if (stored != null && stored.isNotEmpty) {
      final decoded = jsonDecode(stored) as List<dynamic>;
      final tasks = decoded
          .map((raw) => MaintenanceTask.fromJson(raw as Map<String, dynamic>))
          .toList()
        ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
      tasksNotifier.value = tasks;
    } else {
      tasksNotifier.value = _seedTasks();
      await _persistTasks();
    }

    final remindersEnabled =
        prefs.getBool('maintenanceRemindersEnabled') ?? true;
    remindersEnabledNotifier.value = remindersEnabled;
  }

  Future<void> toggleReminders(bool enabled) async {
    final prefs = await _ensurePrefs();
    await prefs.setBool('maintenanceRemindersEnabled', enabled);
    remindersEnabledNotifier.value = enabled;
  }

  Future<void> completeTask(String id) async {
    final now = DateTime.now();
    final updated = tasksNotifier.value.map((task) {
      if (task.id == id) {
        final nextDue = now.add(Duration(days: task.cadenceDays));
        return task.copyWith(
          dueDate: nextDue,
          lastCompleted: now,
        );
      }
      return task;
    }).toList()
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
    tasksNotifier.value = updated;
    await _persistTasks();
  }

  Future<void> snoozeTask(String id, Duration offset) async {
    final updated = tasksNotifier.value.map((task) {
      if (task.id == id) {
        return task.copyWith(dueDate: task.dueDate.add(offset));
      }
      return task;
    }).toList()
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
    tasksNotifier.value = updated;
    await _persistTasks();
  }

  Future<void> resetTasks() async {
    tasksNotifier.value = _seedTasks();
    await _persistTasks();
  }

  List<MaintenanceTask> get upcomingDueSoon {
    final now = DateTime.now();
    final soonThreshold = now.add(const Duration(days: 3));
    return tasksNotifier.value
        .where((task) =>
            task.dueDate.isBefore(soonThreshold) ||
            task.dueDate.isAtSameMomentAs(soonThreshold))
        .toList()
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
  }

  List<MaintenanceTask> _seedTasks() {
    final now = DateTime.now();
    return [
      MaintenanceTask(
        id: 'filterCore',
        titleKey: 'maintenanceFilterCoreTitle',
        descriptionKey: 'maintenanceFilterCoreDescription',
        dueDate: now.add(const Duration(days: 7)),
        cadenceDays: 30,
      ),
      MaintenanceTask(
        id: 'preFilterRinse',
        titleKey: 'maintenancePreFilterTitle',
        descriptionKey: 'maintenancePreFilterDescription',
        dueDate: now.add(const Duration(days: 3)),
        cadenceDays: 14,
      ),
      MaintenanceTask(
        id: 'oscillationCheck',
        titleKey: 'maintenanceOscillationTitle',
        descriptionKey: 'maintenanceOscillationDescription',
        dueDate: now.add(const Duration(days: 12)),
        cadenceDays: 45,
      ),
      MaintenanceTask(
        id: 'airQualityCalibration',
        titleKey: 'maintenanceCalibrationTitle',
        descriptionKey: 'maintenanceCalibrationDescription',
        dueDate: now.add(const Duration(days: 18)),
        cadenceDays: 60,
      ),
    ]
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
  }

  Future<void> _persistTasks() async {
    final prefs = await _ensurePrefs();
    final encoded = jsonEncode(
      tasksNotifier.value.map((task) => task.toJson()).toList(),
    );
    await prefs.setString('maintenanceTasks', encoded);
  }

  Future<SharedPreferences> _ensurePrefs() async {
    if (_prefs != null) {
      return _prefs!;
    }
    _prefs = await SharedPreferences.getInstance();
    return _prefs!;
  }
}
