import 'package:flutter/material.dart';

import '../../app_scope.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/utils/context_extensions.dart';
import '../../shared/controllers/diagnostics_controller.dart';
import '../../shared/models/device_diagnostic.dart';
import '../../shared/widgets/diagnostic_status_card.dart';
import '../../shared/widgets/primary_button.dart';

class DiagnosticsPage extends StatelessWidget {
  const DiagnosticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final DiagnosticsController controller =
        AppScope.of(context).diagnosticsController;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.getString('diagnosticsTitle')),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.getString('diagnosticsDescription'),
              style: context.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            PrimaryButton(
              label: l10n.getString('diagnosticsRunAll'),
              icon: Icons.bolt,
              onPressed: controller.runQuickCheckAll,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            ),
            const SizedBox(height: 20),
            ValueListenableBuilder<bool>(
              valueListenable: controller.flaggedOnlyNotifier,
              builder: (context, flaggedOnly, _) {
                return _FlaggedToggleCard(
                  flaggedOnly: flaggedOnly,
                  l10n: l10n,
                  onChanged: controller.toggleFlaggedOnly,
                );
              },
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ValueListenableBuilder<List<DeviceDiagnostic>>(
                valueListenable: controller.diagnosticsNotifier,
                builder: (context, diagnostics, _) {
                  return ValueListenableBuilder<bool>(
                    valueListenable: controller.flaggedOnlyNotifier,
                    builder: (context, flaggedOnly, __) {
                      final visibleDiagnostics = flaggedOnly
                          ? diagnostics.where((d) => d.isFlagged).toList()
                          : diagnostics;
                      if (visibleDiagnostics.isEmpty) {
                        return Center(
                          child: Text(
                            l10n.getString('diagnosticsEmptyState'),
                            style: context.textTheme.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                        );
                      }
                      return ListView.separated(
                        itemCount: visibleDiagnostics.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 20),
                        itemBuilder: (context, index) {
                          final diagnostic = visibleDiagnostics[index];
                          return DiagnosticStatusCard(
                            diagnostic: diagnostic,
                            l10n: l10n,
                            onRunCheck: () => controller.runQuickCheck(diagnostic.id),
                            onResolve: () => controller.markResolved(diagnostic.id),
                            onAutoTuneChanged: (value) =>
                                controller.toggleAutoTune(diagnostic.id, value),
                          );
                        },
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

class _FlaggedToggleCard extends StatelessWidget {
  const _FlaggedToggleCard({
    required this.flaggedOnly,
    required this.l10n,
    required this.onChanged,
  });

  final bool flaggedOnly;
  final AppLocalizations l10n;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.05),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.08),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.getString('diagnosticsShowFlaggedOnly'),
                  style: theme.textTheme.titleSmall,
                ),
                const SizedBox(height: 6),
                Text(
                  l10n.getString('diagnosticsShowFlaggedOnlyHint'),
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: flaggedOnly,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
