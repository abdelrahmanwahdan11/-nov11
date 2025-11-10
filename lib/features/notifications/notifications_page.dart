import 'package:flutter/material.dart';

import '../../core/utils/context_extensions.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final List<bool> _enabled = [true, true, false];

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final notifications = [
      'Flash sale on Nimbus Flow Pro',
      'Filter replacement reminder',
      'New heater collection dropping soon',
    ];
    return Scaffold(
      appBar: AppBar(title: Text(l10n.getString('notifications'))),
      body: ListView.separated(
        padding: const EdgeInsets.all(24),
        itemBuilder: (context, index) {
          final item = notifications[index];
          return ListTile(
            tileColor: Theme.of(context).cardColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Text(item),
            subtitle: Text('Today · 09:${index}0'),
            trailing: Switch(
              value: _enabled[index],
              onChanged: (value) {
                setState(() => _enabled[index] = value);
              },
            ),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemCount: notifications.length,
      ),
    );
  }
}
