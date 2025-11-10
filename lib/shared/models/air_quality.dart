import 'package:flutter/material.dart';

enum AirQualityTrend {
  improving,
  steady,
  declining,
}

class AirQualitySnapshot {
  const AirQualitySnapshot({
    required this.timestamp,
    required this.score,
    required this.pm25,
    required this.pm10,
    required this.co2,
    required this.trend,
  });

  final DateTime timestamp;
  final int score;
  final double pm25;
  final double pm10;
  final int co2;
  final AirQualityTrend trend;

  AirQualitySnapshot copyWith({
    DateTime? timestamp,
    int? score,
    double? pm25,
    double? pm10,
    int? co2,
    AirQualityTrend? trend,
  }) {
    return AirQualitySnapshot(
      timestamp: timestamp ?? this.timestamp,
      score: score ?? this.score,
      pm25: pm25 ?? this.pm25,
      pm10: pm10 ?? this.pm10,
      co2: co2 ?? this.co2,
      trend: trend ?? this.trend,
    );
  }
}

class AirQualityHistoryEntry {
  const AirQualityHistoryEntry({
    required this.date,
    required this.score,
    required this.pm25,
  });

  final DateTime date;
  final int score;
  final double pm25;

  AirQualityHistoryEntry copyWith({
    DateTime? date,
    int? score,
    double? pm25,
  }) {
    return AirQualityHistoryEntry(
      date: date ?? this.date,
      score: score ?? this.score,
      pm25: pm25 ?? this.pm25,
    );
  }
}

class AirQualityInsight {
  const AirQualityInsight({
    required this.id,
    required this.titleKey,
    required this.bodyKey,
    required this.icon,
    this.highlightKey,
  });

  final String id;
  final String titleKey;
  final String bodyKey;
  final IconData icon;
  final String? highlightKey;
}
