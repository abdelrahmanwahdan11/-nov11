import 'package:flutter/material.dart';

import '../../core/l10n/app_localizations.dart';
import '../models/wellness_trend.dart';

class WellnessTrendChart extends StatelessWidget {
  const WellnessTrendChart({
    super.key,
    required this.points,
  });

  final List<WellnessTrendPoint> points;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    if (points.isEmpty) {
      return const SizedBox.shrink();
    }
    final maxValue = points.fold<double>(0, (previous, element) {
      return element.value > previous ? element.value : previous;
    });

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: theme.cardColor,
        border: Border.all(color: theme.colorScheme.primary.withOpacity(0.08)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: points.map((point) {
          final ratio = maxValue == 0 ? 0.0 : point.value / maxValue;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 420),
                    curve: Curves.easeOutCubic,
                    height: 120 * ratio + 24,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          theme.colorScheme.primary,
                          theme.colorScheme.primary.withOpacity(0.4),
                        ],
                      ),
                    ),
                    alignment: Alignment.topCenter,
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      point.value.toStringAsFixed(0),
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: theme.colorScheme.onPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.getString(point.labelKey),
                    style: theme.textTheme.labelSmall,
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
