import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:smart_air_devices/shared/controllers/maintenance_controller.dart';
import 'package:smart_air_devices/shared/models/maintenance_task.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('load seeds default care tasks when storage empty', () async {
    final controller = MaintenanceController();
    await controller.load();

    expect(controller.tasksNotifier.value, isNotEmpty);
    expect(controller.tasksNotifier.value.length, greaterThanOrEqualTo(4));
    final isSorted = _isSorted(controller.tasksNotifier.value);
    expect(isSorted, isTrue);
  });

  test('completeTask schedules next cycle and stores history', () async {
    final controller = MaintenanceController();
    await controller.load();
    final firstTask = controller.tasksNotifier.value.first;

    await controller.completeTask(firstTask.id);

    final updated = controller.tasksNotifier.value
        .firstWhere((task) => task.id == firstTask.id);
    expect(updated.lastCompleted, isNotNull);
    expect(updated.dueDate.isAfter(DateTime.now()), isTrue);

    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString('maintenanceTasks');
    expect(stored, isNotNull);
    final decoded = jsonDecode(stored!) as List<dynamic>;
    expect(decoded.length, controller.tasksNotifier.value.length);
  });

  test('toggle reminders updates notifier and preference', () async {
    final controller = MaintenanceController();
    await controller.load();

    await controller.toggleReminders(false);

    expect(controller.remindersEnabledNotifier.value, isFalse);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('maintenanceRemindersEnabled'), isFalse);
  });

  test('upcomingDueSoon surfaces tasks due in next three days', () async {
    final controller = MaintenanceController();
    await controller.load();

    final soon = controller.upcomingDueSoon;
    for (final task in soon) {
      final difference = task.dueDate.difference(DateTime.now()).inDays;
      expect(difference, lessThanOrEqualTo(3));
    }
  });
}

bool _isSorted(List<MaintenanceTask> tasks) {
  for (var i = 1; i < tasks.length; i++) {
    if (tasks[i - 1].dueDate.isAfter(tasks[i].dueDate)) {
      return false;
    }
  }
  return true;
}
