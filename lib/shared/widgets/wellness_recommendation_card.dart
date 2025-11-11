import 'package:flutter/material.dart';

import '../../core/l10n/app_localizations.dart';
import '../models/wellness_recommendation.dart';

class WellnessRecommendationCard extends StatelessWidget {
  const WellnessRecommendationCard({
    super.key,
    required this.recommendation,
    required this.onPinToggle,
    required this.onDismiss,
  });

  final WellnessRecommendation recommendation;
  final VoidCallback onPinToggle;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final pinned = recommendation.pinned;

    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.getString(recommendation.titleKey),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.getString(recommendation.bodyKey),
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: onPinToggle,
                  tooltip: pinned
                      ? l10n.getString('wellnessTipUnpin')
                      : l10n.getString('wellnessTipPin'),
                  icon: Icon(
                    pinned ? Icons.push_pin : Icons.push_pin_outlined,
                    color: pinned ? theme.colorScheme.primary : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Chip(
                  label: Text(l10n.getString(recommendation.tagKey)),
                  backgroundColor:
                      theme.colorScheme.primary.withOpacity(0.12),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: onDismiss,
                  icon: const Icon(Icons.close),
                  label: Text(l10n.getString('wellnessTipDismiss')),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
