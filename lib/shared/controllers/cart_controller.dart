import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/mock_products.dart';
import '../models/cart_item.dart';
import '../models/product.dart';

class CartController {
  CartController() {
    cartNotifier = ValueNotifier<List<CartItem>>([]);
    warrantyNotifier = ValueNotifier<bool>(false);
  }

  late final ValueNotifier<List<CartItem>> cartNotifier;
  late final ValueNotifier<bool> warrantyNotifier;

  static const double _warrantyFee = 59;

  SharedPreferences? _prefs;

  Future<void> loadPrefs() async {
    final prefs = await _ensurePrefs();
    warrantyNotifier.value = prefs.getBool('cartWarranty') ?? false;
  }

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

  Future<void> setWarranty(bool value) async {
    warrantyNotifier.value = value;
    final prefs = await _ensurePrefs();
    await prefs.setBool('cartWarranty', value);
  }

  double subtotal() {
    var total = 0.0;
    for (final item in cartNotifier.value) {
      final product = mockProducts.firstWhere((p) => p.id == item.productId);
      total += product.price * item.qty;
    }
    return total;
  }

  double protectionFee() {
    return warrantyNotifier.value ? _warrantyFee : 0;
  }

  double warrantyPrice() => _warrantyFee.toDouble();

  double totalPrice() {
    return subtotal() + protectionFee();
  }

  Future<SharedPreferences> _ensurePrefs() async {
    if (_prefs != null) {
      return _prefs!;
    }
    _prefs = await SharedPreferences.getInstance();
    return _prefs!;
  }
}
