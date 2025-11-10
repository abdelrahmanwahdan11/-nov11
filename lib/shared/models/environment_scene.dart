import 'package:flutter/material.dart';

class EnvironmentScene {
  const EnvironmentScene({
    required this.id,
    required this.titleKey,
    required this.subtitleKey,
    required this.imageSeed,
    required this.gradientStart,
    required this.gradientEnd,
    required this.metrics,
    this.highlightKeys = const <String>[],
  });

  final String id;
  final String titleKey;
  final String subtitleKey;
  final String imageSeed;
  final Color gradientStart;
  final Color gradientEnd;
  final EnvironmentMetrics metrics;
  final List<String> highlightKeys;

  String get imageUrl => 'https://picsum.photos/seed/'
      '$imageSeed/960/1440';
}

class EnvironmentMetrics {
  const EnvironmentMetrics({
    required this.airQuality,
    required this.humidity,
    required this.temperatureC,
  });

  final int airQuality;
  final int humidity;
  final double temperatureC;
}
