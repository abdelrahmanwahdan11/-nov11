import 'package:flutter/material.dart';

import '../../core/l10n/app_localizations.dart';
import '../models/maintenance_task.dart';

class MaintenanceTaskCard extends StatelessWidget {
  const MaintenanceTaskCard({
    super.key,
    required this.task,
    required this.l10n,
    this.onComplete,
    this.onSnooze,
    this.compact = false,
  });

  final MaintenanceTask task;
  final AppLocalizations l10n;
  final VoidCallback? onComplete;
  final VoidCallback? onSnooze;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusLabel = _statusLabel(context);
    final statusColor = _statusColor(context);
    final dueDescription = _dueDescription(context);
    final surface = theme.colorScheme.surface;
    final borderRadius = BorderRadius.circular(compact ? 20 : 24);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: surface,
        borderRadius: borderRadius,
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.08),
            offset: const Offset(0, 10),
            blurRadius: 25,
          ),
        ],
        border: Border.all(
          color: statusColor.withOpacity(0.22),
          width: 1.2,
        ),
      ),
      padding: EdgeInsets.all(compact ? 16 : 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.16),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.autorenew,
                  color: statusColor,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.getString(task.titleKey),
                      style: theme.textTheme.titleMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.getString(task.descriptionKey),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.textTheme.bodyMedium?.color?.withOpacity(0.75),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.16),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  statusLabel,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  dueDescription,
                  style: theme.textTheme.bodySmall,
                ),
              ),
            ],
          ),
          if (task.lastCompleted != null) ...[
            const SizedBox(height: 12),
            Text(
              l10n
                  .getString('maintenanceLastCompleted')
                  .replaceFirst('{date}', _formatDate(context, task.lastCompleted!)),
              style: theme.textTheme.bodySmall,
            ),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              if (onComplete != null)
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onComplete,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: statusColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    icon: const Icon(Icons.check_circle_outline),
                    label: Text(l10n.getString('maintenanceActionComplete')),
                  ),
                ),
              if (onComplete != null && onSnooze != null)
                const SizedBox(width: 12),
              if (onSnooze != null)
                Expanded(
                  child: OutlinedButton(
                    onPressed: onSnooze,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(l10n.getString('maintenanceActionSnooze')),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  String _statusLabel(BuildContext context) {
    switch (task.status) {
      case MaintenanceStatus.overdue:
        return l10n.getString('maintenanceStatusOverdue');
      case MaintenanceStatus.dueSoon:
        return l10n.getString('maintenanceStatusDueSoon');
      case MaintenanceStatus.upcoming:
        return l10n.getString('maintenanceStatusUpcoming');
    }
  }

  Color _statusColor(BuildContext context) {
    final theme = Theme.of(context);
    switch (task.status) {
      case MaintenanceStatus.overdue:
        return theme.colorScheme.error;
      case MaintenanceStatus.dueSoon:
        return theme.colorScheme.primary;
      case MaintenanceStatus.upcoming:
        return theme.colorScheme.secondary;
    }
  }

  String _dueDescription(BuildContext context) {
    final now = DateTime.now();
    final difference = task.dueDate.difference(now).inDays;
    if (difference < 0) {
      final overdueDays = difference.abs();
      return l10n
          .getString('maintenanceOverdueBy')
          .replaceFirst('{days}', overdueDays.toString());
    }
    if (difference == 0) {
      return l10n.getString('maintenanceDueToday');
    }
    final displayDays = difference;
    return l10n
        .getString('maintenanceDueIn')
        .replaceFirst('{days}', displayDays.toString());
  }

  String _formatDate(BuildContext context, DateTime date) {
    return MaterialLocalizations.of(context).formatMediumDate(date.toLocal());
  }
}
