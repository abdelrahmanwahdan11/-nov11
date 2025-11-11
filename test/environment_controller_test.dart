import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:smart_air_devices/shared/controllers/app_controller.dart';
import 'package:smart_air_devices/shared/controllers/environment_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  test('bootstrap honors stored preferred scene', () async {
    SharedPreferences.setMockInitialValues({'preferredScene': 'nightCalm'});
    final appController = AppController();
    await appController.loadPrefs();
    final environmentController = EnvironmentController(appController)
      ..bootstrap();

    expect(environmentController.currentSceneNotifier.value.id, 'nightCalm');
    expect(environmentController.metricsNotifier.value.airQuality, greaterThan(0));
  });

  test('applyScene updates notifiers and persists preference', () async {
    final appController = AppController();
    await appController.loadPrefs();
    final environmentController = EnvironmentController(appController)
      ..bootstrap();

    environmentController.applyScene('loungeBreeze');

    expect(environmentController.currentSceneNotifier.value.id, 'loungeBreeze');
    expect(appController.prefsNotifier.value.preferredScene, 'loungeBreeze');
  });
}
