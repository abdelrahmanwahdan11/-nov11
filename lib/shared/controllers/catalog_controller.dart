import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../data/mock_products.dart';
import '../models/product.dart';

class CatalogController {
  CatalogController() {
    productsNotifier = ValueNotifier<List<Product>>([]);
    filtersNotifier = ValueNotifier<Map<String, dynamic>>({});
    sortNotifier = ValueNotifier<String>('');
    _availableTags = {
      for (final product in mockProducts) ...product.tags,
    }.toList()
      ..sort();
    _availableHepaClasses = {
      for (final product in mockProducts)
        if (product.hepaClass != null) product.hepaClass!,
    }.toList()
      ..sort();
  }

  late final ValueNotifier<List<Product>> productsNotifier;
  late final ValueNotifier<Map<String, dynamic>> filtersNotifier;
  late final ValueNotifier<String> sortNotifier;
  late final List<String> _availableTags;
  late final List<String> _availableHepaClasses;

  List<String> get availableTags => _availableTags;

  List<String> get availableHepaClasses => _availableHepaClasses;

  static const int pageSize = 10;
  int _page = 0;
  bool _isLoading = false;

  Future<void> loadInitial() async {
    productsNotifier.value = [];
    _page = 0;
    await loadMore();
  }

  Future<void> refresh() async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    await loadInitial();
  }

  Future<void> loadMore() async {
    if (_isLoading) return;
    _isLoading = true;
    await Future<void>.delayed(const Duration(milliseconds: 450));
    final start = _page * pageSize;
    if (start >= mockProducts.length) {
      _isLoading = false;
      return;
    }
    final end = start + pageSize;
    final slice = mockProducts.sublist(
      start,
      end > mockProducts.length ? mockProducts.length : end,
    );
    productsNotifier.value = [...productsNotifier.value, ...slice];
    if (slice.isNotEmpty) {
      _page++;
    }
    _isLoading = false;
  }

  void updateFilters(Map<String, dynamic> filters) {
    filtersNotifier.value = {...filters};
  }

  void updateSort(String sort) {
    sortNotifier.value = sort;
  }

  void clearFilters() {
    filtersNotifier.value = {};
  }

  void removeFilter(String key) {
    final filters = {...filtersNotifier.value};
    filters.remove(key);
    filtersNotifier.value = filters;
  }

  void toggleTag(String tag) {
    final filters = {...filtersNotifier.value};
    final tags = (filters['tags'] as List<String>? ?? <String>[]).toList();
    if (tags.contains(tag)) {
      tags.remove(tag);
    } else {
      tags.add(tag);
    }
    if (tags.isEmpty) {
      filters.remove('tags');
    } else {
      filters['tags'] = tags;
    }
    filtersNotifier.value = filters;
  }

  List<String> quickTagSuggestions({int limit = 6}) {
    if (_availableTags.length <= limit) {
      return _availableTags;
    }
    return _availableTags.sublist(0, limit);
  }

  RangeValues get priceDomain {
    final prices = mockProducts.map((product) => product.price).toList();
    final minPrice = prices.reduce(math.min);
    final maxPrice = prices.reduce(math.max);
    return RangeValues(minPrice, maxPrice);
  }

  RangeValues get powerDomain {
    final values = mockProducts
        .map((product) => product.powerW?.toDouble())
        .whereType<double>()
        .toList();
    if (values.isEmpty) {
      return const RangeValues(0, 100);
    }
    final minPower = values.reduce(math.min);
    final maxPower = values.reduce(math.max);
    return RangeValues(minPower, maxPower);
  }

  RangeValues get noiseDomain {
    final values = mockProducts
        .map((product) => product.noiseLevelDb?.toDouble())
        .whereType<double>()
        .toList();
    if (values.isEmpty) {
      return const RangeValues(0, 60);
    }
    final minNoise = values.reduce(math.min);
    final maxNoise = values.reduce(math.max);
    return RangeValues(minNoise, maxNoise);
  }

  List<Product> applyFilters(List<Product> items) {
    final filters = filtersNotifier.value;
    var filtered = items;
    final tags = filters['tags'] as List<String>?;
    if (tags != null && tags.isNotEmpty) {
      filtered = filtered
          .where((p) => tags.every((tag) => p.tags.contains(tag)))
          .toList();
    }
    final hepa = filters['hepaClass'] as String?;
    if (hepa != null && hepa.isNotEmpty) {
      filtered = filtered.where((p) => p.hepaClass == hepa).toList();
    }
    final priceRange = filters['priceRange'] as RangeValues?;
    if (priceRange != null) {
      filtered = filtered
          .where((p) =>
              p.price >= priceRange.start && p.price <= priceRange.end)
          .toList();
    }
    final powerRange = filters['powerRange'] as RangeValues?;
    if (powerRange != null) {
      filtered = filtered
          .where((p) => p.powerW != null &&
              p.powerW! >= powerRange.start && p.powerW! <= powerRange.end)
          .toList();
    }
    final noiseRange = filters['noiseRange'] as RangeValues?;
    if (noiseRange != null) {
      filtered = filtered
          .where((p) => p.noiseLevelDb != null &&
              p.noiseLevelDb! >= noiseRange.start &&
              p.noiseLevelDb! <= noiseRange.end)
          .toList();
    }
    final ratingMin = filters['ratingMin'] as double?;
    if (ratingMin != null) {
      filtered =
          filtered.where((product) => product.rating >= ratingMin).toList();
    }
    return _applySort(filtered);
  }

  List<Product> _applySort(List<Product> items) {
    final list = [...items];
    switch (sortNotifier.value) {
      case 'price_low_high':
        list.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'price_high_low':
        list.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'rating_desc':
        list.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case 'name_asc':
        list.sort((a, b) => a.name.compareTo(b.name));
        break;
      default:
        break;
    }
    return list;
  }
}
