import 'package:flutter/foundation.dart';

@immutable
class ComfortSnapshot {
  const ComfortSnapshot({
    required this.timestamp,
    required this.score,
    required this.humidity,
    required this.temperature,
    required this.focus,
  });

  final DateTime timestamp;
  final int score;
  final double humidity;
  final double temperature;
  final String focus;

  ComfortSnapshot copyWith({
    DateTime? timestamp,
    int? score,
    double? humidity,
    double? temperature,
    String? focus,
  }) {
    return ComfortSnapshot(
      timestamp: timestamp ?? this.timestamp,
      score: score ?? this.score,
      humidity: humidity ?? this.humidity,
      temperature: temperature ?? this.temperature,
      focus: focus ?? this.focus,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'score': score,
      'humidity': humidity,
      'temperature': temperature,
      'focus': focus,
    };
  }

  factory ComfortSnapshot.fromJson(Map<String, dynamic> json) {
    return ComfortSnapshot(
      timestamp: DateTime.parse(json['timestamp'] as String),
      score: json['score'] as int,
      humidity: (json['humidity'] as num).toDouble(),
      temperature: (json['temperature'] as num).toDouble(),
      focus: json['focus'] as String,
    );
  }
}
