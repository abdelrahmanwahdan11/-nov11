import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:smart_air_devices/shared/controllers/comfort_controller.dart';
import 'package:smart_air_devices/shared/models/comfort_snapshot.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('load seeds snapshots and retains default focus', () async {
    final controller = ComfortController();

    await controller.load();

    expect(controller.snapshotsNotifier.value, isNotEmpty);
    expect(controller.focusNotifier.value, equals('sleep'));
    expect(controller.tipsForFocus('sleep'), isNotEmpty);
  });

  test('logSession appends snapshot and persists to preferences', () async {
    final controller = ComfortController();
    await controller.load();

    final initialLength = controller.snapshotsNotifier.value.length;
    final snapshot = ComfortSnapshot(
      timestamp: DateTime.now(),
      score: 90,
      humidity: 44,
      temperature: 22.0,
      focus: 'sleep',
    );

    await controller.logSession(snapshot);

    expect(controller.snapshotsNotifier.value.length, initialLength + 1);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('comfortSnapshots'), isNotNull);
  });

  test('toggleTipPinned updates notifier and storage', () async {
    final controller = ComfortController();
    await controller.load();

    final tip = controller.tipsForFocus('sleep').first;
    await controller.toggleTipPinned(tip.id);

    expect(controller.pinnedTipsNotifier.value.contains(tip.id), isTrue);
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getStringList('comfortPinnedTips');
    expect(stored, contains(tip.id));
  });

  test('toggleAutoBalance and reminders persist state', () async {
    final controller = ComfortController();
    await controller.load();

    await controller.toggleAutoBalance(false);
    await controller.toggleReminders(false);

    final prefs = await SharedPreferences.getInstance();
    expect(controller.autoBalanceNotifier.value, isFalse);
    expect(controller.remindersEnabledNotifier.value, isFalse);
    expect(prefs.getBool('comfortAutoBalance'), isFalse);
    expect(prefs.getBool('comfortReminders'), isFalse);
  });
}
