import 'package:flutter/material.dart';

import '../../app_scope.dart';
import '../../core/utils/context_extensions.dart';
import '../../shared/controllers/environment_controller.dart';
import '../../shared/controllers/environment_schedule_controller.dart';
import '../../shared/models/environment_schedule.dart';
import '../../shared/utils/schedule_formatter.dart';
import '../../shared/widgets/primary_button.dart';

String _sceneNameFor(
  BuildContext context,
  EnvironmentController environment,
  String id,
) {
  final l10n = context.l10n;
  final scenes = environment.scenes;
  final match = scenes.where((scene) => scene.id == id);
  if (match.isNotEmpty) {
    return l10n.getString(match.first.titleKey);
  }
  if (scenes.isNotEmpty) {
    return l10n.getString(scenes.first.titleKey);
  }
  return id;
}

class EnvironmentSchedulePage extends StatefulWidget {
  const EnvironmentSchedulePage({super.key});

  @override
  State<EnvironmentSchedulePage> createState() => _EnvironmentSchedulePageState();
}

class _EnvironmentSchedulePageState extends State<EnvironmentSchedulePage> {
  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    final scheduleController = scope.environmentScheduleController;
    final environmentController = scope.environmentController;
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.getString('schedulePageTitle')),
        actions: [
          IconButton(
            onPressed: () =>
                _showScheduleSheet(context, environmentController, scheduleController),
            icon: const Icon(Icons.add),
            tooltip: l10n.getString('scheduleAdd'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.getString('schedulePageSubtitle'),
              style: context.textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ValueListenableBuilder<bool>(
              valueListenable: scheduleController.pausedNotifier,
              builder: (context, paused, _) {
                return _GlobalAutomationCard(
                  paused: paused,
                  controller: scheduleController,
                );
              },
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ValueListenableBuilder<List<EnvironmentSchedule>>(
                valueListenable: scheduleController.schedulesNotifier,
                builder: (context, schedules, _) {
                  return ValueListenableBuilder<bool>(
                    valueListenable: scheduleController.pausedNotifier,
                    builder: (context, paused, __) {
                      if (schedules.isEmpty) {
                        return _EmptyScheduleState(
                          onAdd: () => _showScheduleSheet(
                            context,
                            environmentController,
                            scheduleController,
                          ),
                        );
                      }
                      final timeline = paused
                          ? const <EnvironmentScheduleOccurrence>[]
                          : scheduleController.forecast(
                              schedules: schedules,
                            );
                      final children = <Widget>[];
                      if (timeline.isNotEmpty) {
                        children
                          ..add(
                            _UpcomingTimeline(
                              environment: environmentController,
                              occurrences: timeline,
                            ),
                          )
                          ..add(const SizedBox(height: 16));
                      }
                      for (final schedule in schedules) {
                        children
                          ..add(
                            _ScheduleCard(
                              schedule: schedule,
                              environment: environmentController,
                              scheduleController: scheduleController,
                              masterPaused: paused,
                              onEdit: () => _showScheduleSheet(
                                context,
                                environmentController,
                                scheduleController,
                                existing: schedule,
                              ),
                              onDelete: () => _confirmDelete(
                                context,
                                scheduleController,
                                schedule.id,
                              ),
                              onApply: () {
                                environmentController.applyScene(schedule.sceneId);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      l10n.getString('scheduleApplyNow'),
                                    ),
                                  ),
                                );
                              },
                            ),
                          )
                          ..add(const SizedBox(height: 16));
                      }
                      if (children.isNotEmpty) {
                        children.removeLast();
                      }
                      return ListView(
                        children: children,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () =>
            _showScheduleSheet(context, environmentController, scheduleController),
        icon: const Icon(Icons.add),
        label: Text(l10n.getString('scheduleAdd')),
      ),
    );
  }

  Future<void> _showScheduleSheet(
    BuildContext pageContext,
    EnvironmentController environment,
    EnvironmentScheduleController controller, {
    EnvironmentSchedule? existing,
  }) async {
    final l10n = pageContext.l10n;
    final scenes = environment.scenes;
    if (scenes.isEmpty) {
      return;
    }
    String selectedSceneId = existing?.sceneId ?? scenes.first.id;
    TimeOfDay selectedTime = existing?.timeOfDay ?? const TimeOfDay(hour: 7, minute: 30);
    final Set<int> selectedDays = existing != null
        ? existing.days.toSet()
        : <int>{
            DateTime.monday,
            DateTime.tuesday,
            DateTime.wednesday,
            DateTime.thursday,
            DateTime.friday,
          };
    var showValidationError = false;

    await showModalBottomSheet<void>(
      context: pageContext,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      l10n.getString(existing == null
                          ? 'scheduleSheetTitleNew'
                          : 'scheduleSheetTitleEdit'),
                      style: context.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.getString('scheduleSceneLabel'),
                      style: context.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: selectedSceneId,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      items: [
                        for (final scene in scenes)
                          DropdownMenuItem<String>(
                            value: scene.id,
                            child: Text(pageContext.l10n.getString(scene.titleKey)),
                          ),
                      ],
                      onChanged: (value) {
                        if (value == null) {
                          return;
                        }
                        setModalState(() {
                          selectedSceneId = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.getString('scheduleTimeLabel'),
                      style: context.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: selectedTime,
                          helpText: l10n.getString('scheduleTimeLabel'),
                        );
                        if (picked != null) {
                          setModalState(() {
                            selectedTime = picked;
                          });
                        }
                      },
                      icon: const Icon(Icons.schedule),
                      label: Text(
                        MaterialLocalizations.of(context)
                            .formatTimeOfDay(selectedTime),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.getString('scheduleDaysLabel'),
                      style: context.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final day in _dayOrder)
                          FilterChip(
                            label: Text(l10n.getString(_dayKey(day))),
                            selected: selectedDays.contains(day),
                            onSelected: (_) {
                              setModalState(() {
                                if (selectedDays.contains(day)) {
                                  selectedDays.remove(day);
                                } else {
                                  selectedDays.add(day);
                                }
                                showValidationError = false;
                              });
                            },
                          ),
                      ],
                    ),
                    if (showValidationError)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          l10n.getString('scheduleDaysError'),
                          style: context.textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ),
                    const SizedBox(height: 24),
                    PrimaryButton(
                      label: l10n.getString('scheduleSave'),
                      icon: Icons.check,
                      onPressed: () async {
                        if (selectedDays.isEmpty) {
                          setModalState(() {
                            showValidationError = true;
                          });
                          return;
                        }
                        final id = existing?.id ??
                            DateTime.now().microsecondsSinceEpoch.toString();
                        final schedule = EnvironmentSchedule(
                          id: id,
                          sceneId: selectedSceneId,
                          hour: selectedTime.hour,
                          minute: selectedTime.minute,
                          days: selectedDays.toList(),
                          enabled: existing?.enabled ?? true,
                        );
                        await controller.upsert(schedule);
                        if (!context.mounted) {
                          return;
                        }
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(pageContext).showSnackBar(
                          SnackBar(
                            content: Text(l10n.getString('scheduleSaved')),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(l10n.getString('cancel')),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    EnvironmentScheduleController controller,
    String id,
  ) async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.getString('scheduleDeleteConfirmTitle')),
          content: Text(l10n.getString('scheduleDeleteConfirmBody')),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.getString('cancel')),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(l10n.getString('scheduleDelete')),
            ),
          ],
        );
      },
    );
    if (confirmed != true) {
      return;
    }
    await controller.remove(id);
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.getString('scheduleDeleted'))),
    );
  }

  static const List<int> _dayOrder = <int>[
    DateTime.monday,
    DateTime.tuesday,
    DateTime.wednesday,
    DateTime.thursday,
    DateTime.friday,
    DateTime.saturday,
    DateTime.sunday,
  ];

  String _dayKey(int day) {
    switch (day) {
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
        return 'scheduleDaySun';
    }
    return 'scheduleDayMon';
  }
}

