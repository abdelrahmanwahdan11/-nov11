import 'dart:async';

import 'package:flutter/material.dart';

import '../../app_scope.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/utils/context_extensions.dart';
import '../../shared/controllers/catalog_controller.dart';
import '../../shared/controllers/search_controller.dart';
import '../../shared/data/mock_products.dart';
import '../../shared/models/product.dart';
import '../../shared/widgets/product_card.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late final SearchController _controller;
  final TextEditingController _query = TextEditingController();
  late final ValueNotifier<Map<String, dynamic>> _filters;
  String _selectedCategory = '';
  String _selectedSort = 'relevance';

  @override
  void initState() {
    super.initState();
    _controller = SearchController();
    _filters = ValueNotifier<Map<String, dynamic>>({});
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is String && args.isNotEmpty) {
      _query.text = args;
      _controller.search(args, _filters.value);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _query.dispose();
    _filters.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final favorites = AppScope.of(context).favoritesController;
    final catalog = AppScope.of(context).catalogController;
    final l10n = context.l10n;
    final sortOptions = <String, String>{
      'relevance': l10n.getString('relevance'),
      'price_low_high': l10n.getString('priceLowHigh'),
      'price_high_low': l10n.getString('priceHighLow'),
      'rating_desc': l10n.getString('ratingDesc'),
      'name_asc': l10n.getString('nameAsc'),
    };
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _query,
          autofocus: true,
          decoration: InputDecoration(
            hintText: l10n.getString('searchPlaceholder'),
            border: InputBorder.none,
          ),
          onChanged: _onQueryChanged,
          onSubmitted: (value) => _controller.search(value, _filters.value),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_alt),
            onPressed: () async {
              final result = await _showFilterSheet(context, catalog);
              if (result != null) {
                _updateFilters(result);
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(l10n.getString('search')), 
                    TextButton(
                      onPressed: () => _clearFilters(),
                      child: Text(l10n.getString('resetAll')),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ValueListenableBuilder<Map<String, dynamic>>(
                  valueListenable: _filters,
                  builder: (context, filters, _) {
                    final chips = _buildActiveFilterChips(context, filters);
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
                Wrap(
                  spacing: 8,
                  children: ['fan', 'heater', 'purifier'].map((category) {
                    return ValueListenableBuilder<Map<String, dynamic>>(
                      valueListenable: _filters,
                      builder: (context, filters, _) {
                        final selected = filters['category'] == category;
                        return ChoiceChip(
                          label: Text(_categoryLabel(l10n, category)),
                          selected: selected,
                          onSelected: (_) => _toggleCategory(category),
                        );
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
                ValueListenableBuilder<Map<String, dynamic>>(
                  valueListenable: _filters,
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
                              selected:
                                  (filters['tags'] as List<String>? ?? [])
                                      .contains(tag),
                              onSelected: (_) => _toggleTag(tag),
                            ),
                          )
                          .toList(),
                    );
                  },
                ),
                const SizedBox(height: 12),
                ValueListenableBuilder<List<String>>(
                  valueListenable: _controller.recentNotifier,
                  builder: (context, recent, _) {
                    if (recent.isEmpty) {
                      return const SizedBox.shrink();
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              l10n.getString('recentSearches'),
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            TextButton(
                              onPressed: _controller.clearRecent,
                              child: Text(l10n.getString('clearHistory')),
                            ),
                          ],
                        ),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: recent
                              .map(
                                (query) => InputChip(
                                  label: Text(query),
                                  onPressed: () => _applySuggestion(query),
                                  onDeleted: () => _controller.removeRecent(query),
                                ),
                              )
                              .toList(),
                        ),
                        const SizedBox(height: 12),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 12),
                ValueListenableBuilder<List<String>>(
                  valueListenable: _controller.suggestionNotifier,
                  builder: (context, suggestions, _) {
                    if (suggestions.isEmpty) {
                      return const SizedBox.shrink();
                    }
                    return Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: suggestions
                          .map(
                            (suggestion) => ActionChip(
                              label: Text(suggestion),
                              onPressed: () => _applySuggestion(suggestion),
                            ),
                          )
                          .toList(),
                    );
                  },
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: sortOptions.entries.map((entry) {
                    final selected = _selectedSort == entry.key;
                    return ChoiceChip(
                      label: Text(entry.value),
                      selected: selected,
                      onSelected: (value) {
                        if (!value) return;
                        setState(() => _selectedSort = entry.key);
                        _controller.setSort(entry.key);
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ValueListenableBuilder<Map<String, dynamic>>(
              valueListenable: _filters,
              builder: (context, filters, _) {
                return StreamBuilder<List<Product>>(
                  stream: _controller.results,
                  builder: (context, snapshot) {
                    final results = snapshot.data ?? [];
                    if (results.isEmpty) {
                      if (_query.text.isEmpty && filters.isEmpty) {
                        final trending = catalog.productsNotifier.value.isNotEmpty
                            ? catalog.productsNotifier.value
                            : mockProducts;
                        return _buildTrending(context, trending);
                      }
                      return Center(
                        child: Text(l10n.getString('searchEmpty')),
                      );
                    }
                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              l10n.getString('resultsCount')
                                  .replaceFirst('{count}', results.length.toString()),
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: ValueListenableBuilder<List<Product>>(
                            valueListenable: favorites.favoritesNotifier,
                            builder: (context, favs, __) {
                              return GridView.builder(
                                padding: const EdgeInsets.all(24),
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  mainAxisSpacing: 16,
                                  crossAxisSpacing: 16,
                                  childAspectRatio: 0.68,
                                ),
                                itemCount: results.length,
                                itemBuilder: (context, index) {
                                  final product = results[index];
                                  final isFav =
                                      favs.any((element) => element.id == product.id);
                                  return ProductCard(
                                    product: product,
                                    isFavorite: isFav,
                                    onFavorite: () => favorites.toggleFavorite(product),
                                    onTap: () => Navigator.of(context)
                                        .pushNamed('/product', arguments: product.id),
                                    onCompare: () {
                                      AppScope.of(context)
                                          .compareController
                                          .addProduct(product);
                                      Navigator.of(context).pushNamed('/compare');
                                    },
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ],
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

  void _onQueryChanged(String value) {
    _controller.search(value, _filters.value);
  }

  void _updateFilters(Map<String, dynamic> next) {
    final updated = {...next};
    if (_selectedCategory.isNotEmpty) {
      updated['category'] = _selectedCategory;
    }
    _filters.value = updated;
    _controller.updateFilters(updated);
  }

  void _clearFilters() {
    _selectedCategory = '';
    _filters.value = {};
    _controller.updateFilters({});
  }

  void _toggleCategory(String category) {
    if (_selectedCategory == category) {
      _selectedCategory = '';
    } else {
      _selectedCategory = category;
    }
    _updateFilters({..._filters.value});
  }

  void _toggleTag(String tag) {
    final current = {..._filters.value};
    final tags = (current['tags'] as List<String>? ?? <String>[]).toList();
    if (tags.contains(tag)) {
      tags.remove(tag);
    } else {
      tags.add(tag);
    }
    if (tags.isEmpty) {
      current.remove('tags');
    } else {
      current['tags'] = tags;
    }
    _updateFilters(current);
  }

  void _applySuggestion(String suggestion) {
    _query.text = suggestion;
    _controller.search(suggestion, _filters.value);
  }

  List<Widget> _buildActiveFilterChips(
    BuildContext context,
    Map<String, dynamic> filters,
  ) {
    final l10n = context.l10n;
    final chips = <Widget>[];
    final category = filters['category'] as String?;
    if (category != null && category.isNotEmpty) {
      chips.add(
        InputChip(
          label: Text(_categoryLabel(l10n, category)),
          onDeleted: () => _toggleCategory(category),
        ),
      );
    }
    final tags = filters['tags'] as List<String>? ?? [];
    for (final tag in tags) {
      chips.add(
        InputChip(
          label: Text(tag),
          onDeleted: () => _toggleTag(tag),
        ),
      );
    }
    final hepa = filters['hepaClass'] as String?;
    if (hepa != null && hepa.isNotEmpty) {
      chips.add(
        InputChip(
          label: Text('${l10n.getString('hepaClass')} $hepa'),
          onDeleted: () {
            final current = {...filters};
            current.remove('hepaClass');
            _updateFilters(current);
          },
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
          onDeleted: () {
            final current = {...filters};
            current.remove('priceRange');
            _updateFilters(current);
          },
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
          onDeleted: () {
            final current = {...filters};
            current.remove('powerRange');
            _updateFilters(current);
          },
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
          onDeleted: () {
            final current = {...filters};
            current.remove('noiseRange');
            _updateFilters(current);
          },
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
          onDeleted: () {
            final current = {...filters};
            current.remove('ratingMin');
            _updateFilters(current);
          },
        ),
      );
    }
    return chips;
  }

  Widget _buildTrending(BuildContext context, List<Product> items) {
    final l10n = context.l10n;
    final currency = l10n.getString('currencySymbol');
    final trending = items.take(6).toList();
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      children: [
        Text(
          l10n.getString('trendingSearches'),
          style: context.textTheme.headlineSmall,
        ),
        const SizedBox(height: 12),
        ...trending.map(
          (product) => Card(
            elevation: 0,
            color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.4),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              title: Text(product.name),
              subtitle:
                  Text('${product.brand} · $currency${product.price.toStringAsFixed(0)}'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.of(context).pushNamed('/product', arguments: product.id);
              },
            ),
          ),
        ),
      ],
    );
  }

  Future<Map<String, dynamic>?> _showFilterSheet(
    BuildContext context,
    CatalogController catalog,
  ) async {
    final l10n = context.l10n;
    final current = {..._filters.value}..remove('category');
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
          builder: (context, setStateModal) {
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
                          setStateModal(() {
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
                    onChanged: (value) => setStateModal(() => range = value),
                  ),
                  Text('${range.start.toStringAsFixed(0)} - ${range.end.toStringAsFixed(0)}'),
                  const SizedBox(height: 16),
                  Text(l10n.getString('powerRange')),
                  RangeSlider(
                    values: powerRange,
                    min: catalog.powerDomain.start,
                    max: catalog.powerDomain.end,
                    onChanged: (value) => setStateModal(() => powerRange = value),
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
                    onChanged: (value) => setStateModal(() => noiseRange = value),
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
                    onChanged: (value) => setStateModal(() => rating = value),
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
                            onSelected: (value) => setStateModal(
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
                            onSelected: (value) => setStateModal(() {
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

  String _categoryLabel(AppLocalizations l10n, String key) {
    switch (key) {
      case 'fan':
        return l10n.getString('fans');
      case 'heater':
        return l10n.getString('heaters');
      case 'purifier':
        return l10n.getString('purifiers');
      default:
        return key;
    }
  }
}
