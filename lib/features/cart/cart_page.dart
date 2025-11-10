import 'package:flutter/material.dart';

import '../../app_scope.dart';
import '../../core/utils/context_extensions.dart';
import '../../shared/controllers/cart_controller.dart';
import '../../shared/data/mock_products.dart';
import '../../shared/models/cart_item.dart';
import '../../shared/widgets/smart_network_image.dart';

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
          return ValueListenableBuilder<bool>(
            valueListenable: cart.warrantyNotifier,
            builder: (context, warrantySelected, __) {
              final currency = l10n.getString('currencySymbol');
              final subtotal = cart.subtotal();
              final protection = cart.protectionFee();
              final total = cart.totalPrice();

              Row buildSummary(String label, double value,
                  {bool emphasize = false}) {
                final style = emphasize
                    ? context.textTheme.headlineSmall
                    : context.textTheme.bodyLarge;
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(label, style: style),
                    Text('$currency${value.toStringAsFixed(0)}', style: style),
                  ],
                );
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
                        final product = mockProducts
                            .firstWhere((p) => p.id == item.productId);
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
                                child: SizedBox(
                                  width: 80,
                                  height: 80,
                                  child: SmartNetworkImage(
                                    imageUrl: product.images.first,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(product.name,
                                        style: context.textTheme.bodyLarge),
                                    const SizedBox(height: 8),
                                    Text(
                                      '$currency${product.price.toStringAsFixed(0)}',
                                      style: context.textTheme.labelSmall,
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    onPressed: () => cart.updateQty(
                                      item.productId,
                                      item.qty - 1,
                                    ),
                                    icon:
                                        const Icon(Icons.remove_circle_outline),
                                  ),
                                  Text(item.qty.toString()),
                                  IconButton(
                                    onPressed: () => cart.updateQty(
                                      item.productId,
                                      item.qty + 1,
                                    ),
                                    icon: const Icon(Icons.add_circle_outline),
                                  ),
                                  IconButton(
                                    onPressed: () => cart.remove(item.productId),
                                    icon: const Icon(Icons.delete_outline),
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
                        SwitchListTile.adaptive(
                          value: warrantySelected,
                          onChanged: (value) {
                            cart.setWarranty(value);
                          },
                          title: Text(l10n.getString('extendedWarranty')),
                          subtitle: Text(
                            l10n
                                .getString('extendedWarrantyHint')
                                .replaceFirst(
                                  '{amount}',
                                  '$currency${cart.warrantyPrice().toStringAsFixed(0)}',
                                ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        buildSummary(l10n.getString('subtotal'), subtotal),
                        if (protection > 0)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: buildSummary(
                              l10n.getString('protectionPlan'),
                              protection,
                            ),
                          ),
                        const SizedBox(height: 12),
                        const Divider(),
                        const SizedBox(height: 12),
                        buildSummary(
                          l10n.getString('total'),
                          total,
                          emphasize: true,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(l10n.getString('proceed')),
                              ),
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
          );
        },
      ),
    );
  }
}
