import 'package:flutter/material.dart';

import '../../app_scope.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/utils/context_extensions.dart';
import '../../shared/models/energy_usage.dart';
import '../../shared/widgets/energy_tip_card.dart';
import '../../shared/widgets/energy_usage_chart.dart';
import '../../shared/widgets/energy_usage_summary_card.dart';

class EnergyPage extends StatelessWidget {
  const EnergyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    final controller = scope.energyUsageController;
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.getString('energyTitle')),
      ),
      body: RefreshIndicator(
        onRefresh: controller.refresh,
        child: ListView(
          padding: const EdgeInsets.all(24),
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            ValueListenableBuilder<EnergyUsageSnapshot>(
              valueListenable: controller.snapshotNotifier,
              builder: (context, snapshot, _) {
                final monthLabel = _monthLabel(l10n, snapshot.period);
                final change = snapshot.changePercent;
                final changeLabel = _changeLabel(l10n, change);
                return EnergyUsageSummaryCard(
                  snapshot: snapshot,
                  periodLabel: l10n
                      .getString('energySummaryPeriod')
                      .replaceFirst('{month}', monthLabel),
                  usageLabel: l10n.getString('energyUsageLabel'),
                  costLabel: l10n.getString('energyCostLabel'),
                  goalLabel: l10n.getString('energyGoalLabel'),
                  changeLabel: changeLabel,
                  currencySymbol: l10n.getString('currencySymbol'),
                  onTapRefresh: () {
                    controller.refresh();
                  },
                );
              },
            ),
            const SizedBox(height: 24),
            ValueListenableBuilder<List<EnergyUsageHistoryEntry>>(
              valueListenable: controller.historyNotifier,
              builder: (context, entries, _) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.getString('energyHistoryTitle'),
                      style: context.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    EnergyUsageChart(
                      entries: entries,
                      emptyLabel: l10n.getString('energyHistoryEmpty'),
                      labelBuilder: (date) =>
                          l10n.getString(_dayKeyFor(date.weekday)),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),
            ValueListenableBuilder<bool>(
              valueListenable: controller.ecoModeNotifier,
              builder: (context, ecoEnabled, _) {
                return SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  value: ecoEnabled,
                  onChanged: (value) => controller.setEcoMode(value),
                  title: Text(l10n.getString('energyEcoToggle')),
                  subtitle: Text(l10n.getString('energyEcoDescription')),
                );
              },
            ),
            const SizedBox(height: 12),
            ValueListenableBuilder<double>(
              valueListenable: controller.goalNotifier,
              builder: (context, goal, _) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          l10n.getString('energyGoalTitle'),
                          style: context.textTheme.titleMedium,
                        ),
                        Text(
                          '${goal.toStringAsFixed(0)} kWh',
                          style: context.textTheme.labelLarge,
                        ),
                      ],
                    ),
                    Slider(
                      min: 30,
                      max: 120,
                      divisions: 18,
                      label: '${goal.toStringAsFixed(0)} kWh',
                      value: goal,
                      onChanged: (value) => controller.setGoal(value),
                    ),
                    Text(
                      l10n.getString('energyGoalHint'),
                      style: context.textTheme.bodySmall,
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),
            Text(
              l10n.getString('energyTipsTitle'),
              style: context.textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            ValueListenableBuilder<List<EnergyUsageTip>>(
              valueListenable: controller.tipsNotifier,
              builder: (context, tips, _) {
                return Column(
                  children: [
                    for (final tip in tips) ...[
                      EnergyTipCard(
                        tip: tip,
                        title: l10n.getString(tip.titleKey),
                        body: l10n.getString(tip.bodyKey),
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

  String _monthLabel(AppLocalizations l10n, DateTime date) {
    final key = 'month${date.month.toString().padLeft(2, '0')}';
    return l10n.getString(key);
  }

  String _changeLabel(AppLocalizations l10n, double change) {
    if (change.abs() < 0.5) {
      return l10n.getString('energyChangeStable');
    }
    final formatted = change.abs().toStringAsFixed(1);
    final key = change < 0 ? 'energyChangeDown' : 'energyChangeUp';
    return l10n.getString(key).replaceFirst('{percent}', formatted);
  }

  String _dayKeyFor(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return 'scheduleDayMon';
      case DateTime.tuesday:
        return 'scheduleDayTue';
      case DateTime.wednesday:
        return 'scheduleDayWed';
      case DateTime.thursday:
        return 'scheduleDayThu';
      case DateTime.friday:
        return 'scheduleDayFri';
      case DateTime.saturday:
        return 'scheduleDaySat';
      case DateTime.sunday:
      default:
        return 'scheduleDaySun';
    }
  }
}
