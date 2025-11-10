import 'package:flutter/material.dart';

import '../data/mock_products.dart';
import '../models/product.dart';

class CompareController {
  CompareController() {
    compareNotifier = ValueNotifier<List<Product>>([]);
    differencesOnly = ValueNotifier<bool>(false);
    highlightDifferences = ValueNotifier<bool>(true);
  }

  late final ValueNotifier<List<Product>> compareNotifier;
  late final ValueNotifier<bool> differencesOnly;
  late final ValueNotifier<bool> highlightDifferences;

  void addProduct(Product product) {
    final current = [...compareNotifier.value];
    if (current.any((p) => p.id == product.id)) {
      return;
    }
    if (current.length == 3) {
      current.removeAt(0);
    }
    current.add(product);
    compareNotifier.value = current;
  }

  void removeProduct(String id) {
    compareNotifier.value =
        compareNotifier.value.where((p) => p.id != id).toList();
  }

  void clear() {
    compareNotifier.value = [];
    differencesOnly.value = false;
    highlightDifferences.value = true;
  }

  Map<String, List<String?>> get comparisonMatrix {
    final items = compareNotifier.value;
    final keys = <String>{
      'Price',
      'Rating',
      'Noise (dB)',
      'Power (W)',
      for (final product in items) ...product.specs.keys,
    };
    final map = <String, List<String?>>{};
    for (final key in keys) {
      map[key] = List.generate(items.length, (index) {
        final product = items[index];
        switch (key) {
          case 'Price':
            return product.price.toStringAsFixed(0);
          case 'Rating':
            return product.rating.toStringAsFixed(1);
          case 'Noise (dB)':
            return product.noiseLevelDb?.toString();
          case 'Power (W)':
            return product.powerW?.toString();
          default:
            return product.specs[key];
        }
      });
    }
    return map;
  }

  Product? resolveProduct(String id) {
    return mockProducts.firstWhere((element) => element.id == id);
  }

  void setDifferencesOnly(bool value) {
    differencesOnly.value = value;
  }

  void setHighlightDifferences(bool value) {
    highlightDifferences.value = value;
  }
}
