import 'package:flutter/material.dart';

class WellnessMetric {
  const WellnessMetric({
    required this.id,
    required this.titleKey,
    required this.subtitleKey,
    required this.score,
    required this.trendDelta,
    required this.accent,
  });

  final String id;
  final String titleKey;
  final String subtitleKey;
  final double score;
  final double trendDelta;
  final Color accent;

  WellnessMetric copyWith({
    double? score,
    double? trendDelta,
  }) {
    return WellnessMetric(
      id: id,
      titleKey: titleKey,
      subtitleKey: subtitleKey,
      score: score ?? this.score,
      trendDelta: trendDelta ?? this.trendDelta,
      accent: accent,
    );
  }
}
