import 'package:flutter/material.dart';

import '../../core/utils/context_extensions.dart';

class SupportPage extends StatelessWidget {
  const SupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.getString('support'))),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            child: ListTile(
              leading: const Icon(Icons.support_agent),
              title: Text(l10n.getString('supportContactTitle')),
              subtitle: Text(l10n.getString('supportContactSubtitle')),
              trailing: TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l10n.getString('supportContactEmail')),
                    ),
                  );
                },
                child: Text(l10n.getString('supportContactAction')),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(l10n.getString('faqTitle'), style: context.textTheme.headlineMedium),
          const SizedBox(height: 16),
          ...[
            ('supportFaqFilterTitle', 'supportFaqFilterBody'),
            ('supportFaqWarrantyTitle', 'supportFaqWarrantyBody'),
            ('supportFaqContactTitle', 'supportFaqContactBody'),
          ].map(
            (entry) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ExpansionTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                collapsedShape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                title: Text(l10n.getString(entry.$1)),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(l10n.getString(entry.$2)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
