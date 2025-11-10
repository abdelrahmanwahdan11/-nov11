import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/energy_usage.dart';

class EnergyUsageController {
  EnergyUsageController() {
    snapshotNotifier =
        ValueNotifier<EnergyUsageSnapshot>(_baselineSnapshot.copyWith());
    historyNotifier = ValueNotifier<List<EnergyUsageHistoryEntry>>(
      List<EnergyUsageHistoryEntry>.from(_baselineHistory),
    );
    tipsNotifier = ValueNotifier<List<EnergyUsageTip>>(_tips);
    goalNotifier = ValueNotifier<double>(_defaultGoalKwh);
    ecoModeNotifier = ValueNotifier<bool>(false);
  }

  static const double _defaultGoalKwh = 62;

  late final ValueNotifier<EnergyUsageSnapshot> snapshotNotifier;
  late final ValueNotifier<List<EnergyUsageHistoryEntry>> historyNotifier;
  late final ValueNotifier<List<EnergyUsageTip>> tipsNotifier;
  late final ValueNotifier<double> goalNotifier;
  late final ValueNotifier<bool> ecoModeNotifier;

  SharedPreferences? _prefs;

  Future<void> load() async {
    final prefs = await _ensurePrefs();
    final storedGoal = prefs.getDouble('energyGoalKwh') ?? _defaultGoalKwh;
    final storedEco = prefs.getBool('energyEcoMode') ?? false;
    goalNotifier.value = storedGoal;
    ecoModeNotifier.value = storedEco;
    snapshotNotifier.value = snapshotNotifier.value.copyWith(goalKwh: storedGoal);
  }

  Future<void> setGoal(double goalKwh) async {
    final clamped = goalKwh.clamp(30, 120).toDouble();
    goalNotifier.value = clamped;
    snapshotNotifier.value = snapshotNotifier.value.copyWith(goalKwh: clamped);
    final prefs = await _ensurePrefs();
    await prefs.setDouble('energyGoalKwh', clamped);
  }

  Future<void> setEcoMode(bool enabled) async {
    if (ecoModeNotifier.value == enabled) {
      return;
    }
    ecoModeNotifier.value = enabled;
    final prefs = await _ensurePrefs();
    await prefs.setBool('energyEcoMode', enabled);
  }

  Future<void> refresh() async {
    await Future<void>.delayed(const Duration(milliseconds: 240));
    final now = DateTime.now();
    final current = snapshotNotifier.value;
    final random = Random(now.microsecondsSinceEpoch);
    final ecoModifier = ecoModeNotifier.value ? -1.3 : 1.0;
    final delta = (random.nextDouble() * 4) - 1.8;
    final projected =
        (current.totalKwh + (delta + ecoModifier)).clamp(28, 98).toDouble();
    final roundedKwh = double.parse(projected.toStringAsFixed(1));
    final estimatedCost = double.parse((roundedKwh * 0.18).toStringAsFixed(2));
    final next = current.copyWith(
      period: DateTime(now.year, now.month),
      totalKwh: roundedKwh,
      previousKwh: current.totalKwh,
      estimatedCost: estimatedCost,
      goalKwh: goalNotifier.value,
    );
    snapshotNotifier.value = next;

    final history = List<EnergyUsageHistoryEntry>.from(historyNotifier.value);
    if (history.length > 14) {
      history.removeAt(0);
    }
    history.add(
      EnergyUsageHistoryEntry(
        date: now,
        kwh: roundedKwh,
      ),
    );
    historyNotifier.value = history;
  }

  void dispose() {
    snapshotNotifier.dispose();
    historyNotifier.dispose();
    tipsNotifier.dispose();
    goalNotifier.dispose();
    ecoModeNotifier.dispose();
  }

  Future<SharedPreferences> _ensurePrefs() async {
    if (_prefs != null) {
      return _prefs!;
    }
    _prefs = await SharedPreferences.getInstance();
    return _prefs!;
  }

  static final EnergyUsageSnapshot _baselineSnapshot = EnergyUsageSnapshot(
    period: DateTime(DateTime.now().year, DateTime.now().month),
    totalKwh: 58.5,
    previousKwh: 61.2,
    estimatedCost: 10.53,
    goalKwh: _defaultGoalKwh,
  );

  static final List<EnergyUsageHistoryEntry> _baselineHistory =
      List<EnergyUsageHistoryEntry>.generate(10, (int index) {
    final day = DateTime.now().subtract(Duration(days: 9 - index));
    final usage = 46 + index * 1.2;
    return EnergyUsageHistoryEntry(
      date: day,
      kwh: double.parse(usage.toStringAsFixed(1)),
    );
  });

  static final List<EnergyUsageTip> _tips = [
    const EnergyUsageTip(
      id: 'nightMode',
      titleKey: 'energyTipNightModeTitle',
      bodyKey: 'energyTipNightModeBody',
      icon: Icons.nights_stay,
    ),
    const EnergyUsageTip(
      id: 'filterCare',
      titleKey: 'energyTipFilterCareTitle',
      bodyKey: 'energyTipFilterCareBody',
      icon: Icons.filter_alt,
    ),
    const EnergyUsageTip(
      id: 'circulation',
      titleKey: 'energyTipCirculationTitle',
      bodyKey: 'energyTipCirculationBody',
      icon: Icons.air_outlined,
    ),
  ];
}
