import 'package:flutter/material.dart';

import '../../core/utils/context_extensions.dart';

class SupportPage extends StatelessWidget {
  const SupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final faqs = [
      ('Filter maintenance', 'Clean filters every 3 months and replace yearly.'),
      ('Warranty coverage', 'All devices include a 2-year limited warranty.'),
      ('Contact support', 'Reach us via hello@smartair.app'),
    ];
    return Scaffold(
      appBar: AppBar(title: Text(l10n.getString('support'))),
      body: ListView.separated(
        padding: const EdgeInsets.all(24),
        itemBuilder: (context, index) {
          final faq = faqs[index];
          return ExpansionTile(
            title: Text(faq.$1),
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(faq.$2),
              ),
            ],
          );
        },
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemCount: faqs.length,
      ),
    );
  }
}
