import 'package:flutter/material.dart';

import '../../app_scope.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/utils/context_extensions.dart';
import '../../shared/controllers/maintenance_controller.dart';
import '../../shared/models/maintenance_task.dart';
import '../../shared/widgets/maintenance_task_card.dart';

class MaintenancePage extends StatelessWidget {
  const MaintenancePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final controller = AppScope.of(context).maintenanceController;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.getString('maintenanceCenterTitle')),
      ),
      body: RefreshIndicator(
        onRefresh: controller.resetTasks,
        child: ValueListenableBuilder<List<MaintenanceTask>>(
          valueListenable: controller.tasksNotifier,
          builder: (context, tasks, _) {
            final nextTask = tasks.isNotEmpty
                ? tasks.reduce((a, b) =>
                    a.dueDate.isBefore(b.dueDate) ? a : b)
                : null;

            return ListView(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                if (nextTask != null)
                  _MaintenanceHero(
                    task: nextTask,
                    l10n: l10n,
                  ),
                const SizedBox(height: 24),
                ValueListenableBuilder<bool>(
                  valueListenable: controller.remindersEnabledNotifier,
                  builder: (context, enabled, __) {
                    return _ReminderToggle(
                      enabled: enabled,
                      l10n: l10n,
                      onChanged: controller.toggleReminders,
                    );
                  },
                ),
                const SizedBox(height: 24),
                Text(
                  l10n.getString('maintenanceTasksHeader'),
                  style: context.textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                if (tasks.isEmpty)
                  _EmptyMaintenanceState(l10n: l10n)
                else
                  ...List.generate(tasks.length, (index) {
                    final task = tasks[index];
                    return Padding(
                      padding: EdgeInsets.only(bottom: index == tasks.length - 1 ? 0 : 20),
                      child: MaintenanceTaskCard(
                        task: task,
                        l10n: l10n,
                        onComplete: () => controller.completeTask(task.id),
                        onSnooze: () => controller
                            .snoozeTask(task.id, const Duration(days: 3)),
                      ),
                    );
                  }),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _MaintenanceHero extends StatelessWidget {
  const _MaintenanceHero({
    required this.task,
    required this.l10n,
  });

  final MaintenanceTask task;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final days = task.dueDate.difference(DateTime.now()).inDays;
    final isOverdue = days < 0;
    final highlightColor = _heroColor(theme, task.status);
    final label = isOverdue
        ? l10n
            .getString('maintenanceHeroOverdue')
            .replaceFirst('{days}', days.abs().toString())
        : l10n
            .getString('maintenanceHeroUpcoming')
            .replaceFirst('{days}', days.toString());

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            highlightColor.withOpacity(0.18),
            highlightColor.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: highlightColor.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.getString('maintenanceCenterHeadline'),
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          Text(
            l10n.getString(task.titleKey),
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            l10n.getString(task.descriptionKey),
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Color _heroColor(ThemeData theme, MaintenanceStatus status) {
    switch (status) {
      case MaintenanceStatus.overdue:
        return theme.colorScheme.error;
      case MaintenanceStatus.dueSoon:
        return theme.colorScheme.primary;
      case MaintenanceStatus.upcoming:
        return theme.colorScheme.secondary;
    }
  }
}

class _ReminderToggle extends StatelessWidget {
  const _ReminderToggle({
    required this.enabled,
    required this.l10n,
    required this.onChanged,
  });

  final bool enabled;
  final AppLocalizations l10n;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.05),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.getString('maintenanceRemindersTitle'),
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 6),
                Text(
                  l10n.getString('maintenanceRemindersSubtitle'),
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Switch.adaptive(
            value: enabled,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _EmptyMaintenanceState extends StatelessWidget {
  const _EmptyMaintenanceState({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.getString('maintenanceEmptyTitle'),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            l10n.getString('maintenanceEmptySubtitle'),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
