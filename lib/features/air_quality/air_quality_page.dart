import 'package:flutter/material.dart';

import '../../app_scope.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/utils/context_extensions.dart';
import '../../shared/models/air_quality.dart';
import '../../shared/widgets/air_quality_gauge.dart';
import '../../shared/widgets/air_quality_history_chart.dart';
import '../../shared/widgets/air_quality_insight_card.dart';

class AirQualityPage extends StatelessWidget {
  const AirQualityPage({super.key});

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    final controller = scope.airQualityController;
    final l10n = context.l10n;
    final focusOptions = [
      _FocusOption('comfort', l10n.getString('airQualityFocusComfort')),
      _FocusOption('allergies', l10n.getString('airQualityFocusAllergies')),
      _FocusOption('productivity', l10n.getString('airQualityFocusProductivity')),
    ];
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.getString('airQualityTitle')),
      ),
      body: RefreshIndicator(
        onRefresh: controller.refresh,
        child: ListView(
          padding: const EdgeInsets.all(24),
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            ValueListenableBuilder<AirQualitySnapshot>(
              valueListenable: controller.snapshotNotifier,
              builder: (context, snapshot, _) {
                return _AirQualityCurrentCard(snapshot: snapshot);
              },
            ),
            const SizedBox(height: 24),
            ValueListenableBuilder<List<AirQualityHistoryEntry>>(
              valueListenable: controller.historyNotifier,
              builder: (context, history, _) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.getString('airQualityWeeklyHeadline'),
                      style: context.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    AirQualityHistoryChart(history: history),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),
            Text(
              l10n.getString('airQualityFocusTitle'),
              style: context.textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            ValueListenableBuilder<String>(
              valueListenable: controller.focusNotifier,
              builder: (context, focus, _) {
                return Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    for (final option in focusOptions)
                      ChoiceChip(
                        label: Text(option.label),
                        selected: option.id == focus,
                        onSelected: (_) {
                          controller.setFocus(option.id);
                        },
                      ),
                  ],
                );
              },
            ),
            const SizedBox(height: 8),
            Text(
              l10n.getString('airQualityFocusHint'),
              style: context.textTheme.bodySmall,
            ),
            const SizedBox(height: 24),
            ValueListenableBuilder<bool>(
              valueListenable: controller.alertsEnabledNotifier,
              builder: (context, enabled, _) {
                return SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  value: enabled,
                  onChanged: (value) {
                    controller.setAlertsEnabled(value);
                  },
                  title: Text(l10n.getString('airQualityAlertsToggle')),
                  subtitle: Text(l10n.getString('airQualityAlertsDescription')),
                );
              },
            ),
            const SizedBox(height: 12),
            Text(
              l10n.getString('airQualityInsightsTitle'),
              style: context.textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            ValueListenableBuilder<List<AirQualityInsight>>(
              valueListenable: controller.insightsNotifier,
              builder: (context, insights, _) {
                return Column(
                  children: [
                    for (final insight in insights) ...[
                      AirQualityInsightCard(
                        insight: insight,
                        title: l10n.getString(insight.titleKey),
                        body: l10n.getString(insight.bodyKey),
                        highlight: insight.highlightKey != null
                            ? l10n.getString(insight.highlightKey!)
                            : null,
                      ),
                      const SizedBox(height: 16),
                    ],
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _AirQualityCurrentCard extends StatelessWidget {
  const _AirQualityCurrentCard({
    required this.snapshot,
  });

  final AirQualitySnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final trendLabel = _trendLabel(snapshot.trend, l10n);
    final labelStyle = theme.textTheme.labelMedium;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary.withOpacity(0.12),
            theme.colorScheme.primary.withOpacity(0.04),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.getString('airQualitySubtitle'),
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              AirQualityGauge(
                snapshot: snapshot,
                size: 140,
                trendLabel: trendLabel,
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n
                          .getString('airQualityUpdatedJustNow'),
                      style: labelStyle,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _metricTile(
                            context,
                            label: l10n.getString('airQualityPm25'),
                            value: '${snapshot.pm25.toStringAsFixed(1)} µg/m³',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _metricTile(
                            context,
                            label: l10n.getString('airQualityPm10'),
                            value: '${snapshot.pm10.toStringAsFixed(1)} µg/m³',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _metricTile(
                      context,
                      label: l10n.getString('airQualityCo2'),
                      value: '${snapshot.co2} ppm',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _metricTile(
    BuildContext context, {
    required String label,
    required String value,
  }) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelMedium,
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: theme.textTheme.titleSmall,
          ),
        ],
      ),
    );
  }

  String _trendLabel(AirQualityTrend trend, AppLocalizations l10n) {
    switch (trend) {
      case AirQualityTrend.improving:
        return l10n.getString('airQualityTrendImproving');
      case AirQualityTrend.steady:
        return l10n.getString('airQualityTrendSteady');
      case AirQualityTrend.declining:
        return l10n.getString('airQualityTrendDeclining');
    }
  }
}

class _FocusOption {
  const _FocusOption(this.id, this.label);

  final String id;
  final String label;
}