class _GlobalAutomationCard extends StatelessWidget {
  const _GlobalAutomationCard({
    required this.paused,
    required this.controller,
  });

  final bool paused;
  final EnvironmentScheduleController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final subtle = context.textTheme.bodySmall?.color?.withOpacity(0.6);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color:
              theme.colorScheme.primary.withOpacity(context.isDarkMode ? 0.25 : 0.12),
        ),
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
                      l10n.getString(paused
                          ? 'scheduleGlobalTitlePaused'
                          : 'scheduleGlobalTitleActive'),
                      style: context.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.getString(paused
                          ? 'scheduleGlobalSubtitlePaused'
                          : 'scheduleGlobalSubtitleActive'),
                      style: context.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              Switch.adaptive(
                value: !paused,
                onChanged: (value) => controller.setPaused(!value),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            l10n.getString('scheduleGlobalToggleLabel'),
            style: context.textTheme.bodySmall?.copyWith(color: subtle),
          ),
        ],
      ),
    );
  }
}

class _UpcomingTimeline extends StatelessWidget {
  const _UpcomingTimeline({
    required this.environment,
    required this.occurrences,
  });

  final EnvironmentController environment;
  final List<EnvironmentScheduleOccurrence> occurrences;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final subtle = context.textTheme.bodySmall?.color?.withOpacity(0.6);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.getString('scheduleTimelineTitle'),
          style: context.textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 170,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: occurrences.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final occurrence = occurrences[index];
              final timeLabel = MaterialLocalizations.of(context)
                  .formatTimeOfDay(TimeOfDay.fromDateTime(occurrence.occursAt));
              final dateLabel = MaterialLocalizations.of(context)
                  .formatMediumDate(occurrence.occursAt);
              final dayLabel = ScheduleFormatter.labelForWeekday(
                l10n,
                occurrence.occursAt.weekday,
              );
              final sceneName = _sceneNameFor(
                context,
                environment,
                occurrence.schedule.sceneId,
              );
              return Container(
                width: 220,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: theme.colorScheme.primary
                        .withOpacity(context.isDarkMode ? 0.2 : 0.1),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dayLabel,
                      style: context.textTheme.titleSmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dateLabel,
                      style: context.textTheme.bodySmall?.copyWith(color: subtle),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      sceneName,
                      style: context.textTheme.titleMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 18,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          timeLabel,
                          style: context.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.getString('scheduleUpcomingSwitch')
                          .replaceFirst('{scene}', sceneName)
                          .replaceFirst('{time}', timeLabel),
                      style: context.textTheme.bodyMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ScheduleCard extends StatelessWidget {
  const _ScheduleCard({
    required this.schedule,
    required this.environment,
    required this.scheduleController,
    required this.onEdit,
    required this.onDelete,
    required this.onApply,
    this.masterPaused = false,
  });

  final EnvironmentSchedule schedule;
  final EnvironmentController environment;
  final EnvironmentScheduleController scheduleController;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onApply;
  final bool masterPaused;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final sceneName = _sceneNameFor(context, environment, schedule.sceneId);
    final timeLabel = MaterialLocalizations.of(context)
        .formatTimeOfDay(schedule.timeOfDay);
    final daysLabel = ScheduleFormatter.describeDays(l10n, schedule);
    final statusLabel = schedule.enabled
        ? l10n.getString('scheduleStatusActive')
        : l10n.getString('scheduleStatusPaused');

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: InkWell(
        onTap: onEdit,
        borderRadius: BorderRadius.circular(28),
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
                          timeLabel,
                          style: context.textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l10n
                              .getString('scheduleUpcomingSwitch')
                              .replaceFirst('{scene}', sceneName)
                              .replaceFirst('{time}', timeLabel),
                          style: context.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: schedule.enabled,
                    onChanged: (value) =>
                        scheduleController.toggle(schedule.id, value),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  Chip(
                    label: Text(daysLabel),
                    avatar: const Icon(Icons.calendar_today, size: 16),
                  ),
                  Chip(
                    label: Text(statusLabel),
                    backgroundColor: schedule.enabled
                        ? theme.colorScheme.primary.withOpacity(0.15)
                        : theme.colorScheme.surfaceVariant,
                  ),
                  if (masterPaused && schedule.enabled)
                    Chip(
                      label: Text(l10n.getString('scheduleStatusMasterPaused')),
                      backgroundColor: theme.colorScheme.surfaceVariant,
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  TextButton.icon(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit),
                    label: Text(l10n.getString('scheduleEdit')),
                  ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: onApply,
                    icon: const Icon(Icons.play_arrow),
                    label: Text(l10n.getString('scheduleApplyNow')),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete_outline),
                    tooltip: l10n.getString('scheduleDelete'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyScheduleState extends StatelessWidget {
  const _EmptyScheduleState({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.edit_calendar,
              size: 64, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 16),
          Text(
            l10n.getString('scheduleNoItems'),
            style: context.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            l10n.getString('scheduleNoItemsSubtitle'),
            textAlign: TextAlign.center,
            style: context.textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          PrimaryButton(
            label: l10n.getString('scheduleAdd'),
            icon: Icons.add,
            onPressed: onAdd,
          ),
        ],
      ),
    );
  }
}
