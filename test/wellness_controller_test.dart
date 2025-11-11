import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:smart_air_devices/shared/controllers/wellness_controller.dart';
import 'package:smart_air_devices/shared/models/wellness_metric.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('load seeds metrics and defaults focus when unset', () async {
    final controller = WellnessController();

    await controller.load();

    expect(controller.metricsNotifier.value, isNotEmpty);
    expect(controller.trendNotifier.value, isNotEmpty);
    expect(controller.focusMetricNotifier.value, isNotNull);
    final WellnessMetric focusMetric = controller.metricsNotifier.value
        .firstWhere((metric) => metric.id == controller.focusMetricNotifier.value);
    expect(focusMetric.titleKey, equals('wellnessMetricAirTitle'));
  });

  test('respects persisted focus and updates on change', () async {
    SharedPreferences.setMockInitialValues({'wellnessFocus': 'energyBalance'});
    final controller = WellnessController();

    await controller.load();

    expect(controller.focusMetricNotifier.value, equals('energyBalance'));

    await controller.setFocusMetric('comfortRhythm');
    expect(controller.focusMetricNotifier.value, equals('comfortRhythm'));

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('wellnessFocus'), equals('comfortRhythm'));
  });

  test('togglePin and dismiss track persistence', () async {
    final controller = WellnessController();
    await controller.load();

    await controller.togglePin('hydrate');
    expect(
      controller.recommendationsNotifier.value
          .where((tip) => tip.id == 'hydrate')
          .first
          .pinned,
      isTrue,
    );

    var prefs = await SharedPreferences.getInstance();
    expect(prefs.getStringList('wellnessPinned'), contains('hydrate'));

    await controller.dismissRecommendation('hydrate');
    expect(
      controller.recommendationsNotifier.value
          .where((tip) => tip.id == 'hydrate'),
      isEmpty,
    );
    expect(controller.hiddenCountNotifier.value, equals(1));

    prefs = await SharedPreferences.getInstance();
    expect(prefs.getStringList('wellnessDismissed'), contains('hydrate'));

    await controller.restoreDismissed();
    expect(controller.hiddenCountNotifier.value, equals(0));
    expect(
      controller.recommendationsNotifier.value
          .where((tip) => tip.id == 'hydrate'),
      isNotEmpty,
    );
  });

  test('refresh nudges composite score and trend', () async {
    final controller = WellnessController();
    await controller.load();

    final initialComposite = controller.compositeScoreNotifier.value;
    final initialTrend = controller.trendNotifier.value.last.value;

    await controller.refresh();

    expect(controller.compositeScoreNotifier.value, greaterThan(initialComposite));
    expect(controller.trendNotifier.value.last.value, greaterThan(initialTrend));
  });
}
