import 'dart:async';

import 'package:flutter/material.dart';

import '../data/mock_products.dart';
import '../models/product.dart';

class ProductController {
  ProductController(String productId) {
    productNotifier = ValueNotifier<Product?>(
      mockProducts.firstWhere((p) => p.id == productId),
    );
    overlayFlipped = ValueNotifier<bool>(false);
  }

  late final ValueNotifier<Product?> productNotifier;
  late final ValueNotifier<bool> overlayFlipped;

  void toggleOverlaySide() {
    overlayFlipped.value = !overlayFlipped.value;
  }
}
