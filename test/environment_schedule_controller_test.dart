import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:smart_air_devices/shared/controllers/app_controller.dart';
import 'package:smart_air_devices/shared/controllers/environment_controller.dart';
import 'package:smart_air_devices/shared/controllers/environment_schedule_controller.dart';
import 'package:smart_air_devices/shared/models/environment_schedule.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppController appController;
  late EnvironmentController environmentController;
  late EnvironmentScheduleController scheduleController;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    appController = AppController();
    await appController.loadPrefs();
    environmentController = EnvironmentController(appController)..bootstrap();
    scheduleController = EnvironmentScheduleController(environmentController);
    await scheduleController.load();
  });

  tearDown(() {
    scheduleController.dispose();
    environmentController.dispose();
  });

  test('loads default schedules when storage empty', () {
    final schedules = scheduleController.schedulesNotifier.value;
    expect(schedules, isNotEmpty);
    final occurrence = scheduleController.nextOccurrence();
    expect(occurrence, isNotNull);
  });

  test('upsert persists schedule and surfaces next occurrence', () async {
    final initialLength = scheduleController.schedulesNotifier.value.length;
    final sceneId = environmentController.scenes.first.id;
    final custom = EnvironmentSchedule(
      id: 'test-schedule',
      sceneId: sceneId,
      hour: 6,
      minute: 45,
      days: const [DateTime.monday, DateTime.wednesday],
    );

    await scheduleController.upsert(custom);

    expect(
      scheduleController.schedulesNotifier.value.length,
      initialLength + 1,
    );

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('environmentSchedules'), isNotEmpty);

    final next = scheduleController.nextOccurrence(
      from: DateTime(DateTime.now().year, 1, 1),
    );
    expect(next, isNotNull);
    expect(next!.schedule.id, equals(custom.id));
  });
}
