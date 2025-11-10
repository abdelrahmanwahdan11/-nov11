import 'package:flutter/material.dart';

import '../../core/utils/context_extensions.dart';
import '../models/product.dart';
import '../controllers/compare_controller.dart';

class CompareTable extends StatelessWidget {
  const CompareTable({
    super.key,
    required this.controller,
    required this.differencesOnly,
    required this.highlightDifferences,
  });

  final CompareController controller;
  final bool differencesOnly;
  final bool highlightDifferences;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<Product>>(
      valueListenable: controller.compareNotifier,
      builder: (context, items, _) {
        if (items.isEmpty) {
          return Center(
            child: Text(
              context.l10n.getString('emptyCompare'),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          );
        }
        final matrix = controller.comparisonMatrix;
        final rows = <DataRow>[];
        matrix.forEach((key, value) {
          final hasDifference = _hasDifference(value);
          if (differencesOnly && !hasDifference) {
            return;
          }
          final title = _localizeKey(context, key);
          final rowColor = highlightDifferences && hasDifference
              ? MaterialStateProperty.all(
                  Theme.of(context)
                      .colorScheme
                      .secondaryContainer
                      .withOpacity(0.45),
                )
              : null;
          final cells = <DataCell>[
            DataCell(Text(title, style: Theme.of(context).textTheme.bodyMedium)),
          ];
          for (final cell in value) {
            cells.add(
              DataCell(
                Text(
                  cell ?? '-',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          rows.add(DataRow(color: rowColor, cells: cells));
        });
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingRowColor: MaterialStateProperty.all(
              Theme.of(context).colorScheme.surface.withOpacity(0.4),
            ),
            columns: [
              DataColumn(label: Text(context.l10n.getString('specifications'))),
              ...List.generate(items.length, (index) {
                final product = items[index];
                return DataColumn(
                  label: SizedBox(
                    width: 140,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          product.name,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        IconButton(
                          iconSize: 18,
                          padding: EdgeInsets.zero,
                          visualDensity: VisualDensity.compact,
                          tooltip: context.l10n.getString('remove'),
                          onPressed: () => controller.removeProduct(product.id),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
            rows: rows,
          ),
        );
      },
    );
  }
}

String _localizeKey(BuildContext context, String key) {
  final l10n = context.l10n;
  switch (key) {
    case 'Price':
      return l10n.getString('price');
    case 'Rating':
      return l10n.getString('rating');
    case 'Noise (dB)':
      return l10n.getString('noise');
    case 'Power (W)':
      return l10n.getString('power');
    default:
      return key;
  }
}

bool _hasDifference(List<String?> values) {
  final normalized = values.map((value) => value ?? '').toSet();
  return normalized.length > 1;
}
