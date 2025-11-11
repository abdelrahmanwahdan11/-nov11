import 'package:flutter/material.dart';

import '../../app_scope.dart';
import '../../core/utils/context_extensions.dart';
import '../../shared/models/product.dart';
import '../../shared/widgets/product_card.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final favorites = AppScope.of(context).favoritesController;
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.getString('favorites'))),
      body: ValueListenableBuilder<List<Product>>(
        valueListenable: favorites.favoritesNotifier,
        builder: (context, items, _) {
          if (items.isEmpty) {
            return Center(child: Text(l10n.getString('emptyState')));
          }
          return GridView.builder(
            padding: const EdgeInsets.all(24),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.68,
            ),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final product = items[index];
              return ProductCard(
                product: product,
                isFavorite: true,
                onFavorite: () => favorites.toggleFavorite(product),
                onTap: () => Navigator.of(context)
                    .pushNamed('/product', arguments: product.id),
                onCompare: () {
                  AppScope.of(context).compareController.addProduct(product);
                  Navigator.of(context).pushNamed('/compare');
                },
              );
            },
          );
        },
      ),
    );
  }
}
