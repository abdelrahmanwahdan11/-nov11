import 'package:flutter/material.dart';

import '../../app_scope.dart';
import '../../core/utils/context_extensions.dart';
import '../../shared/controllers/compare_controller.dart';
import '../../shared/models/product.dart';
import '../../shared/widgets/compare_table.dart';

class ComparePage extends StatelessWidget {
  const ComparePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context).compareController;
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.getString('compare')),
        actions: [
          TextButton(
            onPressed: controller.clear,
            child: Text(l10n.getString('clear')),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ValueListenableBuilder<List<Product>>(
              valueListenable: controller.compareNotifier,
              builder: (context, items, _) {
                if (items.isEmpty) {
                  return Text(
                    l10n.getString('compareHint'),
                    style: Theme.of(context).textTheme.bodyMedium,
                  );
                }
                return Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: items
                      .map(
                        (item) => Chip(
                          label: Text(item.name),
                          deleteIcon: const Icon(Icons.close, size: 18),
                          onDeleted: () => controller.removeProduct(item.id),
                        ),
                      )
                      .toList(),
                );
              },
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                ValueListenableBuilder<bool>(
                  valueListenable: controller.differencesOnly,
                  builder: (context, selected, _) {
                    return FilterChip(
                      label: Text(l10n.getString('differencesOnly')),
                      selected: selected,
                      onSelected: controller.setDifferencesOnly,
                    );
                  },
                ),
                ValueListenableBuilder<bool>(
                  valueListenable: controller.highlightDifferences,
                  builder: (context, selected, _) {
                    return FilterChip(
                      label: Text(l10n.getString('highlightDifferences')),
                      selected: selected,
                      onSelected: controller.setHighlightDifferences,
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ValueListenableBuilder<bool>(
                valueListenable: controller.differencesOnly,
                builder: (context, differencesOnly, _) {
                  return ValueListenableBuilder<bool>(
                    valueListenable: controller.highlightDifferences,
                    builder: (context, highlight, __) {
                      return CompareTable(
                        controller: controller,
                        differencesOnly: differencesOnly,
                        highlightDifferences: highlight,
                      );
                    },
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
