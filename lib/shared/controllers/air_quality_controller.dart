import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/air_quality.dart';

class AirQualityController {
  AirQualityController() {
    snapshotNotifier = ValueNotifier<AirQualitySnapshot>(_baselineSnapshot);
    historyNotifier =
        ValueNotifier<List<AirQualityHistoryEntry>>(_baselineHistory);
    insightsNotifier = ValueNotifier<List<AirQualityInsight>>(
      _insightsForFocus(_defaultFocus),
    );
    focusNotifier = ValueNotifier<String>(_defaultFocus);
    alertsEnabledNotifier = ValueNotifier<bool>(true);
  }

  static const String _defaultFocus = 'comfort';

  late final ValueNotifier<AirQualitySnapshot> snapshotNotifier;
  late final ValueNotifier<List<AirQualityHistoryEntry>> historyNotifier;
  late final ValueNotifier<List<AirQualityInsight>> insightsNotifier;
  late final ValueNotifier<String> focusNotifier;
  late final ValueNotifier<bool> alertsEnabledNotifier;

  SharedPreferences? _prefs;

  Future<void> load() async {
    final prefs = await _ensurePrefs();
    final storedFocus = prefs.getString('airQualityFocus') ?? _defaultFocus;
    final storedAlerts = prefs.getBool('airQualityAlerts') ?? true;
    focusNotifier.value = storedFocus;
    alertsEnabledNotifier.value = storedAlerts;
    insightsNotifier.value = _insightsForFocus(storedFocus);
  }

  Future<void> setFocus(String focus) async {
    if (focusNotifier.value == focus) {
      return;
    }
    focusNotifier.value = focus;
    insightsNotifier.value = _insightsForFocus(focus);
    final prefs = await _ensurePrefs();
    await prefs.setString('airQualityFocus', focus);
  }

  Future<void> setAlertsEnabled(bool enabled) async {
    if (alertsEnabledNotifier.value == enabled) {
      return;
    }
    alertsEnabledNotifier.value = enabled;
    final prefs = await _ensurePrefs();
    await prefs.setBool('airQualityAlerts', enabled);
  }

  Future<void> refresh() async {
    await Future<void>.delayed(const Duration(milliseconds: 280));
    final now = DateTime.now();
    final current = snapshotNotifier.value;
    final random = Random(now.millisecondsSinceEpoch);
    final scoreBump = max(1, random.nextInt(3));
    final nextScore = (current.score + scoreBump).clamp(65, 100);
    final next = current.copyWith(
      timestamp: now,
      score: nextScore,
      pm25: max(7, (current.pm25 - random.nextDouble())).toDouble(),
      pm10: max(14, (current.pm10 - random.nextDouble())).toDouble(),
      co2: max(360, current.co2 - random.nextInt(12)),
      trend: AirQualityTrend.improving,
    );
    snapshotNotifier.value = next;

    final history = List<AirQualityHistoryEntry>.from(historyNotifier.value);
    if (history.isNotEmpty) {
      history.removeAt(0);
    }
    history.add(
      AirQualityHistoryEntry(
        date: now,
        score: next.score,
        pm25: next.pm25,
      ),
    );
    historyNotifier.value = history;
  }

  void dispose() {
    snapshotNotifier.dispose();
    historyNotifier.dispose();
    insightsNotifier.dispose();
    focusNotifier.dispose();
    alertsEnabledNotifier.dispose();
  }

  List<AirQualityInsight> _insightsForFocus(String focus) {
    switch (focus) {
      case 'allergies':
        return const <AirQualityInsight>[
          AirQualityInsight(
            id: 'hepaPulse',
            titleKey: 'insightFilterPulseTitle',
            bodyKey: 'insightFilterPulseBody',
            icon: Icons.air,
            highlightKey: 'insightHighlightPollen',
          ),
          AirQualityInsight(
            id: 'windowSeal',
            titleKey: 'insightSealTitle',
            bodyKey: 'insightSealBody',
            icon: Icons.blur_off,
          ),
          AirQualityInsight(
            id: 'routineBoost',
            titleKey: 'insightRoutineBoostTitle',
            bodyKey: 'insightRoutineBoostBody',
            icon: Icons.schedule,
          ),
        ];
      case 'productivity':
        return const <AirQualityInsight>[
          AirQualityInsight(
            id: 'ventBoost',
            titleKey: 'insightVentilationTitle',
            bodyKey: 'insightVentilationBody',
            icon: Icons.autorenew,
          ),
          AirQualityInsight(
            id: 'focusLight',
            titleKey: 'insightFocusLightTitle',
            bodyKey: 'insightFocusLightBody',
            icon: Icons.light_mode,
          ),
          AirQualityInsight(
            id: 'reminderBreak',
            titleKey: 'insightBreaksTitle',
            bodyKey: 'insightBreaksBody',
            icon: Icons.self_improvement,
          ),
        ];
      case 'comfort':
      default:
        return const <AirQualityInsight>[
          AirQualityInsight(
            id: 'hydrateAir',
            titleKey: 'insightHydrateTitle',
            bodyKey: 'insightHydrateBody',
            icon: Icons.water_drop,
            highlightKey: 'insightHighlightComfort',
          ),
          AirQualityInsight(
            id: 'calmMode',
            titleKey: 'insightCalmModeTitle',
            bodyKey: 'insightCalmModeBody',
            icon: Icons.nightlight_round,
          ),
          AirQualityInsight(
            id: 'cleanCycle',
            titleKey: 'insightCleanCycleTitle',
            bodyKey: 'insightCleanCycleBody',
            icon: Icons.refresh,
          ),
        ];
    }
  }

  Future<SharedPreferences> _ensurePrefs() async {
    if (_prefs != null) {
      return _prefs!;
    }
    _prefs = await SharedPreferences.getInstance();
    return _prefs!;
  }

  static final AirQualitySnapshot _baselineSnapshot = AirQualitySnapshot(
    timestamp: DateTime.now(),
    score: 86,
    pm25: 12.5,
    pm10: 22.1,
    co2: 412,
    trend: AirQualityTrend.steady,
  );

  static final List<AirQualityHistoryEntry> _baselineHistory =
      List<AirQualityHistoryEntry>.generate(7, (int index) {
    final day = DateTime.now().subtract(Duration(days: 6 - index));
    final baseScore = 76 + index;
    return AirQualityHistoryEntry(
      date: day,
      score: baseScore,
      pm25: 14 + index.toDouble(),
    );
  });
}
