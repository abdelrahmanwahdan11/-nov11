import 'package:flutter/material.dart';

import '../../app_scope.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/utils/context_extensions.dart';
import '../../shared/controllers/catalog_controller.dart';
import '../../shared/controllers/environment_controller.dart';
import '../../shared/controllers/environment_schedule_controller.dart';
import '../../shared/controllers/favorites_controller.dart';
import '../../shared/data/mock_products.dart';
import '../../shared/models/app_prefs.dart';
import '../../shared/models/environment_scene.dart';
import '../../shared/models/environment_schedule.dart';
import '../../shared/models/product.dart';
import '../../shared/widgets/chip_filter.dart';
import '../../shared/widgets/environment_stat_card.dart';
import '../../shared/widgets/primary_button.dart';
import '../../shared/widgets/product_card.dart';
import '../../shared/widgets/skeleton_box.dart';
import '../../shared/widgets/smart_network_image.dart';
import '../../shared/widgets/scene_card.dart';
import '../../shared/widgets/routine_card.dart';
import '../../shared/utils/schedule_formatter.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final ScrollController _scrollController;
  String _selectedCategory = 'all';

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()
      ..addListener(() {
        if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200) {
          AppScope.of(context).catalogController.loadMore();
        }
      });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scope = AppScope.of(context);
    final catalog = scope.catalogController;
    final favorites = scope.favoritesController;
    final environment = scope.environmentController;
    final scheduleController = scope.environmentScheduleController;
    final routines = _RoutineBlueprint.samples(l10n);
    final categories = {
      'all': l10n.getString('catalog'),
      'fan': l10n.getString('fans'),
      'heater': l10n.getString('heaters'),
      'purifier': l10n.getString('purifiers'),
    };

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.getString('home')),
        actions: [
          IconButton(
            onPressed: () => Navigator.of(context).pushNamed('/search'),
            icon: const Icon(Icons.search),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pushNamed('/notifications'),
            icon: const Icon(Icons.notifications),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: catalog.refresh,
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ValueListenableBuilder<AppPrefs>(
                      valueListenable: scope.appController.prefsNotifier,
                      builder: (context, prefs, _) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _greetingFor(context, prefs),
                              style: context.textTheme.headlineLarge,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _messageFor(context, prefs),
                              style: context.textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 16),
                            PrimaryButton(
                              label: l10n.getString('homeExploreCta'),
                              icon: Icons.auto_awesome,
                              onPressed: () =>
                                  Navigator.of(context).pushNamed('/catalog'),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    Text(
                      l10n.getString('homeQuickActions'),
                      style: context.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        _quickAction(
                          context,
                          icon: Icons.favorite,
                          label: l10n.getString('quickActionFavorites'),
                          onTap: () =>
                              Navigator.of(context).pushNamed('/favorites'),
                        ),
                        _quickAction(
                          context,
                          icon: Icons.compare_arrows,
                          label: l10n.getString('quickActionCompare'),
                          onTap: () =>
                              Navigator.of(context).pushNamed('/compare'),
                        ),
                        _quickAction(
                          context,
                          icon: Icons.edit_calendar,
                          label: l10n.getString('quickActionSchedules'),
                          onTap: () => Navigator.of(context)
                              .pushNamed('/environment-schedules'),
                        ),
                        _quickAction(
                          context,
                          icon: Icons.headset_mic,
                          label: l10n.getString('quickActionSupport'),
                          onTap: () =>
                              Navigator.of(context).pushNamed('/support'),
                        ),
                        _quickAction(
                          context,
                          icon: Icons.shopping_cart,
                          label: l10n.getString('quickActionCart'),
                          onTap: () =>
                              Navigator.of(context).pushNamed('/cart'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    ValueListenableBuilder<EnvironmentScene>(
                      valueListenable: environment.currentSceneNotifier,
                      builder: (context, scene, _) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.getString('homeActiveScene'),
                              style: context.textTheme.titleLarge,
                            ),
                            const SizedBox(height: 12),
                            _buildActiveSceneBanner(
                              context,
                              scene,
                              () => _showSceneDetails(context, scene),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    ValueListenableBuilder<EnvironmentMetrics>(
                      valueListenable: environment.metricsNotifier,
                      builder: (context, metrics, _) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.getString('sceneMetricsTitle'),
                              style: context.textTheme.titleMedium,
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: EnvironmentStatCard(
                                    icon: Icons.air,
                                    label: l10n.getString('sceneAirQuality'),
                                    value: 'AQI ${metrics.airQuality}',
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: EnvironmentStatCard(
                                    icon: Icons.water_drop,
                                    label: l10n.getString('sceneHumidity'),
                                    value: '${metrics.humidity}%',
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: EnvironmentStatCard(
                                    icon: Icons.thermostat,
                                    label: l10n.getString('sceneTemperature'),
                                    value: '${metrics.temperatureC.toStringAsFixed(1)}°C',
                                  ),
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    Text(
                      l10n.getString('homeSchedulesTitle'),
                      style: context.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.getString('homeSchedulesSubtitle'),
                      style: context.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 12),
                    ValueListenableBuilder<List<EnvironmentSchedule>>(
                      valueListenable: scheduleController.schedulesNotifier,
                      builder: (context, schedules, _) {
                        return _buildScheduleOverview(
                          context,
                          environment,
                          scheduleController,
                          schedules,
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    ValueListenableBuilder<EnvironmentScene>(
                      valueListenable: environment.currentSceneNotifier,
                      builder: (context, activeScene, _) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.getString('homeScenesTitle'),
                              style: context.textTheme.titleLarge,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              l10n.getString('homeScenesSubtitle'),
                              style: context.textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              height: 260,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount: environment.scenes.length,
                                separatorBuilder: (_, __) => const SizedBox(width: 16),
                                itemBuilder: (context, index) {
                                  final scene = environment.scenes[index];
                                  return SceneCard(
                                    scene: scene,
                                    selected: scene.id == activeScene.id,
                                    onApply: () {
                                      environment.applyScene(scene.id);
                                      final messenger = ScaffoldMessenger.of(context);
                                      messenger.hideCurrentSnackBar();
                                      messenger.showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            l10n
                                                .getString('sceneAppliedMessage')
                                                .replaceFirst(
                                                  '{scene}',
                                                  l10n.getString(scene.titleKey),
                                                ),
                                          ),
                                        ),
                                      );
                                    },
                                    onInfo: () => _showSceneDetails(context, scene),
                                  );
                                },
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    Text(
                      l10n.getString('homeRoutinesTitle'),
                      style: context.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 250,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index) {
                          final routine = routines[index];
                          return RoutineCard(
                            title: routine.title,
                            description: routine.description,
                            imageSeed: routine.imageSeed,
                            onTap: () => _showRoutineSheet(context, routine),
                          );
                        },
                        separatorBuilder: (_, __) => const SizedBox(width: 16),
                        itemCount: routines.length,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      l10n.getString('discoverDevices'),
                      style: context.textTheme.headlineLarge,
                    ),
                    const SizedBox(height: 24),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: categories.entries.map((entry) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: ChipFilter(
                              label: entry.value,
                              selected: _selectedCategory == entry.key,
                              onSelected: (_) => setState(() {
                                _selectedCategory = entry.key;
                              }),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 260,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index) {
                          final product = mockProducts[index % mockProducts.length];
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: SizedBox(
                              width: 240,
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  SmartNetworkImage(
                                    imageUrl: product.images.first,
                                    fit: BoxFit.cover,
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.bottomLeft,
                                        end: Alignment.topRight,
                                        colors: [
                                          Colors.black.withOpacity(0.75),
                                          Colors.transparent,
                                        ],
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(20),
                                    child: Align(
                                      alignment: Alignment.bottomLeft,
                                      child: Text(
                                        product.name,
                                        style: context.textTheme.headlineMedium?.copyWith(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                        separatorBuilder: (_, __) => const SizedBox(width: 16),
                        itemCount: mockProducts.length,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          l10n.getString('recommended'),
                          style: context.textTheme.headlineMedium,
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pushNamed('/catalog'),
                          child: Text(l10n.getString('viewAll')),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ValueListenableBuilder<List<Product>>(
                      valueListenable: favorites.recentNotifier,
                      builder: (context, recents, _) {
                        if (recents.isEmpty) {
                          return const SizedBox.shrink();
                        }
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.getString('recentlyViewed'),
                              style: context.textTheme.bodyLarge,
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              height: 160,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemBuilder: (context, index) {
                                  final item = recents[index];
                                  return GestureDetector(
                                    onTap: () => Navigator.of(context)
                                        .pushNamed('/product', arguments: item.id),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(24),
                                      child: SizedBox(
                                        width: 140,
                                        child: SmartNetworkImage(
                                          imageUrl: item.images.first,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                                separatorBuilder: (_, __) => const SizedBox(width: 12),
                                itemCount: recents.length,
                              ),
                            ),
                            const SizedBox(height: 24),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            ValueListenableBuilder<List<Product>>(
              valueListenable: catalog.productsNotifier,
              builder: (context, products, _) {
                if (products.isEmpty) {
                  return SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    sliver: SliverGrid(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => const SkeletonBox(width: double.infinity, height: 220),
                        childCount: 4,
                      ),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 0.68,
                      ),
                    ),
                  );
                }
                final filtered = _selectedCategory == 'all'
                    ? products
                    : products.where((element) => element.tags.join(' ').toLowerCase().contains(_selectedCategory)).toList();
                return ValueListenableBuilder<List<Product>>(
                  valueListenable: favorites.favoritesNotifier,
                  builder: (context, favs, __) {
                    return SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      sliver: SliverGrid(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            if (index >= filtered.length) {
                              return const SkeletonBox(width: double.infinity, height: 220);
                            }
                            final product = filtered[index];
                            final isFav = favs.any((element) => element.id == product.id);
                            return ProductCard(
                              product: product,
                              isFavorite: isFav,
                              onTap: () {
                                favorites.addRecent(product.id);
                                Navigator.of(context).pushNamed('/product', arguments: product.id);
                              },
                              onCompare: () {
                                AppScope.of(context).compareController.addProduct(product);
                                Navigator.of(context).pushNamed('/compare');
                              },
                              onFavorite: () {
                                favorites.toggleFavorite(product);
                              },
                            );
                          },
                          childCount: filtered.length,
                        ),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          childAspectRatio: 0.68,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        onTap: (index) {
          switch (index) {
            case 1:
              Navigator.of(context).pushNamed('/catalog');
              break;
            case 2:
              Navigator.of(context).pushNamed('/compare');
              break;
            case 3:
              Navigator.of(context).pushNamed('/favorites');
              break;
            case 4:
              Navigator.of(context).pushNamed('/settings');
              break;
          }
        },
        items: [
          BottomNavigationBarItem(icon: const Icon(Icons.home), label: l10n.getString('home')),
          BottomNavigationBarItem(icon: const Icon(Icons.grid_view), label: l10n.getString('catalog')),
          BottomNavigationBarItem(icon: const Icon(Icons.compare_arrows), label: l10n.getString('compare')),
          BottomNavigationBarItem(icon: const Icon(Icons.favorite), label: l10n.getString('favorites')),
          BottomNavigationBarItem(icon: const Icon(Icons.settings), label: l10n.getString('settings')),
        ],
      ),
    );
  }

  String _greetingFor(BuildContext context, AppPrefs prefs) {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return context.l10n.getString('greetingMorning');
    }
    if (hour < 17) {
      return context.l10n.getString('greetingAfternoon');
    }
    return context.l10n.getString('greetingEvening');
  }

  String _messageFor(BuildContext context, AppPrefs prefs) {
    final name = prefs.userName;
    if (name != null && name.isNotEmpty && !prefs.isGuest) {
      return context.l10n
          .getString('greetingNamed')
          .replaceFirst('{name}', name);
    }
    return context.l10n.getString('greetingGuest');
  }

  Widget _quickAction(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return ActionChip(
      avatar: Icon(icon, color: theme.colorScheme.primary),
      backgroundColor: theme.cardColor,
      label: Text(label),
      onPressed: onTap,
    );
  }

  Widget _buildScheduleOverview(
    BuildContext context,
    EnvironmentController environment,
    EnvironmentScheduleController scheduleController,
    List<EnvironmentSchedule> schedules,
  ) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final occurrence = scheduleController.nextOccurrence(schedules: schedules);
    final hasSchedules = schedules.isNotEmpty;
    final background = theme.cardColor;
    final borderColor = theme.colorScheme.primary
        .withOpacity(context.isDarkMode ? 0.35 : 0.18);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.getString('scheduleUpcomingLabel'),
                  style: context.textTheme.titleMedium,
                ),
              ),
              Icon(Icons.edit_calendar, color: theme.colorScheme.primary),
            ],
          ),
          const SizedBox(height: 12),
          if (occurrence != null) ...[
            Text(
              l10n
                  .getString('scheduleUpcomingSwitch')
                  .replaceFirst(
                    '{scene}',
                    _resolveSceneTitle(
                      context,
                      environment,
                      occurrence.schedule.sceneId,
                    ),
                  )
                  .replaceFirst(
                    '{time}',
                    MaterialLocalizations.of(context).formatTimeOfDay(
                      TimeOfDay.fromDateTime(occurrence.occursAt),
                    ),
                  ),
              style: context.textTheme.bodyLarge,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Chip(
                  avatar: const Icon(Icons.calendar_today, size: 16),
                  label: Text(
                    MaterialLocalizations.of(context)
                        .formatMediumDate(occurrence.occursAt),
                  ),
                ),
                Chip(
                  label: Text(
                    l10n
                        .getString('scheduleUpcomingDays')
                        .replaceFirst(
                          '{days}',
                          ScheduleFormatter.describeDays(
                            l10n,
                            occurrence.schedule,
                          ),
                        ),
                  ),
                ),
              ],
            ),
          ] else if (hasSchedules) ...[
            Text(
              l10n.getString('scheduleUpcomingPaused'),
              style: context.textTheme.bodyLarge,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.getString('homeSchedulesSubtitle'),
              style: context.textTheme.bodyMedium,
            ),
          ] else ...[
            Text(
              l10n.getString('homeSchedulesEmpty'),
              style: context.textTheme.bodyLarge,
            ),
          ],
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: () =>
                Navigator.of(context).pushNamed('/environment-schedules'),
            icon: const Icon(Icons.tune),
            label: Text(l10n.getString('scheduleManageCta')),
          ),
        ],
      ),
    );
  }

  String _resolveSceneTitle(
    BuildContext context,
    EnvironmentController environment,
    String id,
  ) {
    final scenes = environment.scenes;
    final match = scenes.where((scene) => scene.id == id);
    if (match.isNotEmpty) {
      return context.l10n.getString(match.first.titleKey);
    }
    if (scenes.isNotEmpty) {
      return context.l10n.getString(scenes.first.titleKey);
    }
    return id;
  }

  Widget _buildActiveSceneBanner(
    BuildContext context,
    EnvironmentScene scene,
    VoidCallback onInfo,
  ) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [scene.gradientStart, scene.gradientEnd],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  l10n.getString(scene.titleKey),
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              IconButton(
                onPressed: onInfo,
                icon: const Icon(Icons.info_outline, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            l10n.getString(scene.subtitleKey),
            style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70),
          ),
          if (scene.highlightKeys.isNotEmpty) ...[
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: scene.highlightKeys
                  .map(
                    (key) => Chip(
                      label: Text(
                        l10n.getString(key),
                        style: const TextStyle(color: Colors.white),
                      ),
                      backgroundColor: Colors.white.withOpacity(0.15),
                      visualDensity: VisualDensity.compact,
                    ),
                  )
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }
}

Future<void> _showSceneDetails(BuildContext context, EnvironmentScene scene) {
  final environment = AppScope.of(context).environmentController;
  final messenger = ScaffoldMessenger.of(context);
  final l10n = context.l10n;
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
    ),
    builder: (sheetContext) {
      final theme = Theme.of(sheetContext);
      return ValueListenableBuilder<EnvironmentScene>(
        valueListenable: environment.currentSceneNotifier,
        builder: (context, activeScene, _) {
          final isActive = activeScene.id == scene.id;
          final metrics = scene.metrics;
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        l10n.getString(scene.titleKey),
                        style: theme.textTheme.headlineMedium,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(sheetContext).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.getString(scene.subtitleKey),
                  style: theme.textTheme.bodyLarge,
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.getString('sceneHighlightsTitle'),
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                ...scene.highlightKeys.map(
                  (key) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.check_circle_outline, size: 20),
                        const SizedBox(width: 8),
                        Expanded(child: Text(l10n.getString(key))),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.getString('sceneMetricsTitle'),
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${l10n.getString('sceneAirQuality')}: AQI ${metrics.airQuality}',
                      ),
                    ),
                    Expanded(
                      child: Text(
                        '${l10n.getString('sceneHumidity')}: ${metrics.humidity}%',
                      ),
                    ),
                    Expanded(
                      child: Text(
                        '${l10n.getString('sceneTemperature')}: ${metrics.temperatureC.toStringAsFixed(1)}°C',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                PrimaryButton(
                  label: l10n.getString('sceneApply'),
                  icon: Icons.check,
                  onPressed: isActive
                      ? null
                      : () {
                          environment.applyScene(scene.id);
                          Navigator.of(sheetContext).pop();
                          messenger.hideCurrentSnackBar();
                          messenger.showSnackBar(
                            SnackBar(
                              content: Text(
                                l10n
                                    .getString('sceneAppliedMessage')
                                    .replaceFirst(
                                      '{scene}',
                                      l10n.getString(scene.titleKey),
                                    ),
                              ),
                            ),
                          );
                        },
                ),
                const SizedBox(height: 12),
              ],
            ),
          );
        },
      );
    },
  );
}

Future<void> _showRoutineSheet(BuildContext context, _RoutineBlueprint routine) {
  final l10n = context.l10n;
  final theme = Theme.of(context);
  return showModalBottomSheet(
    context: context,
    backgroundColor: theme.colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
    ),
    builder: (context) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(routine.icon, color: theme.colorScheme.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    routine.title,
                    style: theme.textTheme.headlineSmall,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              routine.longDescription,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: () => Navigator.of(context).pushNamed('/catalog'),
              icon: const Icon(Icons.storefront),
              label: Text(l10n.getString('routineShopCta')),
            ),
            const SizedBox(height: 12),
          ],
        ),
      );
    },
  );
}

class _RoutineBlueprint {
  const _RoutineBlueprint({
    required this.title,
    required this.description,
    required this.longDescription,
    required this.imageSeed,
    required this.icon,
  });

  final String title;
  final String description;
  final String longDescription;
  final String imageSeed;
  final IconData icon;

  static List<_RoutineBlueprint> samples(AppLocalizations l10n) {
    return [
      _RoutineBlueprint(
        title: l10n.getString('routineMorningTitle'),
        description: l10n.getString('routineMorningSubtitle'),
        longDescription: l10n.getString('routineMorningBody'),
        imageSeed: 'routine-morning-light',
        icon: Icons.wb_sunny,
      ),
      _RoutineBlueprint(
        title: l10n.getString('routineSleepTitle'),
        description: l10n.getString('routineSleepSubtitle'),
        longDescription: l10n.getString('routineSleepBody'),
        imageSeed: 'routine-sleep-haven',
        icon: Icons.nightlight,
      ),
      _RoutineBlueprint(
        title: l10n.getString('routineAllergyTitle'),
        description: l10n.getString('routineAllergySubtitle'),
        longDescription: l10n.getString('routineAllergyBody'),
        imageSeed: 'routine-allergy-guard',
        icon: Icons.grass,
      ),
    ];
  }
}
