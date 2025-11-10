import 'package:flutter/material.dart';

import '../../app_scope.dart';
import '../../core/utils/context_extensions.dart';
import '../../shared/controllers/search_controller.dart';
import '../../shared/models/product.dart';
import '../../shared/widgets/product_card.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late final SearchController _controller;
  final TextEditingController _query = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = SearchController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is String && args.isNotEmpty) {
      _query.text = args;
      _controller.search(args, {});
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _query.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final favorites = AppScope.of(context).favoritesController;
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _query,
          autofocus: true,
          decoration: InputDecoration(
            hintText: l10n.getString('searchPlaceholder'),
            border: InputBorder.none,
          ),
          onSubmitted: (value) => _controller.search(value, {}),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
      body: StreamBuilder<List<Product>>(
        stream: _controller.results,
        builder: (context, snapshot) {
          final results = snapshot.data ?? [];
          if (results.isEmpty) {
            return Center(
              child: Text(l10n.getString('searchPlaceholder')),
            );
          }
          return ValueListenableBuilder<List<Product>>(
            valueListenable: favorites.favoritesNotifier,
            builder: (context, favs, __) {
              return GridView.builder(
                padding: const EdgeInsets.all(24),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.68,
                ),
                itemCount: results.length,
                itemBuilder: (context, index) {
                  final product = results[index];
                  final isFav = favs.any((element) => element.id == product.id);
                  return ProductCard(
                    product: product,
                    isFavorite: isFav,
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
          );
        },
      ),
    );
  }
}
