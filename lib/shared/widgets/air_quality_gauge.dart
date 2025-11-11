import 'package:flutter/material.dart';

import '../models/air_quality.dart';

class AirQualityGauge extends StatelessWidget {
  const AirQualityGauge({
    super.key,
    required this.snapshot,
    required this.size,
    required this.trendLabel,
  });

  final AirQualitySnapshot snapshot;
  final double size;
  final String trendLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _colorForScore(snapshot.score, theme.colorScheme.primary);
    final icon = _trendIcon(snapshot.trend);
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: snapshot.score / 100,
              strokeWidth: 10,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              backgroundColor: theme.colorScheme.surfaceVariant.withOpacity(0.25),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    snapshot.score.toString(),
                    style: theme.textTheme.displaySmall?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(icon, color: color, size: 20),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                trendLabel,
                style: theme.textTheme.labelMedium,
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _trendIcon(AirQualityTrend trend) {
    switch (trend) {
      case AirQualityTrend.improving:
        return Icons.arrow_upward;
      case AirQualityTrend.declining:
        return Icons.arrow_downward;
      case AirQualityTrend.steady:
        return Icons.remove;
    }
  }

  Color _colorForScore(int score, Color primary) {
    if (score >= 85) {
      return Colors.greenAccent.shade400;
    }
    if (score >= 70) {
      return Colors.orangeAccent.shade400;
    }
    return primary;
  }
}
