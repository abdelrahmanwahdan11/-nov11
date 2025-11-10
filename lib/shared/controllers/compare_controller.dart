import 'package:flutter/material.dart';

import '../data/mock_products.dart';
import '../models/product.dart';

class CompareController {
  CompareController() {
    compareNotifier = ValueNotifier<List<Product>>([]);
  }

  late final ValueNotifier<List<Product>> compareNotifier;

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
  }

  Map<String, List<String?>> get comparisonMatrix {
    final map = <String, List<String?>>{};
    final items = compareNotifier.value;
    for (final product in items) {
      map['Price'] = [...(map['Price'] ?? []), '${product.price}'];
      map['Rating'] = [...(map['Rating'] ?? []), '${product.rating}'];
      map['Noise (dB)'] = [...(map['Noise (dB)'] ?? []), product.noiseLevelDb?.toString()];
      map['Power (W)'] = [...(map['Power (W)'] ?? []), product.powerW?.toString()];
      product.specs.forEach((key, value) {
        map[key] = [...(map[key] ?? []), value];
      });
    }
    return map;
  }

  Product? resolveProduct(String id) {
    return mockProducts.firstWhere((element) => element.id == id);
  }
}
