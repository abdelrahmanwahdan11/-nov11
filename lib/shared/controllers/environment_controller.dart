import 'dart:async';

import 'package:flutter/material.dart';

import 'app_controller.dart';
import '../models/environment_scene.dart';

class EnvironmentController {
  EnvironmentController(this._appController) {
    currentSceneNotifier = ValueNotifier<EnvironmentScene>(_scenes.first);
    metricsNotifier = ValueNotifier<EnvironmentMetrics>(_scenes.first.metrics);
  }

  final AppController _appController;

  late final ValueNotifier<EnvironmentScene> currentSceneNotifier;
  late final ValueNotifier<EnvironmentMetrics> metricsNotifier;

  final List<EnvironmentScene> _scenes = const [
    EnvironmentScene(
      id: 'pureFocus',
      titleKey: 'scenePureFocusTitle',
      subtitleKey: 'scenePureFocusSubtitle',
      imageSeed: 'scene-pure-focus',
      gradientStart: Color(0xFF0A1D2E),
      gradientEnd: Color(0xFF1B4F72),
      metrics: EnvironmentMetrics(
        airQuality: 94,
        humidity: 42,
        temperatureC: 21.5,
      ),
      highlightKeys: <String>[
        'scenePureFocusPoint1',
        'scenePureFocusPoint2',
        'scenePureFocusPoint3',
      ],
    ),
    EnvironmentScene(
      id: 'loungeBreeze',
      titleKey: 'sceneLoungeBreezeTitle',
      subtitleKey: 'sceneLoungeBreezeSubtitle',
      imageSeed: 'scene-lounge-breeze',
      gradientStart: Color(0xFF0F3D3E),
      gradientEnd: Color(0xFF5CB8B2),
      metrics: EnvironmentMetrics(
        airQuality: 88,
        humidity: 48,
        temperatureC: 23.0,
      ),
      highlightKeys: <String>[
        'sceneLoungeBreezePoint1',
        'sceneLoungeBreezePoint2',
        'sceneLoungeBreezePoint3',
      ],
    ),
    EnvironmentScene(
      id: 'nightCalm',
      titleKey: 'sceneNightCalmTitle',
      subtitleKey: 'sceneNightCalmSubtitle',
      imageSeed: 'scene-night-calm',
      gradientStart: Color(0xFF1F1646),
      gradientEnd: Color(0xFF6C2C83),
      metrics: EnvironmentMetrics(
        airQuality: 91,
        humidity: 55,
        temperatureC: 19.2,
      ),
      highlightKeys: <String>[
        'sceneNightCalmPoint1',
        'sceneNightCalmPoint2',
        'sceneNightCalmPoint3',
      ],
    ),
  ];

  List<EnvironmentScene> get scenes => List<EnvironmentScene>.unmodifiable(_scenes);

  void bootstrap() {
    final stored = _appController.prefsNotifier.value.preferredScene;
    _setScene(stored, persist: false);
  }

  void applyScene(String id) {
    _setScene(id, persist: true);
  }

  void dispose() {
    currentSceneNotifier.dispose();
    metricsNotifier.dispose();
  }

  void _setScene(String id, {required bool persist}) {
    final scene = _scenes.firstWhere(
      (element) => element.id == id,
      orElse: () => _scenes.first,
    );
    if (currentSceneNotifier.value.id != scene.id) {
      currentSceneNotifier.value = scene;
    }
    // Ensure metrics are refreshed even if the same scene is selected.
    metricsNotifier.value = scene.metrics;
    if (persist) {
      unawaited(_appController.updatePreferredScene(scene.id));
    }
  }
}
