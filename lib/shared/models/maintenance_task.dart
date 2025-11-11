enum MaintenanceStatus { overdue, dueSoon, upcoming }

class MaintenanceTask {
  MaintenanceTask({
    required this.id,
    required this.titleKey,
    required this.descriptionKey,
    required this.dueDate,
    required this.cadenceDays,
    this.lastCompleted,
  });

  final String id;
  final String titleKey;
  final String descriptionKey;
  final DateTime dueDate;
  final int cadenceDays;
  final DateTime? lastCompleted;

  int get daysUntilDue {
    final diff = dueDate.difference(DateTime.now()).inDays;
    if (diff < 0) {
      return diff;
    }
    return diff;
  }

  MaintenanceStatus get status {
    final now = DateTime.now();
    if (dueDate.isBefore(now)) {
      return MaintenanceStatus.overdue;
    }
    if (dueDate.isBefore(now.add(const Duration(days: 3)))) {
      return MaintenanceStatus.dueSoon;
    }
    return MaintenanceStatus.upcoming;
  }

  MaintenanceTask copyWith({
    String? id,
    String? titleKey,
    String? descriptionKey,
    DateTime? dueDate,
    int? cadenceDays,
    DateTime? lastCompleted,
    bool clearLastCompleted = false,
  }) {
    return MaintenanceTask(
      id: id ?? this.id,
      titleKey: titleKey ?? this.titleKey,
      descriptionKey: descriptionKey ?? this.descriptionKey,
      dueDate: dueDate ?? this.dueDate,
      cadenceDays: cadenceDays ?? this.cadenceDays,
      lastCompleted: clearLastCompleted ? null : (lastCompleted ?? this.lastCompleted),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'titleKey': titleKey,
        'descriptionKey': descriptionKey,
        'dueDate': dueDate.toIso8601String(),
        'cadenceDays': cadenceDays,
        'lastCompleted': lastCompleted?.toIso8601String(),
      };

  factory MaintenanceTask.fromJson(Map<String, dynamic> json) {
    return MaintenanceTask(
      id: json['id'] as String,
      titleKey: json['titleKey'] as String,
      descriptionKey: json['descriptionKey'] as String,
      dueDate: DateTime.parse(json['dueDate'] as String),
      cadenceDays: json['cadenceDays'] as int,
      lastCompleted: json['lastCompleted'] != null
          ? DateTime.parse(json['lastCompleted'] as String)
          : null,
    );
  }

}
