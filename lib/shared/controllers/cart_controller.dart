import 'package:flutter/material.dart';

import '../data/mock_products.dart';
import '../models/cart_item.dart';
import '../models/product.dart';

class CartController {
  CartController() {
    cartNotifier = ValueNotifier<List<CartItem>>([]);
  }

  late final ValueNotifier<List<CartItem>> cartNotifier;

  void add(Product product) {
    final items = [...cartNotifier.value];
    final index = items.indexWhere((item) => item.productId == product.id);
    if (index >= 0) {
      items[index].qty += 1;
    } else {
      items.add(CartItem(productId: product.id));
    }
    cartNotifier.value = items;
  }

  void remove(String productId) {
    final items = [...cartNotifier.value];
    items.removeWhere((item) => item.productId == productId);
    cartNotifier.value = items;
  }

  void updateQty(String productId, int qty) {
    final items = [...cartNotifier.value];
    final index = items.indexWhere((item) => item.productId == productId);
    if (index >= 0) {
      items[index].qty = qty.clamp(1, 99).toInt();
    }
    cartNotifier.value = items;
  }

  double totalPrice() {
    var total = 0.0;
    for (final item in cartNotifier.value) {
      final product = mockProducts.firstWhere((p) => p.id == item.productId);
      total += product.price * item.qty;
    }
    return total;
  }
}
