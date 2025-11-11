import 'package:flutter/material.dart';

class EnvironmentSchedule {
  const EnvironmentSchedule({
    required this.id,
    required this.sceneId,
    required this.hour,
    required this.minute,
    required List<int> days,
    this.enabled = true,
  }) : days = List<int>.unmodifiable((List<int>.from(days)..sort()));

  final String id;
  final String sceneId;
  final int hour;
  final int minute;
  final List<int> days;
  final bool enabled;

  TimeOfDay get timeOfDay => TimeOfDay(hour: hour, minute: minute);

  EnvironmentSchedule copyWith({
    String? id,
    String? sceneId,
    int? hour,
    int? minute,
    List<int>? days,
    bool? enabled,
  }) {
    return EnvironmentSchedule(
      id: id ?? this.id,
      sceneId: sceneId ?? this.sceneId,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
      days: days ?? this.days,
      enabled: enabled ?? this.enabled,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'sceneId': sceneId,
      'hour': hour,
      'minute': minute,
      'days': days,
      'enabled': enabled,
    };
  }

  factory EnvironmentSchedule.fromJson(Map<String, dynamic> json) {
    final rawDays = json['days'];
    final parsedDays = rawDays is List
        ? rawDays.map((dynamic value) => (value as num).toInt()).toList()
        : List<int>.generate(7, (index) => index + 1);
    return EnvironmentSchedule(
      id: json['id'] as String,
      sceneId: json['sceneId'] as String,
      hour: (json['hour'] as num).toInt(),
      minute: (json['minute'] as num).toInt(),
      days: parsedDays,
      enabled: json['enabled'] is bool ? json['enabled'] as bool : true,
    );
  }

  bool occursOnDay(int weekday) => days.isEmpty || days.contains(weekday);

  DateTime? nextDateTime(DateTime from) {
    final allowedDays = days.isEmpty ? _allDays : days;
    for (var offset = 0; offset < 7; offset++) {
      final targetDay = ((from.weekday - 1 + offset) % 7) + 1;
      if (!allowedDays.contains(targetDay)) {
        continue;
      }
      final candidate = DateTime(
        from.year,
        from.month,
        from.day,
        hour,
        minute,
      ).add(Duration(days: offset));
      if (offset == 0 && candidate.isBefore(from)) {
        continue;
      }
      if (candidate.isBefore(from)) {
        continue;
      }
      return candidate;
    }
    return null;
  }

  static const List<int> _allDays = <int>[
    DateTime.monday,
    DateTime.tuesday,
    DateTime.wednesday,
    DateTime.thursday,
    DateTime.friday,
    DateTime.saturday,
    DateTime.sunday,
  ];
}

class EnvironmentScheduleOccurrence {
  const EnvironmentScheduleOccurrence({
    required this.schedule,
    required this.occursAt,
  });

  final EnvironmentSchedule schedule;
  final DateTime occursAt;
}
