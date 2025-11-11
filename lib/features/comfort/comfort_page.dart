import 'package:flutter/material.dart';

import '../../app_scope.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/utils/context_extensions.dart';
import '../../shared/controllers/comfort_controller.dart';
import '../../shared/models/comfort_snapshot.dart';
import '../../shared/widgets/comfort_score_ring.dart';
import '../../shared/widgets/comfort_tip_card.dart';
import '../../shared/widgets/primary_button.dart';

class ComfortPage extends StatelessWidget {
  const ComfortPage({super.key});

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    final controller = scope.comfortController;
    final l10n = context.l10n;
    final focusLabels = _focusLabels(l10n);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.getString('comfortTitle')),
      ),
      body: ValueListenableBuilder<String>(
        valueListenable: controller.focusNotifier,
        builder: (context, focus, _) {
          return ValueListenableBuilder<List<ComfortSnapshot>>(
            valueListenable: controller.snapshotsNotifier,
            builder: (context, snapshots, __) {
              final average = controller.averageScoreForFocus(focus);
              final trend = controller.trendForFocus(focus);
              final lastUpdated = controller.lastUpdated();
              final timeline =
                  controller.timelineForFocus(focus).reversed.toList();
              final limitedTimeline = timeline.take(10).toList();
              final focusTips = controller.tipsForFocus(focus);
              final color = Theme.of(context).colorScheme.primary;
              final subtitle = l10n.getString('comfortScoreLabel');
              return ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                children: [
                  Text(
                    l10n.getString('comfortSubtitle'),
                    style: context.textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 24),
                  Align(
                    child: ComfortScoreRing(
                      score: average,
                      color: color,
                      subtitle: subtitle,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _TrendChip(
                          label: _trendLabel(l10n, trend),
                          icon: _trendIcon(trend),
                          background: color.withOpacity(0.12),
                          foreground: color,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _InfoChip(
                          label: l10n.getString('comfortLastUpdated'),
                          value: lastUpdated != null
                              ? _formatTimestamp(context, lastUpdated)
                              : l10n.getString('comfortNoSessions'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    l10n.getString('comfortFocusTitle'),
                    style: context.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: ComfortController.focuses
                        .map(
                          (key) => ChoiceChip(
                            label: Text(focusLabels[key] ?? key),
                            selected: focus == key,
                            onSelected: (_) => controller.setFocus(key),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 24),
                  PrimaryButton(
                    label: l10n.getString('comfortAddEntry'),
                    icon: Icons.brightness_low,
                    onPressed: snapshots.isEmpty
                        ? null
                        : () {
                            final snapshot = _generateSnapshot(controller, focus);
                            controller.logSession(snapshot);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content:
                                    Text(l10n.getString('comfortAddEntrySnack')),
                              ),
                            );
                          },
                  ),
                  const SizedBox(height: 32),
                  ValueListenableBuilder<bool>(
                    valueListenable: controller.autoBalanceNotifier,
                    builder: (context, autoBalance, _) {
                      return SwitchListTile.adaptive(
                        value: autoBalance,
                        onChanged: controller.toggleAutoBalance,
                        title: Text(l10n.getString('comfortAutoBalance')),
                        subtitle: Text(
                          l10n.getString('comfortAutoBalanceDescription'),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  ValueListenableBuilder<bool>(
                    valueListenable: controller.remindersEnabledNotifier,
                    builder: (context, reminders, _) {
                      return SwitchListTile.adaptive(
                        value: reminders,
                        onChanged: controller.toggleReminders,
                        title: Text(l10n.getString('comfortReminders')),
                        subtitle: Text(
                          l10n.getString('comfortRemindersDescription'),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 32),
                  Text(
                    l10n.getString('comfortPinned'),
                    style: context.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  ValueListenableBuilder<Set<String>>(
                    valueListenable: controller.pinnedTipsNotifier,
                    builder: (context, pinned, _) {
                      final pinnedTips = controller.pinnedTips();
                      if (pinnedTips.isEmpty) {
                        return _EmptyStateCard(
                          message: l10n.getString('comfortPinnedEmpty'),
                        );
                      }
                      return Column(
                        children: [
                          for (final tip in pinnedTips) ...[
                            ComfortTipCard(
                              title: l10n.getString(tip.titleKey),
                              description: l10n.getString(tip.descriptionKey),
                              pinned: pinned.contains(tip.id),
                              accent: color,
                              onTogglePin: () => controller.toggleTipPinned(tip.id),
                            ),
                            const SizedBox(height: 16),
                          ],
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 32),
                  Text(
                    l10n.getString('comfortInsights'),
                    style: context.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  Column(
                    children: [
                      for (final tip in focusTips) ...[
                        ComfortTipCard(
                          title: l10n.getString(tip.titleKey),
                          description: l10n.getString(tip.descriptionKey),
                          pinned: controller.pinnedTipsNotifier.value
                              .contains(tip.id),
                          accent: color.withOpacity(0.85),
                          onTogglePin: () => controller.toggleTipPinned(tip.id),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    l10n.getString('comfortTimeline'),
                    style: context.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  if (timeline.isEmpty)
                    _EmptyStateCard(
                      message: l10n.getString('comfortNoSessions'),
                    )
                  else
                    SizedBox(
                      height: 160,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index) {
                          final session = limitedTimeline[index];
                          return _TimelineCard(
                            snapshot: session,
                            focusLabel: focusLabels[session.focus] ?? session.focus,
                            color: color,
                          );
                        },
                        separatorBuilder: (_, __) => const SizedBox(width: 16),
                        itemCount: limitedTimeline.length,
                      ),
                    ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Map<String, String> _focusLabels(AppLocalizations l10n) {
    return {
      'sleep': l10n.getString('comfortFocusSleep'),
      'productivity': l10n.getString('comfortFocusProductivity'),
      'allergy': l10n.getString('comfortFocusAllergy'),
    };
  }
}

ComfortSnapshot _generateSnapshot(ComfortController controller, String focus) {
  final last = controller.latestForFocus(focus);
  final baseScore = last?.score ?? 72;
  final score = (baseScore + 2).clamp(0, 100);
  final humidity = ((last?.humidity ?? 48) + 0.5).clamp(35, 60);
  final temperature = ((last?.temperature ?? 23) - 0.3).clamp(18.0, 27.0);
  return ComfortSnapshot(
    timestamp: DateTime.now(),
    score: score.toInt(),
    humidity: humidity.toDouble(),
    temperature: temperature.toDouble(),
    focus: focus,
  );
}

String _trendLabel(AppLocalizations l10n, ComfortTrend trend) {
  switch (trend) {
    case ComfortTrend.improving:
      return l10n.getString('comfortTrendImproving');
    case ComfortTrend.declining:
      return l10n.getString('comfortTrendDeclining');
    case ComfortTrend.steady:
    default:
      return l10n.getString('comfortTrendStable');
  }
}

IconData _trendIcon(ComfortTrend trend) {
  switch (trend) {
    case ComfortTrend.improving:
      return Icons.trending_up;
    case ComfortTrend.declining:
      return Icons.trending_down;
    case ComfortTrend.steady:
    default:
      return Icons.trending_flat;
  }
}

String _formatTimestamp(BuildContext context, DateTime timestamp) {
  final material = MaterialLocalizations.of(context);
  final date = material.formatShortDate(timestamp);
  final time = material.formatTimeOfDay(
    TimeOfDay.fromDateTime(timestamp),
  );
  return '$date • $time';
}

class _TrendChip extends StatelessWidget {
  const _TrendChip({
    required this.label,
    required this.icon,
    required this.background,
    required this.foreground,
  });

  final String label;
  final IconData icon;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Icon(icon, color: foreground),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelMedium,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelineCard extends StatelessWidget {
  const _TimelineCard({
    required this.snapshot,
    required this.focusLabel,
    required this.color,
  });

  final ComfortSnapshot snapshot;
  final String focusLabel;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final material = MaterialLocalizations.of(context);
    return Container(
      width: 200,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.2),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    '${snapshot.score}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      focusLabel,
                      style: theme.textTheme.labelLarge,
                    ),
                    Text(
                      material.formatTimeOfDay(
                        TimeOfDay.fromDateTime(snapshot.timestamp),
                      ),
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Spacer(),
          Row(
            children: [
              Icon(Icons.water_drop, size: 18, color: color),
              const SizedBox(width: 8),
              Text('${snapshot.humidity.toStringAsFixed(0)}%'),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.thermostat, size: 18, color: color),
              const SizedBox(width: 8),
              Text('${snapshot.temperature.toStringAsFixed(1)}°'),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            material.formatShortDate(snapshot.timestamp),
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _EmptyStateCard extends StatelessWidget {
  const _EmptyStateCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: theme.colorScheme.outlineVariant,
        ),
      ),
      child: Text(
        message,
        style: theme.textTheme.bodyMedium,
      ),
    );
  }
}
