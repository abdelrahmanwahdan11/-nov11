import 'package:flutter/material.dart';

import '../../app_scope.dart';
import '../../core/utils/context_extensions.dart';
import '../../shared/controllers/cart_controller.dart';
import '../../shared/data/mock_products.dart';
import '../../shared/models/cart_item.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = AppScope.of(context).cartController;
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.getString('cart'))),
      body: ValueListenableBuilder<List<CartItem>>(
        valueListenable: cart.cartNotifier,
        builder: (context, items, _) {
          if (items.isEmpty) {
            return Center(child: Text(l10n.getString('emptyState')));
          }
          return Column(
            children: [
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(24),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final product = mockProducts.firstWhere((p) => p.id == item.productId);
                    return Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        color: Theme.of(context).cardColor,
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.network(product.images.first, width: 80, height: 80, fit: BoxFit.cover),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(product.name, style: context.textTheme.bodyLarge),
                                const SizedBox(height: 8),
                                Text('${product.price.toStringAsFixed(0)}',
                                    style: context.textTheme.labelSmall),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              IconButton(
                                onPressed: () => cart.updateQty(item.productId, item.qty - 1),
                                icon: const Icon(Icons.remove_circle_outline),
                              ),
                              Text(item.qty.toString()),
                              IconButton(
                                onPressed: () => cart.updateQty(item.productId, item.qty + 1),
                                icon: const Icon(Icons.add_circle_outline),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('${l10n.getString('total')}: ${cart.totalPrice().toStringAsFixed(0)}'),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(l10n.getString('proceed'))),
                        );
                      },
                      child: Text(l10n.getString('proceed')),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
