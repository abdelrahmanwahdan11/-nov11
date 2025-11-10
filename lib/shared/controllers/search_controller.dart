import 'dart:async';

import '../data/mock_products.dart';
import '../models/product.dart';

class SearchController {
  SearchController() {
    _controller = StreamController<List<Product>>.broadcast();
  }

  late final StreamController<List<Product>> _controller;
  Stream<List<Product>> get results => _controller.stream;

  void dispose() {
    _controller.close();
  }

  void search(String query, Map<String, dynamic> filters) {
    final lower = query.toLowerCase();
    final matches = mockProducts.where((product) {
      final baseMatch = product.name.toLowerCase().contains(lower) ||
          product.brand.toLowerCase().contains(lower) ||
          product.tags.any((tag) => tag.toLowerCase().contains(lower)) ||
          product.specs.entries.any((entry) =>
              entry.key.toLowerCase().contains(lower) ||
              entry.value.toLowerCase().contains(lower));
      return baseMatch;
    }).toList();
    _controller.add(matches);
  }
}
