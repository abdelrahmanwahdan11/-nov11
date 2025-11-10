import 'package:flutter/material.dart';

import '../../core/utils/context_extensions.dart';
import '../models/product.dart';
import '../controllers/compare_controller.dart';

class CompareTable extends StatelessWidget {
  const CompareTable({super.key, required this.controller});

  final CompareController controller;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<Product>>(
      valueListenable: controller.compareNotifier,
      builder: (context, items, _) {
        if (items.isEmpty) {
          return Center(
            child: Text(
              'No items yet',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          );
        }
        final matrix = controller.comparisonMatrix;
        final rows = matrix.entries.map((entry) {
          final title = _localizeKey(context, entry.key);
          final cells = <DataCell>[
            DataCell(Text(title, style: Theme.of(context).textTheme.bodyMedium)),
          ];
          cells.addAll(entry.value.map(
            (value) => DataCell(Text(value ?? '-', textAlign: TextAlign.center)),
          ));
          return DataRow(cells: cells);
        }).toList();
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingRowColor: MaterialStateProperty.all(
              Theme.of(context).colorScheme.surface.withOpacity(0.4),
            ),
            columns: [
              DataColumn(label: Text(context.l10n.getString('specifications'))),
              ...items.map((product) => DataColumn(
                    label: SizedBox(
                      width: 120,
                      child: Text(product.name, textAlign: TextAlign.center),
                    ),
                  )),
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
