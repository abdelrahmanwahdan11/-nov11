import 'package:flutter/material.dart';

import '../models/energy_usage.dart';

class EnergyUsageSummaryCard extends StatelessWidget {
  const EnergyUsageSummaryCard({
    super.key,
    required this.snapshot,
    required this.periodLabel,
    required this.usageLabel,
    required this.costLabel,
    required this.goalLabel,
    required this.changeLabel,
    required this.currencySymbol,
    this.onTapRefresh,
  });

  final EnergyUsageSnapshot snapshot;
  final String periodLabel;
  final String usageLabel;
  final String costLabel;
  final String goalLabel;
  final String changeLabel;
  final String currencySymbol;
  final VoidCallback? onTapRefresh;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final change = snapshot.changePercent;
    final changeColor = change <= 0
        ? theme.colorScheme.primary
        : theme.colorScheme.error.withOpacity(0.84);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        color: theme.cardColor,
        border: Border.all(color: theme.colorScheme.primary.withOpacity(0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  periodLabel,
                  style: theme.textTheme.titleLarge,
                ),
              ),
              if (onTapRefresh != null)
                IconButton(
                  onPressed: onTapRefresh,
                  icon: const Icon(Icons.refresh),
                ),
            ],
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 20,
            runSpacing: 16,
            children: [
              _statTile(
                context,
                label: usageLabel,
                value: '${snapshot.totalKwh.toStringAsFixed(1)} kWh',
              ),
              _statTile(
                context,
                label: costLabel,
                value:
                    '$currencySymbol${snapshot.estimatedCost.toStringAsFixed(2)}',
              ),
              _statTile(
                context,
                label: goalLabel,
                value: '${snapshot.goalKwh.toStringAsFixed(0)} kWh',
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                change <= 0 ? Icons.trending_down : Icons.trending_up,
                color: changeColor,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  changeLabel,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: changeColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statTile(BuildContext context,
      {required String label, required String value}) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelLarge,
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
