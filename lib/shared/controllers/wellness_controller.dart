import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/theme/design_tokens.dart';
import '../models/wellness_metric.dart';
import '../models/wellness_recommendation.dart';
import '../models/wellness_trend.dart';

class WellnessController {
  WellnessController() {
    metricsNotifier = ValueNotifier<List<WellnessMetric>>(<WellnessMetric>[]);
    recommendationsNotifier =
        ValueNotifier<List<WellnessRecommendation>>(<WellnessRecommendation>[]);
    trendNotifier =
        ValueNotifier<List<WellnessTrendPoint>>(<WellnessTrendPoint>[]);
    focusMetricNotifier = ValueNotifier<String?>(null);
    compositeScoreNotifier = ValueNotifier<double>(0);
    hiddenCountNotifier = ValueNotifier<int>(0);
  }

  late final ValueNotifier<List<WellnessMetric>> metricsNotifier;
  late final ValueNotifier<List<WellnessRecommendation>> recommendationsNotifier;
  late final ValueNotifier<List<WellnessTrendPoint>> trendNotifier;
  late final ValueNotifier<String?> focusMetricNotifier;
  late final ValueNotifier<double> compositeScoreNotifier;
  late final ValueNotifier<int> hiddenCountNotifier;

  SharedPreferences? _prefs;
  final _random = Random();
  List<String> _dismissedIds = <String>[];
  List<String> _pinnedIds = <String>[];

  Future<void> load() async {
    final prefs = await _ensurePrefs();
    _dismissedIds = prefs.getStringList('wellnessDismissed') ?? <String>[];
    _pinnedIds = prefs.getStringList('wellnessPinned') ?? <String>[];
    focusMetricNotifier.value = prefs.getString('wellnessFocus');
    _seedData();
  }

  Future<void> refresh() async {
    final focusId = focusMetricNotifier.value;
    final updatedMetrics = metricsNotifier.value.map((metric) {
      final emphasis = metric.id == focusId ? 2.0 : 1.0;
      final delta = (metric.trendDelta + emphasis * 0.2).clamp(-5.0, 8.0);
      final newScore = (metric.score + emphasis * 0.8)
          .clamp(0.0, 100.0);
      return metric.copyWith(score: newScore, trendDelta: delta);
    }).toList();
    metricsNotifier.value = updatedMetrics;
    compositeScoreNotifier.value = _computeComposite(updatedMetrics);

    final nextTrends = trendNotifier.value.map((point) {
      final bump = focusId == 'restRecovery' ? 1.8 : 1.2;
      final jitter = _random.nextDouble() * 0.6;
      final value = (point.value + bump + jitter).clamp(45.0, 100.0);
      return WellnessTrendPoint(labelKey: point.labelKey, value: value);
    }).toList();
    trendNotifier.value = nextTrends;
  }

  Future<void> setFocusMetric(String id) async {
    final prefs = await _ensurePrefs();
    await prefs.setString('wellnessFocus', id);
    focusMetricNotifier.value = id;
  }

  Future<void> togglePin(String id) async {
    if (_pinnedIds.contains(id)) {
      _pinnedIds.remove(id);
    } else {
      _pinnedIds.add(id);
    }
    await _persistPinned();
    recommendationsNotifier.value = _seedRecommendations();
  }

  Future<void> dismissRecommendation(String id) async {
    if (!_dismissedIds.contains(id)) {
      _dismissedIds.add(id);
      await _persistDismissed();
    }
    _pinnedIds.remove(id);
    await _persistPinned();
    recommendationsNotifier.value = _seedRecommendations();
    hiddenCountNotifier.value = _dismissedIds.length;
  }

  Future<void> restoreDismissed() async {
    if (_dismissedIds.isEmpty) {
      return;
    }
    _dismissedIds.clear();
    await _persistDismissed();
    recommendationsNotifier.value = _seedRecommendations();
    hiddenCountNotifier.value = 0;
  }

