import 'dart:async';

import 'package:flutter/material.dart';

import '../data/mock_products.dart';
import '../models/product.dart';
import '../models/product_callout.dart';

class ProductController {
  ProductController(String productId) {
    productNotifier = ValueNotifier<Product?>(
      mockProducts.firstWhere((p) => p.id == productId),
    );
    overlayFlipped = ValueNotifier<bool>(false);
    callouts = ValueNotifier<List<ProductCallout>>(
      List<ProductCallout>.from(_calloutMap[productId] ?? _defaultCallouts),
    );
  }

  late final ValueNotifier<Product?> productNotifier;
  late final ValueNotifier<bool> overlayFlipped;
  late final ValueNotifier<List<ProductCallout>> callouts;

  void toggleOverlaySide() {
    overlayFlipped.value = !overlayFlipped.value;
  }

  static const List<ProductCallout> _defaultCallouts = [
    ProductCallout(
      labelKey: 'calloutFilter',
      descriptionKey: 'calloutFilterDesc',
      top: 120,
      left: 24,
    ),
    ProductCallout(
      labelKey: 'calloutHepa',
      descriptionKey: 'calloutHepaDesc',
      top: 220,
      right: 24,
    ),
    ProductCallout(
      labelKey: 'calloutOscillation',
      descriptionKey: 'calloutOscillationDesc',
      bottom: 40,
      centerX: true,
    ),
  ];

  static final Map<String, List<ProductCallout>> _calloutMap = {
    for (final product in mockProducts) product.id: _defaultCallouts,
  };
}
