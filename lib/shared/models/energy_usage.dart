import 'package:flutter/material.dart';

class EnergyUsageSnapshot {
  const EnergyUsageSnapshot({
    required this.period,
    required this.totalKwh,
    required this.previousKwh,
    required this.estimatedCost,
    required this.goalKwh,
  });

  final DateTime period;
  final double totalKwh;
  final double previousKwh;
  final double estimatedCost;
  final double goalKwh;

  double get changePercent {
    if (previousKwh == 0) {
      return 0;
    }
    return ((totalKwh - previousKwh) / previousKwh) * 100;
  }

  double get goalProgress {
    if (goalKwh == 0) {
      return 0;
    }
    return (totalKwh / goalKwh).clamp(0, 2);
  }

  EnergyUsageSnapshot copyWith({
    DateTime? period,
    double? totalKwh,
    double? previousKwh,
    double? estimatedCost,
    double? goalKwh,
  }) {
    return EnergyUsageSnapshot(
      period: period ?? this.period,
      totalKwh: totalKwh ?? this.totalKwh,
      previousKwh: previousKwh ?? this.previousKwh,
      estimatedCost: estimatedCost ?? this.estimatedCost,
      goalKwh: goalKwh ?? this.goalKwh,
    );
  }
}

class EnergyUsageHistoryEntry {
  const EnergyUsageHistoryEntry({
    required this.date,
    required this.kwh,
  });

  final DateTime date;
  final double kwh;

  EnergyUsageHistoryEntry copyWith({
    DateTime? date,
    double? kwh,
  }) {
    return EnergyUsageHistoryEntry(
      date: date ?? this.date,
      kwh: kwh ?? this.kwh,
    );
  }
}

class EnergyUsageTip {
  const EnergyUsageTip({
    required this.id,
    required this.titleKey,
    required this.bodyKey,
    required this.icon,
  });

  final String id;
  final String titleKey;
  final String bodyKey;
  final IconData icon;
}
