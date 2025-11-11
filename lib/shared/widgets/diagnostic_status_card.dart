import 'package:flutter/material.dart';

import '../../core/l10n/app_localizations.dart';
import '../../core/theme/design_tokens.dart';
import '../models/device_diagnostic.dart';
import 'primary_button.dart';

class DiagnosticStatusCard extends StatelessWidget {
  const DiagnosticStatusCard({
    super.key,
    required this.diagnostic,
    required this.l10n,
    required this.onRunCheck,
    required this.onResolve,
    required this.onAutoTuneChanged,
  });

  final DeviceDiagnostic diagnostic;
  final AppLocalizations l10n;
  final VoidCallback onRunCheck;
  final VoidCallback onResolve;
  final ValueChanged<bool> onAutoTuneChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = _statusColor(theme, diagnostic.status);
    final statusLabel = l10n.getString(diagnostic.statusLocalizationKey);
    final lastCheckedLabel = _lastCheckedLabel(l10n, diagnostic.lastChecked);
    final advisories = diagnostic.advisoryKeys;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: statusColor.withOpacity(0.24)),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.06),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
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
                      diagnostic.deviceName,
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Text(
                        statusLabel,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.health_and_safety,
                color: statusColor,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            lastCheckedLabel,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 16),
          if (advisories.isEmpty)
            _AdvisoryChip(
              label: l10n.getString('diagnosticsNoIssues'),
              backgroundColor: theme.colorScheme.primary.withOpacity(0.12),
              foregroundColor: theme.colorScheme.primary,
            )
          else
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: advisories
                  .map(
                    (key) => _AdvisoryChip(
                      label: l10n.getString(key),
                      backgroundColor: statusColor.withOpacity(0.12),
                      foregroundColor: statusColor,
                    ),
                  )
                  .toList(),
            ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  l10n.getString('diagnosticsAutoTuneLabel'),
                  style: theme.textTheme.bodyMedium,
                ),
              ),
              Switch.adaptive(
                value: diagnostic.autoTuneEnabled,
                onChanged: onAutoTuneChanged,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            diagnostic.issueCount > 0
                ? l10n
                    .getString('diagnosticsIssueCount')
                    .replaceFirst('{count}', diagnostic.issueCount.toString())
                : l10n.getString('diagnosticsNoIssues'),
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: PrimaryButton(
                  label: l10n.getString('diagnosticsRunQuickCheck'),
                  icon: Icons.speed,
                  onPressed: onRunCheck,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                ),
              ),
              const SizedBox(width: 16),
              TextButton(
                onPressed: onResolve,
                style: TextButton.styleFrom(
                  foregroundColor: theme.colorScheme.primary,
                ),
                child: Text(l10n.getString('diagnosticsMarkResolved')),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _lastCheckedLabel(AppLocalizations l10n, DateTime lastChecked) {
    final difference = DateTime.now().difference(lastChecked);
    if (difference.inDays >= 1) {
      final days = difference.inDays;
      return l10n
          .getString('diagnosticsLastCheckedDays')
          .replaceFirst('{days}', days.toString());
    }
    final hours = difference.inHours.clamp(1, 23);
    return l10n
        .getString('diagnosticsLastCheckedHours')
        .replaceFirst('{hours}', hours.toString());
  }

  Color _statusColor(ThemeData theme, DiagnosticStatus status) {
    switch (status) {
      case DiagnosticStatus.optimal:
        return theme.colorScheme.primary;
      case DiagnosticStatus.attention:
        return DesignTokens.accentSky;
      case DiagnosticStatus.critical:
        return theme.colorScheme.error;
    }
  }
}

class _AdvisoryChip extends StatelessWidget {
  const _AdvisoryChip({
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
  });

  final String label;
  final Color backgroundColor;
  final Color foregroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: foregroundColor,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}
