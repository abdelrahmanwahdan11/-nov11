import 'package:flutter/material.dart';

import '../../app_scope.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/utils/context_extensions.dart';
import '../../shared/controllers/catalog_controller.dart';
import '../../shared/models/product.dart';
import '../../shared/widgets/product_card.dart';
import '../../shared/widgets/skeleton_box.dart';

class CatalogPage extends StatefulWidget {
  const CatalogPage({super.key});

  @override
  State<CatalogPage> createState() => _CatalogPageState();
}

class _CatalogPageState extends State<CatalogPage> {
  late final ScrollController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ScrollController()
      ..addListener(() {
        if (_controller.position.pixels >=
            _controller.position.maxScrollExtent - 200) {
          AppScope.of(context).catalogController.loadMore();
        }
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final catalog = AppScope.of(context).catalogController;
    final favorites = AppScope.of(context).favoritesController;
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.getString('catalog')),
        actions: [
          IconButton(
            onPressed: () async {
              final sort = await _showSortSheet(context);
              if (sort != null) {
                catalog.updateSort(sort);
              }
            },
            icon: const Icon(Icons.sort),
          ),
          IconButton(
            onPressed: () async {
              final filters = await _showFilterSheet(context);
              if (filters != null) {
                catalog.updateFilters(filters);
              }
            },
            icon: const Icon(Icons.filter_alt),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search),
                    hintText: l10n.getString('searchPlaceholder'),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(28)),
                  ),
                  onSubmitted: (value) {
                    Navigator.of(context).pushNamed('/search', arguments: value);
                  },
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: ValueListenableBuilder<String>(
                        valueListenable: catalog.sortNotifier,
                        builder: (context, sortKey, _) {
                          if (sortKey.isEmpty) {
                            return const SizedBox.shrink();
                          }
                          return Align(
                            alignment: Alignment.centerLeft,
                            child: InputChip(
                              label: Text(
                                l10n.getString('sortedBy') +
                                    ': ' +
                                    _sortLabel(l10n, sortKey),
                              ),
                              onDeleted: () => catalog.updateSort(''),
                            ),
                          );
                        },
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        catalog.clearFilters();
                        catalog.updateSort('');
                      },
                      child: Text(l10n.getString('resetAll')),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ValueListenableBuilder<Map<String, dynamic>>(
                  valueListenable: catalog.filtersNotifier,
                  builder: (context, filters, _) {
                    final chips =
                        _buildActiveFilterChips(context, filters, catalog);
                    if (chips.isEmpty) {
                      return Text(
                        l10n.getString('filtersEmptyHint'),
                        style: Theme.of(context).textTheme.bodySmall,
                      );
                    }
                    return Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: chips,
                    );
                  },
                ),
                const SizedBox(height: 12),
                ValueListenableBuilder<Map<String, dynamic>>(
                  valueListenable: catalog.filtersNotifier,
                  builder: (context, filters, _) {
                    final quickTags = catalog.quickTagSuggestions(limit: 6);
                    if (quickTags.isEmpty) {
                      return const SizedBox.shrink();
                    }
                    return Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: quickTags
                          .map(
                            (tag) => FilterChip(
                              label: Text(tag),
                              selected: (filters['tags'] as List<String>? ?? [])
                                  .contains(tag),
                              onSelected: (_) => catalog.toggleTag(tag),
                            ),
                          )
                          .toList(),
                    );
                  },
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
          Expanded(
            child: ValueListenableBuilder<List<Product>>(
              valueListenable: catalog.productsNotifier,
              builder: (context, products, _) {
                return ValueListenableBuilder<Map<String, dynamic>>(
                  valueListenable: catalog.filtersNotifier,
                  builder: (context, __, ___) {
                    return ValueListenableBuilder<String>(
                      valueListenable: catalog.sortNotifier,
                      builder: (context, ___, ____) {
                        if (products.isEmpty) {
                          return GridView.builder(
                            padding: const EdgeInsets.all(24),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 16,
                              crossAxisSpacing: 16,
                              childAspectRatio: 0.68,
                            ),
                            itemBuilder: (context, index) =>
                                const SkeletonBox(width: double.infinity, height: 220),
                            itemCount: 4,
                          );
                        }
                        final filtered = catalog.applyFilters(products);
                        if (filtered.isEmpty) {
                          return Center(child: Text(l10n.getString('noResults')));
                        }
                        return ValueListenableBuilder<List<Product>>(
                          valueListenable: favorites.favoritesNotifier,
                          builder: (context, favs, __) {
                            return GridView.builder(
                              controller: _controller,
                              padding: const EdgeInsets.all(24),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                mainAxisSpacing: 16,
                                crossAxisSpacing: 16,
                                childAspectRatio: 0.68,
                              ),
                              itemCount: filtered.length,
                              itemBuilder: (context, index) {
                                final product = filtered[index];
                                final isFav = favs.any((element) => element.id == product.id);
                                return ProductCard(
                                  product: product,
                                  isFavorite: isFav,
                                  onFavorite: () => favorites.toggleFavorite(product),
                                  onTap: () => Navigator.of(context)
                                      .pushNamed('/product', arguments: product.id),
                                  onCompare: () {
                                    AppScope.of(context).compareController.addProduct(product);
                                    Navigator.of(context).pushNamed('/compare');
                                  },
                                );
                              },
                            );
                          },
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
    );
  }

  Future<String?> _showSortSheet(BuildContext context) async {
    final l10n = context.l10n;
    return showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        final options = {
          'price_low_high': l10n.getString('priceLowHigh'),
          'price_high_low': l10n.getString('priceHighLow'),
          'rating_desc': l10n.getString('ratingDesc'),
          'name_asc': l10n.getString('nameAsc'),
        };
        return ListView(
          padding: const EdgeInsets.all(24),
          children: options.entries
              .map((entry) => ListTile(
                    title: Text(entry.value),
                    onTap: () => Navigator.of(context).pop(entry.key),
                  ))
              .toList(),
        );
      },
    );
  }

  Future<Map<String, dynamic>?> _showFilterSheet(BuildContext context) async {
    final l10n = context.l10n;
    final catalog = AppScope.of(context).catalogController;
    final current = catalog.filtersNotifier.value;
    RangeValues range = current['priceRange'] as RangeValues? ?? catalog.priceDomain;
    RangeValues powerRange =
        current['powerRange'] as RangeValues? ?? catalog.powerDomain;
    RangeValues noiseRange =
        current['noiseRange'] as RangeValues? ?? catalog.noiseDomain;
    String hepa = current['hepaClass'] as String? ?? '';
    double rating = current['ratingMin'] as double? ?? 0;
    final tags = <String>{...(current['tags'] as List<String>? ?? [])};
    return showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                top: 24,
                left: 24,
                right: 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(l10n.getString('filters'),
                          style: context.textTheme.headlineMedium),
                      TextButton(
                        onPressed: () {
                          setModalState(() {
                            range = catalog.priceDomain;
                            powerRange = catalog.powerDomain;
                            noiseRange = catalog.noiseDomain;
                            hepa = '';
                            rating = 0;
                            tags.clear();
                          });
                        },
                        child: Text(l10n.getString('clear')),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(l10n.getString('priceRange')),
                  RangeSlider(
                    values: range,
                    min: catalog.priceDomain.start,
                    max: catalog.priceDomain.end,
                    onChanged: (value) => setModalState(() => range = value),
                  ),
                  Text('${range.start.toStringAsFixed(0)} - ${range.end.toStringAsFixed(0)}'),
                  const SizedBox(height: 16),
                  Text(l10n.getString('powerRange')),
                  RangeSlider(
                    values: powerRange,
                    min: catalog.powerDomain.start,
                    max: catalog.powerDomain.end,
                    onChanged: (value) => setModalState(() => powerRange = value),
                  ),
                  Text(
                    '${powerRange.start.toStringAsFixed(0)}W - ${powerRange.end.toStringAsFixed(0)}W',
                  ),
                  const SizedBox(height: 16),
                  Text(l10n.getString('noiseRange')),
                  RangeSlider(
                    values: noiseRange,
                    min: catalog.noiseDomain.start,
                    max: catalog.noiseDomain.end,
                    onChanged: (value) => setModalState(() => noiseRange = value),
                  ),
                  Text(
                    '${noiseRange.start.toStringAsFixed(0)} dB - ${noiseRange.end.toStringAsFixed(0)} dB',
                  ),
                  const SizedBox(height: 16),
                  Text(l10n.getString('ratingAbove')),
                  Slider(
                    value: rating,
                    min: 0,
                    max: 5,
                    divisions: 10,
                    label: rating == 0
                        ? l10n.getString('any')
                        : rating.toStringAsFixed(1),
                    onChanged: (value) => setModalState(() => rating = value),
                  ),
                  const SizedBox(height: 16),
                  Text(l10n.getString('hepaClass')),
                  Wrap(
                    spacing: 8,
                    children: catalog.availableHepaClasses
                        .map(
                          (className) => ChoiceChip(
                            label: Text(className),
                            selected: hepa == className,
                            onSelected: (value) => setModalState(
                              () => hepa = value ? className : '',
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 16),
                  Text(l10n.getString('tags')),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: catalog.availableTags
                        .map(
                          (tag) => FilterChip(
                            label: Text(tag),
                            selected: tags.contains(tag),
                            onSelected: (value) => setModalState(() {
                              if (value) {
                                tags.add(tag);
                              } else {
                                tags.remove(tag);
                              }
                            }),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop({
                          'priceRange': range,
                          'powerRange': powerRange,
                          'noiseRange': noiseRange,
                          if (hepa.isNotEmpty) 'hepaClass': hepa,
                          if (rating > 0) 'ratingMin': rating,
                          if (tags.isNotEmpty) 'tags': tags.toList(),
                        });
                      },
                      child: Text(l10n.getString('apply')),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  List<Widget> _buildActiveFilterChips(
    BuildContext context,
    Map<String, dynamic> filters,
    CatalogController controller,
  ) {
    final l10n = context.l10n;
    final chips = <Widget>[];
    final tags = filters['tags'] as List<String>? ?? [];
    for (final tag in tags) {
      chips.add(
        InputChip(
          label: Text(tag),
          onDeleted: () => controller.toggleTag(tag),
        ),
      );
    }
    final hepa = filters['hepaClass'] as String?;
    if (hepa != null && hepa.isNotEmpty) {
      chips.add(
        InputChip(
          label: Text('${l10n.getString('hepaClass')} $hepa'),
          onDeleted: () => controller.removeFilter('hepaClass'),
        ),
      );
    }
    final priceRange = filters['priceRange'] as RangeValues?;
    if (priceRange != null) {
      chips.add(
        InputChip(
          label: Text(
            '${l10n.getString('price')} ${priceRange.start.toStringAsFixed(0)}-${priceRange.end.toStringAsFixed(0)}',
          ),
          onDeleted: () => controller.removeFilter('priceRange'),
        ),
      );
    }
    final powerRange = filters['powerRange'] as RangeValues?;
    if (powerRange != null) {
      chips.add(
        InputChip(
          label: Text(
            '${l10n.getString('power')} ${powerRange.start.toStringAsFixed(0)}-${powerRange.end.toStringAsFixed(0)}W',
          ),
          onDeleted: () => controller.removeFilter('powerRange'),
        ),
      );
    }
    final noiseRange = filters['noiseRange'] as RangeValues?;
    if (noiseRange != null) {
      chips.add(
        InputChip(
          label: Text(
            '${l10n.getString('noise')} ${noiseRange.start.toStringAsFixed(0)}-${noiseRange.end.toStringAsFixed(0)} dB',
          ),
          onDeleted: () => controller.removeFilter('noiseRange'),
        ),
      );
    }
    final ratingMin = filters['ratingMin'] as double?;
    if (ratingMin != null && ratingMin > 0) {
      chips.add(
        InputChip(
          label: Text(
            '${l10n.getString('rating')} ≥ ${ratingMin.toStringAsFixed(1)}',
          ),
          onDeleted: () => controller.removeFilter('ratingMin'),
        ),
      );
    }
    return chips;
  }

  String _sortLabel(AppLocalizations l10n, String key) {
    switch (key) {
      case 'price_low_high':
        return l10n.getString('priceLowHigh');
      case 'price_high_low':
        return l10n.getString('priceHighLow');
      case 'rating_desc':
        return l10n.getString('ratingDesc');
      case 'name_asc':
        return l10n.getString('nameAsc');
      default:
        return l10n.getString('sort');
    }
  }
}
