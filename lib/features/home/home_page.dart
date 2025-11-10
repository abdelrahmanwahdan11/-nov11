import 'package:flutter/material.dart';

import '../../app_scope.dart';
import '../../core/utils/context_extensions.dart';
import '../../shared/controllers/catalog_controller.dart';
import '../../shared/controllers/favorites_controller.dart';
import '../../shared/data/mock_products.dart';
import '../../shared/models/product.dart';
import '../../shared/widgets/chip_filter.dart';
import '../../shared/widgets/product_card.dart';
import '../../shared/widgets/skeleton_box.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final ScrollController _scrollController;
  String _selectedCategory = 'all';

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()
      ..addListener(() {
        if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200) {
          AppScope.of(context).catalogController.loadMore();
        }
      });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scope = AppScope.of(context);
    final catalog = scope.catalogController;
    final favorites = scope.favoritesController;
    final categories = {
      'all': l10n.getString('catalog'),
      'fan': l10n.getString('fans'),
      'heater': l10n.getString('heaters'),
      'purifier': l10n.getString('purifiers'),
    };

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.getString('home')),
        actions: [
          IconButton(
            onPressed: () => Navigator.of(context).pushNamed('/search'),
            icon: const Icon(Icons.search),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pushNamed('/notifications'),
            icon: const Icon(Icons.notifications),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: catalog.refresh,
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.getString('discoverDevices'),
                      style: context.textTheme.headlineLarge,
                    ),
                    const SizedBox(height: 24),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: categories.entries.map((entry) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: ChipFilter(
                              label: entry.value,
                              selected: _selectedCategory == entry.key,
                              onSelected: (_) => setState(() {
                                _selectedCategory = entry.key;
                              }),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 220,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index) {
                          final product = mockProducts[index % mockProducts.length];
                          return Container(
                            width: 260,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(28),
                              image: DecorationImage(
                                image: NetworkImage(product.images.first),
                                fit: BoxFit.cover,
                              ),
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(28),
                                gradient: LinearGradient(
                                  colors: [Colors.black.withOpacity(0.6), Colors.transparent],
                                  begin: Alignment.bottomLeft,
                                  end: Alignment.topRight,
                                ),
                              ),
                              padding: const EdgeInsets.all(20),
                              child: Align(
                                alignment: Alignment.bottomLeft,
                                child: Text(
                                  product.name,
                                  style:
                                      context.textTheme.headlineMedium?.copyWith(color: Colors.white),
                                ),
                              ),
                            ),
                          );
                        },
                        separatorBuilder: (_, __) => const SizedBox(width: 16),
                        itemCount: mockProducts.length,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          l10n.getString('recommended'),
                          style: context.textTheme.headlineMedium,
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pushNamed('/catalog'),
                          child: Text(l10n.getString('viewAll')),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ValueListenableBuilder<List<Product>>(
                      valueListenable: favorites.recentNotifier,
                      builder: (context, recents, _) {
                        if (recents.isEmpty) {
                          return const SizedBox.shrink();
                        }
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.getString('recentlyViewed'),
                              style: context.textTheme.bodyLarge,
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              height: 140,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemBuilder: (context, index) {
                                  final item = recents[index];
                                  return GestureDetector(
                                    onTap: () => Navigator.of(context)
                                        .pushNamed('/product', arguments: item.id),
                                    child: Container(
                                      width: 140,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(24),
                                        image: DecorationImage(
                                          image: NetworkImage(item.images.first),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                                separatorBuilder: (_, __) => const SizedBox(width: 12),
                                itemCount: recents.length,
                              ),
                            ),
                            const SizedBox(height: 24),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            ValueListenableBuilder<List<Product>>(
              valueListenable: catalog.productsNotifier,
              builder: (context, products, _) {
                if (products.isEmpty) {
                  return SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    sliver: SliverGrid(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => const SkeletonBox(width: double.infinity, height: 220),
                        childCount: 4,
                      ),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 0.68,
                      ),
                    ),
                  );
                }
                final filtered = _selectedCategory == 'all'
                    ? products
                    : products.where((element) => element.tags.join(' ').toLowerCase().contains(_selectedCategory)).toList();
                return ValueListenableBuilder<List<Product>>(
                  valueListenable: favorites.favoritesNotifier,
                  builder: (context, favs, __) {
                    return SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      sliver: SliverGrid(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            if (index >= filtered.length) {
                              return const SkeletonBox(width: double.infinity, height: 220);
                            }
                            final product = filtered[index];
                            final isFav = favs.any((element) => element.id == product.id);
                            return ProductCard(
                              product: product,
                              isFavorite: isFav,
                              onTap: () {
                                favorites.addRecent(product.id);
                                Navigator.of(context).pushNamed('/product', arguments: product.id);
                              },
                              onCompare: () {
                                AppScope.of(context).compareController.addProduct(product);
                                Navigator.of(context).pushNamed('/compare');
                              },
                              onFavorite: () {
                                favorites.toggleFavorite(product);
                              },
                            );
                          },
                          childCount: filtered.length,
                        ),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          childAspectRatio: 0.68,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        onTap: (index) {
          switch (index) {
            case 1:
              Navigator.of(context).pushNamed('/catalog');
              break;
            case 2:
              Navigator.of(context).pushNamed('/favorites');
              break;
            case 3:
              Navigator.of(context).pushNamed('/cart');
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.grid_view), label: 'Catalog'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Favorites'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_bag), label: 'Cart'),
        ],
      ),
    );
  }
}
