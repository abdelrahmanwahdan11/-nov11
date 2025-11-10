import 'dart:async';

import 'package:flutter/material.dart';

import '../data/mock_products.dart';
import '../models/product.dart';

class SearchController {
  SearchController() {
    _controller = StreamController<List<Product>>.broadcast();
    _lastFilters = <String, dynamic>{};
  }

  late final StreamController<List<Product>> _controller;
  Stream<List<Product>> get results => _controller.stream;
  String _lastQuery = '';
  Map<String, dynamic> _lastFilters = {};

  void dispose() {
    _controller.close();
  }

  void search(String query, Map<String, dynamic> filters) {
    _lastQuery = query;
    _lastFilters = {...filters};
    final lower = query.toLowerCase().trim();
    var matches = mockProducts.where((product) {
      final queryMatch = lower.isEmpty ||
          product.name.toLowerCase().contains(lower) ||
          product.brand.toLowerCase().contains(lower) ||
          product.tags.any((tag) => tag.toLowerCase().contains(lower)) ||
          product.specs.entries.any((entry) =>
              entry.key.toLowerCase().contains(lower) ||
              entry.value.toLowerCase().contains(lower));
      return queryMatch;
    }).toList();
    matches = _applyFilters(matches, filters);
    _controller.add(matches);
  }

  void updateFilters(Map<String, dynamic> filters) {
    search(_lastQuery, filters);
  }

  Map<String, dynamic> get lastFilters => _lastFilters;

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
          .where((product) =>
              tags.every((tag) => product.tags.contains(tag)))
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
}
