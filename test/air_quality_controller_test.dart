import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:smart_air_devices/shared/controllers/air_quality_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('load restores stored focus and alerts', () async {
    SharedPreferences.setMockInitialValues({
      'airQualityFocus': 'allergies',
      'airQualityAlerts': false,
    });
    final controller = AirQualityController();
    await controller.load();

    expect(controller.focusNotifier.value, 'allergies');
    expect(controller.alertsEnabledNotifier.value, isFalse);
  });

  test('refresh bumps snapshot score and appends latest history', () async {
    final controller = AirQualityController();
    await controller.load();
    final initialScore = controller.snapshotNotifier.value.score;
    final initialHistoryTail =
        controller.historyNotifier.value.last.score;

    await controller.refresh();

    expect(controller.snapshotNotifier.value.score,
        greaterThanOrEqualTo(initialScore));
    expect(controller.historyNotifier.value.last.score,
        controller.snapshotNotifier.value.score);
    expect(controller.historyNotifier.value.first.score,
        isNot(equals(controller.historyNotifier.value.last.score)));
    expect(initialHistoryTail, isNot(equals(controller.historyNotifier.value.last.score)));
  });
}
