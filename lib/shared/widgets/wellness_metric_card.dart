import 'package:flutter/material.dart';

import '../../core/l10n/app_localizations.dart';
import '../models/wellness_metric.dart';

class WellnessMetricCard extends StatelessWidget {
  const WellnessMetricCard({
    super.key,
    required this.metric,
    required this.focused,
    required this.onFocus,
  });

  final WellnessMetric metric;
  final bool focused;
  final VoidCallback onFocus;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final progress = (metric.score / 100).clamp(0.0, 1.0);
    final delta = metric.trendDelta;
    final trendIsPositive = delta >= 0;
    final trendIcon = trendIsPositive ? Icons.trending_up : Icons.trending_down;
    final trendColor = trendIsPositive
        ? theme.colorScheme.primary
        : theme.colorScheme.error;
    final trendLabel =
        '${trendIsPositive ? '+' : '-'}${delta.abs().toStringAsFixed(1)}%';

    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOut,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: focused
            ? metric.accent.withOpacity(0.16)
            : theme.cardColor,
        border: Border.all(
          color: focused
              ? metric.accent.withOpacity(0.6)
              : theme.colorScheme.primary.withOpacity(0.06),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: metric.accent.withOpacity(0.22),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  l10n.getString(metric.titleKey),
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: focused ? null : onFocus,
                icon: Icon(
                  focused ? Icons.check_circle : Icons.brightness_auto,
                  color: focused ? metric.accent : null,
                ),
                label: Text(
                  focused
                      ? l10n.getString('wellnessFocusActive')
                      : l10n.getString('wellnessFocusSet'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            l10n.getString(metric.subtitleKey),
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: progress),
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: LinearProgressIndicator(
                      value: value,
                      minHeight: 12,
                      backgroundColor: metric.accent.withOpacity(0.18),
                      valueColor:
                          AlwaysStoppedAnimation<Color>(metric.accent),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Text(
                        '${metric.score.toStringAsFixed(0)}%',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Chip(
                        avatar: Icon(
                          trendIcon,
                          size: 18,
                          color: trendColor,
                        ),
                        label: Text(trendLabel),
                        labelStyle: theme.textTheme.labelMedium?.copyWith(
                          color: trendColor,
                          fontWeight: FontWeight.w600,
                        ),
                        backgroundColor: trendColor.withOpacity(0.12),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