  void _seedData() {
    final metrics = <WellnessMetric>[
      WellnessMetric(
        id: 'airHarmony',
        titleKey: 'wellnessMetricAirTitle',
        subtitleKey: 'wellnessMetricAirSubtitle',
        score: 88,
        trendDelta: 2.4,
        accent: DesignTokens.accentSky,
      ),
      WellnessMetric(
        id: 'restRecovery',
        titleKey: 'wellnessMetricRestTitle',
        subtitleKey: 'wellnessMetricRestSubtitle',
        score: 82,
        trendDelta: 1.2,
        accent: const Color(0xFFCFB8FF),
      ),
      WellnessMetric(
        id: 'energyBalance',
        titleKey: 'wellnessMetricEnergyTitle',
        subtitleKey: 'wellnessMetricEnergySubtitle',
        score: 76,
        trendDelta: -0.8,
        accent: const Color(0xFF6EE7B7),
      ),
      WellnessMetric(
        id: 'comfortRhythm',
        titleKey: 'wellnessMetricComfortTitle',
        subtitleKey: 'wellnessMetricComfortSubtitle',
        score: 90,
        trendDelta: 3.1,
        accent: DesignTokens.accentLime,
      ),
    ];
    metricsNotifier.value = metrics;
    compositeScoreNotifier.value = _computeComposite(metrics);
    trendNotifier.value = _seedTrends();
    hiddenCountNotifier.value = _dismissedIds.length;

    if (focusMetricNotifier.value == null && metrics.isNotEmpty) {
      focusMetricNotifier.value = metrics.first.id;
    }
    recommendationsNotifier.value = _seedRecommendations();
  }

  double _computeComposite(List<WellnessMetric> metrics) {
    if (metrics.isEmpty) {
      return 0;
    }
    final total = metrics.fold<double>(0, (sum, metric) => sum + metric.score);
    return total / metrics.length;
  }

  List<WellnessTrendPoint> _seedTrends() {
    return <WellnessTrendPoint>[
      const WellnessTrendPoint(labelKey: 'wellnessTrendMon', value: 68),
      const WellnessTrendPoint(labelKey: 'wellnessTrendTue', value: 72),
      const WellnessTrendPoint(labelKey: 'wellnessTrendWed', value: 75),
      const WellnessTrendPoint(labelKey: 'wellnessTrendThu', value: 78),
      const WellnessTrendPoint(labelKey: 'wellnessTrendFri', value: 82),
      const WellnessTrendPoint(labelKey: 'wellnessTrendSat', value: 85),
      const WellnessTrendPoint(labelKey: 'wellnessTrendSun', value: 88),
    ];
  }

  List<WellnessRecommendation> _seedRecommendations() {
    final all = <WellnessRecommendation>[
      const WellnessRecommendation(
        id: 'hydrate',
        titleKey: 'wellnessRecHydrateTitle',
        bodyKey: 'wellnessRecHydrateBody',
        tagKey: 'wellnessRecTagDaily',
      ),
      const WellnessRecommendation(
        id: 'purifyPulse',
        titleKey: 'wellnessRecPurifyTitle',
        bodyKey: 'wellnessRecPurifyBody',
        tagKey: 'wellnessRecTagAir',
      ),
      const WellnessRecommendation(
        id: 'nightMode',
        titleKey: 'wellnessRecNightTitle',
        bodyKey: 'wellnessRecNightBody',
        tagKey: 'wellnessRecTagRest',
      ),
      const WellnessRecommendation(
        id: 'energySaver',
        titleKey: 'wellnessRecEnergyTitle',
        bodyKey: 'wellnessRecEnergyBody',
        tagKey: 'wellnessRecTagEnergy',
      ),
    ];

    final filtered = all
        .where((rec) => !_dismissedIds.contains(rec.id))
        .map((rec) =>
            _pinnedIds.contains(rec.id) ? rec.copyWith(pinned: true) : rec)
        .toList();
    filtered.sort((a, b) {
      if (a.pinned == b.pinned) {
        return a.titleKey.compareTo(b.titleKey);
      }
      return a.pinned ? -1 : 1;
    });
    return filtered;
  }

  Future<void> _persistPinned() async {
    final prefs = await _ensurePrefs();
    await prefs.setStringList('wellnessPinned', _pinnedIds);
  }

  Future<void> _persistDismissed() async {
    final prefs = await _ensurePrefs();
    await prefs.setStringList('wellnessDismissed', _dismissedIds);
  }

  Future<SharedPreferences> _ensurePrefs() async {
    if (_prefs != null) {
      return _prefs!;
    }
    _prefs = await SharedPreferences.getInstance();
    return _prefs!;
  }
}
