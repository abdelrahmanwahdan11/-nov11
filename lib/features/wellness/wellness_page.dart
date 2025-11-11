import 'package:flutter/material.dart';

import '../../app_scope.dart';
import '../../core/utils/context_extensions.dart';
import '../../shared/models/wellness_metric.dart';
import '../../shared/models/wellness_recommendation.dart';
import '../../shared/widgets/comfort_score_ring.dart';
import '../../shared/widgets/wellness_metric_card.dart';
import '../../shared/widgets/wellness_recommendation_card.dart';
import '../../shared/widgets/wellness_trend_chart.dart';

class WellnessPage extends StatelessWidget {
  const WellnessPage({super.key});

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    final controller = scope.wellnessController;
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.getString('wellnessTitle')),
        actions: [
          IconButton(
            onPressed: controller.refresh,
            icon: const Icon(Icons.refresh_rounded),
            tooltip: l10n.getString('wellnessRefresh'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: controller.refresh,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            ValueListenableBuilder<double>(
              valueListenable: controller.compositeScoreNotifier,
              builder: (context, score, _) {
                return Row(
                  children: [
                    ComfortScoreRing(
                      score: score.round(),
                      color: Theme.of(context).colorScheme.primary,
                      size: 160,
                      subtitle: l10n.getString('wellnessScoreLabel'),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.getString('wellnessScoreTitle'),
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            l10n.getString('wellnessScoreDescription'),
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 32),
            ValueListenableBuilder<List<WellnessMetric>>(
              valueListenable: controller.metricsNotifier,
              builder: (context, metrics, _) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.getString('wellnessFocusTitle'),
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 16),
                    ValueListenableBuilder<String?>(
                      valueListenable: controller.focusMetricNotifier,
                      builder: (context, focus, __) {
                        return Column(
                          children: metrics
                              .map(
                                (metric) => Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: WellnessMetricCard(
                                    metric: metric,
                                    focused: focus == metric.id,
                                    onFocus: () =>
                                        controller.setFocusMetric(metric.id),
                                  ),
                                ),
                              )
                              .toList(),
                        );
                      },
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 32),
            ValueListenableBuilder<List<WellnessTrendPoint>>(
              valueListenable: controller.trendNotifier,
              builder: (context, points, _) {
                if (points.isEmpty) {
                  return const SizedBox.shrink();
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.getString('wellnessTrendTitle'),
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 16),
                    WellnessTrendChart(points: points),
                  ],
                );
              },
            ),
            const SizedBox(height: 32),
            ValueListenableBuilder<List<WellnessRecommendation>>(
              valueListenable: controller.recommendationsNotifier,
              builder: (context, recommendations, _) {
                if (recommendations.isEmpty) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.getString('wellnessTipsEmptyTitle'),
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.getString('wellnessTipsEmptyDescription'),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 12),
                      ValueListenableBuilder<int>(
                        valueListenable: controller.hiddenCountNotifier,
                        builder: (context, hiddenCount, __) {
                          if (hiddenCount == 0) {
                            return const SizedBox.shrink();
                          }
                          return OutlinedButton.icon(
                            onPressed: controller.restoreDismissed,
                            icon: const Icon(Icons.undo),
                            label: Text(
                              l10n
                                  .getString('wellnessTipsRestore')
                                  .replaceFirst('{count}', '$hiddenCount'),
                            ),
                          );
                        },
                      ),
                    ],
                  );
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.getString('wellnessTipsTitle'),
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 16),
                    ...recommendations.map(
                      (tip) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: WellnessRecommendationCard(
                          recommendation: tip,
                          onPinToggle: () => controller.togglePin(tip.id),
                          onDismiss: () =>
                              controller.dismissRecommendation(tip.id),
                        ),
                      ),
                    ),
                    ValueListenableBuilder<int>(
                      valueListenable: controller.hiddenCountNotifier,
                      builder: (context, hiddenCount, __) {
                        if (hiddenCount == 0) {
                          return const SizedBox.shrink();
                        }
                        return Align(
                          alignment: Alignment.centerLeft,
                          child: OutlinedButton.icon(
                            onPressed: controller.restoreDismissed,
                            icon: const Icon(Icons.undo),
                            label: Text(
                              l10n
                                  .getString('wellnessTipsRestore')
                                  .replaceFirst('{count}', '$hiddenCount'),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
