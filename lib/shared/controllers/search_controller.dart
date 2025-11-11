import 'dart:async';

import 'package:flutter/material.dart';

import '../data/mock_products.dart';
import '../models/product.dart';

class SearchController {
  SearchController() {
    _resultsController = StreamController<List<Product>>.broadcast();
    suggestionNotifier = ValueNotifier<List<String>>(_trendingQueries);
    _lastFilters = <String, dynamic>{};
    recentNotifier = ValueNotifier<List<String>>(<String>[]);
  }

  late final StreamController<List<Product>> _resultsController;
  Stream<List<Product>> get results => _resultsController.stream;
  late final ValueNotifier<List<String>> suggestionNotifier;
  late final ValueNotifier<List<String>> recentNotifier;

  String _lastQuery = '';
  Map<String, dynamic> _lastFilters = {};
  String _currentSort = 'relevance';
  Timer? _debounce;

  static final List<String> _trendingQueries = mockProducts
      .map((product) => product.name)
      .take(6)
      .toList();

  void dispose() {
    _debounce?.cancel();
    _resultsController.close();
    suggestionNotifier.dispose();
    recentNotifier.dispose();
  }

  void search(String query, Map<String, dynamic> filters) {
    _lastQuery = query;
    _lastFilters = {...filters};
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), _performSearch);
  }

  void setSort(String sort) {
    _currentSort = sort;
    _performSearch();
  }

  void updateFilters(Map<String, dynamic> filters) {
    _lastFilters = {...filters};
    _performSearch();
  }

  Map<String, dynamic> get lastFilters => _lastFilters;

  void _performSearch() {
    final query = _lastQuery.toLowerCase().trim();
    var matches = mockProducts.where((product) {
      if (query.isEmpty) {
        return true;
      }
      return product.name.toLowerCase().contains(query) ||
          product.brand.toLowerCase().contains(query) ||
          product.tags.any((tag) => tag.toLowerCase().contains(query)) ||
          product.specs.entries.any(
            (entry) =>
                entry.key.toLowerCase().contains(query) ||
                entry.value.toLowerCase().contains(query),
          );
    }).toList();

    matches = _applyFilters(matches, _lastFilters);
    matches = _applySort(matches);
    _resultsController.add(matches);
    if (_lastQuery.trim().isNotEmpty) {
      _addRecentQuery(_lastQuery.trim());
    }
    _updateSuggestions(query);
  }

  void _addRecentQuery(String query) {
    final list = [...recentNotifier.value];
    list.removeWhere((element) => element.toLowerCase() == query.toLowerCase());
    list.insert(0, query);
    if (list.length > 6) {
      list.removeRange(6, list.length);
    }
    recentNotifier.value = list;
  }

  void clearRecent() {
    recentNotifier.value = <String>[];
  }

  void removeRecent(String query) {
    final list = [...recentNotifier.value];
    list.removeWhere((element) => element == query);
    recentNotifier.value = list;
  }

  void _updateSuggestions(String query) {
    if (query.isEmpty) {
      suggestionNotifier.value = _trendingQueries;
      return;
    }
    final lower = query.toLowerCase();
    final suggestions = <String>{};
    for (final product in mockProducts) {
      if (product.name.toLowerCase().contains(lower)) {
        suggestions.add(product.name);
      }
      if (product.brand.toLowerCase().contains(lower)) {
        suggestions.add(product.brand);
      }
      for (final tag in product.tags) {
        if (tag.toLowerCase().contains(lower)) {
          suggestions.add(tag);
        }
      }
      if (suggestions.length >= 6) break;
    }
    if (suggestions.isEmpty) {
      suggestionNotifier.value = _trendingQueries;
    } else {
      suggestionNotifier.value = suggestions.take(6).toList();
    }
  }

  List<Product> _applyFilters(
    List<Product> items,
    Map<String, dynamic> filters,
  ) {
    var filtered = items;
    final category = filters['category'] as String?;
    if (category != null && category.isNotEmpty) {
      filtered = filtered
          .where((product) => product.tags
              .map((tag) => tag.toLowerCase())
              .contains(category.toLowerCase()))
          .toList();
    }
    final tags = filters['tags'] as List<String>?;
    if (tags != null && tags.isNotEmpty) {
      filtered = filtered
          .where((product) => tags.every((tag) => product.tags.contains(tag)))
          .toList();
    }
    final hepa = filters['hepaClass'] as String?;
    if (hepa != null && hepa.isNotEmpty) {
      filtered = filtered.where((product) => product.hepaClass == hepa).toList();
    }
    final priceRange = filters['priceRange'] as RangeValues?;
    if (priceRange != null) {
      filtered = filtered
          .where((product) =>
              product.price >= priceRange.start &&
              product.price <= priceRange.end)
          .toList();
    }
    final powerRange = filters['powerRange'] as RangeValues?;
    if (powerRange != null) {
      filtered = filtered
          .where((product) => product.powerW != null &&
              product.powerW! >= powerRange.start &&
              product.powerW! <= powerRange.end)
          .toList();
    }
    final noiseRange = filters['noiseRange'] as RangeValues?;
    if (noiseRange != null) {
      filtered = filtered
          .where((product) => product.noiseLevelDb != null &&
              product.noiseLevelDb! >= noiseRange.start &&
              product.noiseLevelDb! <= noiseRange.end)
          .toList();
    }
    final ratingMin = filters['ratingMin'] as double?;
    if (ratingMin != null && ratingMin > 0) {
      filtered =
          filtered.where((product) => product.rating >= ratingMin).toList();
    }
    return filtered;
  }

  List<Product> _applySort(List<Product> items) {
    final list = [...items];
    switch (_currentSort) {
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
