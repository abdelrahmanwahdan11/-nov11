import 'package:flutter/material.dart';

import '../../app_scope.dart';
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
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: l10n.getString('searchPlaceholder'),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(28)),
              ),
              onSubmitted: (value) {
                Navigator.of(context).pushNamed('/search', arguments: value);
              },
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
    RangeValues range = const RangeValues(100, 600);
    RangeValues powerRange = const RangeValues(10, 70);
    RangeValues noiseRange = const RangeValues(10, 40);
    String hepa = '';
    final tags = <String>{};
    return showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            top: 24,
            left: 24,
            right: 24,
          ),
          child: StatefulBuilder(
            builder: (context, setModalState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.getString('filters'), style: context.textTheme.headlineMedium),
                  const SizedBox(height: 16),
                  Text(l10n.getString('price')),
                  RangeSlider(
                    values: range,
                    min: 100,
                    max: 600,
                    onChanged: (value) => setModalState(() => range = value),
                  ),
                  const SizedBox(height: 16),
                  Text(l10n.getString('power')),
                  RangeSlider(
                    values: powerRange,
                    min: 10,
                    max: 80,
                    divisions: 7,
                    labels: RangeLabels(
                      powerRange.start.toStringAsFixed(0),
                      powerRange.end.toStringAsFixed(0),
                    ),
                    onChanged: (value) => setModalState(() => powerRange = value),
                  ),
                  const SizedBox(height: 16),
                  Text(l10n.getString('noise')),
                  RangeSlider(
                    values: noiseRange,
                    min: 10,
                    max: 40,
                    divisions: 6,
                    labels: RangeLabels(
                      noiseRange.start.toStringAsFixed(0),
                      noiseRange.end.toStringAsFixed(0),
                    ),
                    onChanged: (value) => setModalState(() => noiseRange = value),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: hepa.isEmpty ? null : hepa,
                    decoration: InputDecoration(labelText: l10n.getString('hepaClass')),
                    items: const [
                      DropdownMenuItem(value: 'H11', child: Text('H11')),
                      DropdownMenuItem(value: 'H13', child: Text('H13')),
                    ],
                    onChanged: (value) => setModalState(() => hepa = value ?? ''),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    children: [
                      'HEPA',
                      'oscillation',
                      'Hybrid',
                    ].map((tag) {
                      final selected = tags.contains(tag);
                      return FilterChip(
                        label: Text(tag),
                        selected: selected,
                        onSelected: (value) {
                          setModalState(() {
                            if (value) {
                              tags.add(tag);
                            } else {
                              tags.remove(tag);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop({
                        'priceRange': range,
                        'powerRange': powerRange,
                        'noiseRange': noiseRange,
                        'hepaClass': hepa,
                        'tags': tags.toList(),
                      });
                    },
                    child: Text(l10n.getString('apply')),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}
