import 'package:flutter/material.dart';

import '../../core/l10n/app_localizations.dart';
import '../models/air_quality.dart';
import '../utils/schedule_formatter.dart';

class AirQualityHistoryChart extends StatelessWidget {
  const AirQualityHistoryChart({
    super.key,
    required this.history,
  });

  final List<AirQualityHistoryEntry> history;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    if (history.isEmpty) {
      return const SizedBox.shrink();
    }
    final maxScore = history
        .map((entry) => entry.score)
        .fold<int>(0, (int previous, int element) {
      return element > previous ? element : previous;
    });
    return SizedBox(
      height: 160,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: history.map((entry) {
          final ratio = maxScore == 0 ? 0.0 : entry.score / maxScore;
          return Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                  height: 100 * ratio + 24,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.18 + (ratio * 0.45)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.bottomCenter,
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    entry.score.toString(),
                    style: theme.textTheme.labelLarge,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  ScheduleFormatter.labelForWeekday(l10n, entry.date.weekday),
                  style: theme.textTheme.labelSmall,
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
