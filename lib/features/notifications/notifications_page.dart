import 'package:flutter/material.dart';

import '../../core/utils/context_extensions.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final List<_NotificationItem> _items = [
    _NotificationItem(
      title: 'Flash sale on Nimbus Flow Pro',
      time: '09:10',
      category: 'offers',
      marketing: true,
    ),
    _NotificationItem(
      title: 'Filter replacement reminder',
      time: '07:45',
      category: 'maintenance',
      marketing: false,
    ),
    _NotificationItem(
      title: 'New heater collection dropping soon',
      time: 'Yesterday',
      category: 'news',
      marketing: true,
    ),
  ];
  final Map<String, bool> _enabled = {
    'Flash sale on Nimbus Flow Pro': true,
    'Filter replacement reminder': true,
    'New heater collection dropping soon': false,
  };
  String _category = 'all';
  bool _muteMarketing = false;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final filtered = _items.where((item) {
      final matchesCategory =
          _category == 'all' || item.category == _category;
      final marketingAllowed = !_muteMarketing || !item.marketing;
      return matchesCategory && marketingAllowed;
    }).toList();
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
        child: Column(
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
            SwitchListTile(
              value: _muteMarketing,
              onChanged: (value) => setState(() => _muteMarketing = value),
              title: Text(l10n.getString('muteMarketing')),
              subtitle: Text(l10n.getString('muteMarketingHint')),
            ),
            const SizedBox(height: 12),
            if (filtered.isEmpty)
              Expanded(
                child: Center(
                  child: Text(l10n.getString('notificationsEmpty')),
                ),
              )
            else
              Expanded(
                child: ListView.separated(
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final item = filtered[index];
                    final enabled = _enabled[item.title] ?? true;
                    return ListTile(
                      tileColor: Theme.of(context).cardColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      title: Text(item.title),
                      subtitle: Text(
                        '${l10n.getString(item.category)} · ${item.time}',
                      ),
                      trailing: Switch(
                        value: enabled,
                        onChanged: (value) {
                          setState(() {
                            _enabled[item.title] = value;
                          });
                        },
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _NotificationItem {
  const _NotificationItem({
    required this.title,
    required this.time,
    required this.category,
    required this.marketing,
  });

  final String title;
  final String time;
  final String category;
  final bool marketing;
}
