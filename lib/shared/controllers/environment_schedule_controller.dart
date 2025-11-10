import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/environment_schedule.dart';
import 'environment_controller.dart';

class EnvironmentScheduleController {
  EnvironmentScheduleController(this._environmentController)
      : schedulesNotifier =
            ValueNotifier<List<EnvironmentSchedule>>(const <EnvironmentSchedule>[]);

  final EnvironmentController _environmentController;
  final ValueNotifier<List<EnvironmentSchedule>> schedulesNotifier;

  SharedPreferences? _prefs;
  static const String _storageKey = 'environmentSchedules';

  Future<void> load() async {
    final prefs = await _ensurePrefs();
    final stored = prefs.getString(_storageKey);
    if (stored != null && stored.isNotEmpty) {
      try {
        final decoded = jsonDecode(stored);
        if (decoded is List) {
          final schedules = decoded
              .map((dynamic item) => EnvironmentSchedule.fromJson(
                  Map<String, dynamic>.from(item as Map)))
              .toList();
          _emit(_sortSchedules(schedules));
          return;
        }
      } catch (_) {
        // Fall through to seeding defaults when parsing fails.
      }
    }
    final defaults = _seedDefaults();
    _emit(_sortSchedules(defaults));
    await _persist();
  }

  Future<void> upsert(EnvironmentSchedule schedule) async {
    final current = List<EnvironmentSchedule>.from(schedulesNotifier.value);
    final index = current.indexWhere((element) => element.id == schedule.id);
    if (index >= 0) {
      current[index] = schedule;
    } else {
      current.add(schedule);
    }
    _emit(_sortSchedules(current));
    await _persist();
  }

  Future<void> toggle(String id, bool enabled) async {
    final current = List<EnvironmentSchedule>.from(schedulesNotifier.value);
    final index = current.indexWhere((element) => element.id == id);
    if (index == -1) {
      return;
    }
    current[index] = current[index].copyWith(enabled: enabled);
    _emit(_sortSchedules(current));
    await _persist();
  }

  Future<void> remove(String id) async {
    final current = List<EnvironmentSchedule>.from(schedulesNotifier.value);
    current.removeWhere((element) => element.id == id);
    _emit(_sortSchedules(current));
    await _persist();
  }

  EnvironmentScheduleOccurrence? nextOccurrence({
    DateTime? from,
    List<EnvironmentSchedule>? schedules,
  }) {
    final reference = from ?? DateTime.now();
    final source = schedules ?? schedulesNotifier.value;
    EnvironmentScheduleOccurrence? best;
    for (final schedule in source) {
      if (!schedule.enabled) {
        continue;
      }
      final next = schedule.nextDateTime(reference);
      if (next == null) {
        continue;
      }
      if (best == null || next.isBefore(best.occursAt)) {
        best = EnvironmentScheduleOccurrence(schedule: schedule, occursAt: next);
      }
    }
    return best;
  }

  void dispose() {
    schedulesNotifier.dispose();
  }

  Future<SharedPreferences> _ensurePrefs() async {
    if (_prefs != null) {
      return _prefs!;
    }
    _prefs = await SharedPreferences.getInstance();
    return _prefs!;
  }

  Future<void> _persist() async {
    final prefs = await _ensurePrefs();
    final payload = schedulesNotifier.value.map((schedule) => schedule.toJson()).toList();
    await prefs.setString(_storageKey, jsonEncode(payload));
  }

  void _emit(List<EnvironmentSchedule> schedules) {
    schedulesNotifier.value = List<EnvironmentSchedule>.unmodifiable(schedules);
  }

  List<EnvironmentSchedule> _sortSchedules(List<EnvironmentSchedule> schedules) {
    final sorted = List<EnvironmentSchedule>.from(schedules);
    sorted.sort((a, b) {
      final hourCompare = a.hour.compareTo(b.hour);
      if (hourCompare != 0) {
        return hourCompare;
      }
      return a.minute.compareTo(b.minute);
    });
    return sorted;
  }

  List<EnvironmentSchedule> _seedDefaults() {
    final scenes = _environmentController.scenes;
    if (scenes.isEmpty) {
      return const <EnvironmentSchedule>[];
    }
    final first = scenes.first;
    final evening = scenes.length > 1 ? scenes.last : scenes.first;
    return <EnvironmentSchedule>[
      EnvironmentSchedule(
        id: 'schedule-morning',
        sceneId: first.id,
        hour: 7,
        minute: 30,
        days: const <int>[
          DateTime.monday,
          DateTime.tuesday,
          DateTime.wednesday,
          DateTime.thursday,
          DateTime.friday,
        ],
      ),
      EnvironmentSchedule(
        id: 'schedule-night',
        sceneId: evening.id,
        hour: 22,
        minute: 0,
        days: const <int>[
          DateTime.monday,
          DateTime.tuesday,
          DateTime.wednesday,
          DateTime.thursday,
          DateTime.friday,
          DateTime.saturday,
          DateTime.sunday,
        ],
      ),
    ];
  }
}
