import 'package:flutter/material.dart';

import '../data/mock_products.dart';
import '../models/product.dart';

class FavoritesController {
  FavoritesController() {
    favoritesNotifier = ValueNotifier<List<Product>>([]);
    recentNotifier = ValueNotifier<List<Product>>([]);
  }

  late final ValueNotifier<List<Product>> favoritesNotifier;
  late final ValueNotifier<List<Product>> recentNotifier;

  void toggleFavorite(Product product) {
    final favorites = [...favoritesNotifier.value];
    if (favorites.any((item) => item.id == product.id)) {
      favorites.removeWhere((item) => item.id == product.id);
    } else {
      favorites.add(product);
    }
    favoritesNotifier.value = favorites;
  }

  void addRecent(String productId) {
    final product = mockProducts.firstWhere((element) => element.id == productId);
    final recents = [...recentNotifier.value];
    recents.removeWhere((element) => element.id == productId);
    recents.insert(0, product);
    if (recents.length > 5) {
      recents.removeLast();
    }
    recentNotifier.value = recents;
  }
}
