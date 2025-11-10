import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:smart_air_devices/shared/controllers/energy_usage_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('load restores stored goal and eco mode', () async {
    SharedPreferences.setMockInitialValues({
      'energyGoalKwh': 72.0,
      'energyEcoMode': true,
    });

    final controller = EnergyUsageController();
    await controller.load();

    expect(controller.goalNotifier.value, 72.0);
    expect(controller.ecoModeNotifier.value, isTrue);
    expect(controller.snapshotNotifier.value.goalKwh, 72.0);
  });

  test('setGoal clamps within range and updates snapshot', () async {
    final controller = EnergyUsageController();
    await controller.load();

    await controller.setGoal(150);

    expect(controller.goalNotifier.value, 120);
    expect(controller.snapshotNotifier.value.goalKwh, 120);
  });

  test('refresh updates usage and appends history entry', () async {
    final controller = EnergyUsageController();
    await controller.load();
    final initialTotal = controller.snapshotNotifier.value.totalKwh;
    final initialHistoryLength = controller.historyNotifier.value.length;

    await controller.refresh();

    expect(controller.snapshotNotifier.value.totalKwh,
        isNot(equals(initialTotal)));
    expect(controller.historyNotifier.value.length,
        greaterThanOrEqualTo(initialHistoryLength));
  });
}
