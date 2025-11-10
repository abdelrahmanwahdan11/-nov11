import 'package:flutter/material.dart';

import '../../app_scope.dart';
import '../../core/utils/context_extensions.dart';
import '../../shared/controllers/compare_controller.dart';
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
        child: CompareTable(controller: controller),
      ),
    );
  }
}
