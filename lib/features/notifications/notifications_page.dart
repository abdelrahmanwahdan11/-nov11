import 'package:flutter/material.dart';

import '../../app_scope.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/utils/context_extensions.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final List<_NotificationItem> _items = const [
    _NotificationItem(
      id: 'flash-sale',
      titleKey: 'notificationTitleFlash',
      timeLabel: '09:10',
      category: 'offers',
      marketing: true,
    ),
    _NotificationItem(
      id: 'filter-reminder',
      titleKey: 'notificationTitleFilter',
      timeLabel: '07:45',
      category: 'maintenance',
    ),
    _NotificationItem(
      id: 'new-collection',
      titleKey: 'notificationTitleCollection',
      timeLabel: 'timeYesterday',
      category: 'news',
      marketing: true,
      timeIsKey: true,
    ),
  ];
  String _category = 'all';

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final notifications = AppScope.of(context).notificationsController;
    final categories = {
      'all': l10n.getString('all'),
      'offers': l10n.getString('offers'),
      'maintenance': l10n.getString('maintenance'),
      'news': l10n.getString('news'),
    };
    return Scaffold(
      appBar: AppBar(title: Text(l10n.getString('notifications'))),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: ValueListenableBuilder<bool>(
          valueListenable: notifications.muteMarketingNotifier,
          builder: (context, muteMarketing, _) {
            final filtered = _items.where((item) {
              final matchesCategory =
                  _category == 'all' || item.category == _category;
              final marketingAllowed = !muteMarketing || !item.marketing;
              return matchesCategory && marketingAllowed;
            }).toList();

            Widget buildList() {
              if (filtered.isEmpty) {
                return Center(child: Text(l10n.getString('notificationsEmpty')));
              }
              return ValueListenableBuilder<Set<String>>(
                valueListenable: notifications.disabledNotifier,
                builder: (context, disabled, __) {
                  return ListView.separated(
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final item = filtered[index];
                      final enabled = notifications.isNotificationEnabled(item.id);
                      return ListTile(
                        tileColor: Theme.of(context).cardColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        title: Text(l10n.getString(item.titleKey)),
                        subtitle: Text(
                          '${l10n.getString(item.category)} · ${item.timeLabelFor(l10n)}',
                        ),
                        trailing: Switch(
                          value: enabled,
                          onChanged: (value) {
                            notifications.setNotificationEnabled(
                              item.id,
                              value,
                            );
                          },
                        ),
                      );
                    },
                  );
                },
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  children: categories.entries.map((entry) {
                    return ChoiceChip(
                      label: Text(entry.value),
                      selected: _category == entry.key,
                      onSelected: (_) => setState(() => _category = entry.key),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
                SwitchListTile.adaptive(
                  value: muteMarketing,
                  onChanged: (value) {
                    notifications.setMuteMarketing(value);
                  },
                  title: Text(l10n.getString('muteMarketing')),
                  subtitle: Text(l10n.getString('muteMarketingHint')),
                ),
                const SizedBox(height: 12),
                Expanded(child: buildList()),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _NotificationItem {
  const _NotificationItem({
    required this.id,
    required this.titleKey,
    required this.timeLabel,
    required this.category,
    this.marketing = false,
    this.timeIsKey = false,
  });

  final String id;
  final String titleKey;
  final String timeLabel;
  final String category;
  final bool marketing;
  final bool timeIsKey;

  String timeLabelFor(AppLocalizations l10n) {
    return timeIsKey ? l10n.getString(timeLabel) : timeLabel;
  }
}
