import 'package:flutter/material.dart';

import '../../app_scope.dart';
import '../../core/utils/context_extensions.dart';
import '../../shared/controllers/favorites_controller.dart';
import '../../shared/controllers/overlay_card_controller.dart';
import '../../shared/controllers/product_controller.dart';
import '../../shared/models/product.dart';
import '../../shared/models/product_callout.dart';
import '../../shared/widgets/callout_tag.dart';
import '../../shared/widgets/feature_tag.dart';
import '../../shared/widgets/image_360_preview.dart';
import '../../shared/widgets/overlay_image_card.dart';
import '../../shared/widgets/smart_network_image.dart';
import '../../shared/widgets/sticky_cta.dart';

class ProductDetailPage extends StatefulWidget {
  const ProductDetailPage({super.key, required this.productId});

  final String productId;

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  late final ProductController _controller;
  late final OverlayCardController _overlayController;

  @override
  void initState() {
    super.initState();
    _controller = ProductController(widget.productId);
    _overlayController = OverlayCardController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AppScope.of(context).favoritesController.addRecent(widget.productId);
    });
  }

  @override
  void dispose() {
    _controller.productNotifier.dispose();
    _overlayController.isVisible.dispose();
    _overlayController.isFlipped.dispose();
    _controller.callouts.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final favorites = AppScope.of(context).favoritesController;
    final cart = AppScope.of(context).cartController;
    final compare = AppScope.of(context).compareController;
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.getString('overview')),
      ),
      body: ValueListenableBuilder<Product?>(
        valueListenable: _controller.productNotifier,
        builder: (context, product, _) {
          if (product == null) {
            return const SizedBox();
          }
          final isFav = favorites.favoritesNotifier.value
              .any((element) => element.id == product.id);
          return Stack(
            children: [
              ListView(
                padding: const EdgeInsets.only(bottom: 120),
                children: [
                  Hero(
                    tag: 'product_${product.id}',
                    child: GestureDetector(
                      onTap: () => _overlayController.show(),
                      child: AspectRatio(
                        aspectRatio: 3 / 4,
                        child: ClipRRect(
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(48),
                            bottomRight: Radius.circular(48),
                          ),
                          child: ValueListenableBuilder<List<ProductCallout>>(
                            valueListenable: _controller.callouts,
                            builder: (context, callouts, _) {
                              return Stack(
                                fit: StackFit.expand,
                                children: [
                                  SmartNetworkImage(
                                    imageUrl: product.images.first,
                                    fit: BoxFit.cover,
                                  ),
                                  ...callouts.map((callout) => _buildCallout(context, callout)).toList(),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(product.brand.toUpperCase(),
                            style: context.textTheme.labelSmall?.copyWith(letterSpacing: 1.2)),
                        const SizedBox(height: 8),
                        Text(product.name, style: context.textTheme.headlineLarge),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: product.tags.map((tag) => FeatureTag(label: tag)).toList(),
                        ),
                        const SizedBox(height: 24),
                        Text(l10n.getString('specifications'), style: context.textTheme.headlineMedium),
                        const SizedBox(height: 12),
                        ...product.specs.entries.map(
                          (entry) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              children: [
                                Expanded(child: Text(entry.key)),
                                Text(entry.value, style: context.textTheme.bodyLarge),
                              ],
                            ),
                          ),
                        ),
                        if (product.frames360 != null) ...[
                          const SizedBox(height: 32),
                          Text(l10n.getString('preview360'), style: context.textTheme.headlineMedium),
                          const SizedBox(height: 12),
                          Image360Preview(frames: product.frames360!),
                        ],
                        const SizedBox(height: 48),
                      ],
                    ),
                  ),
                ],
              ),
              ValueListenableBuilder<bool>(
                valueListenable: _overlayController.isVisible,
                builder: (context, visible, _) {
                  if (!visible) return const SizedBox.shrink();
                  return ValueListenableBuilder<bool>(
                    valueListenable: _overlayController.isFlipped,
                    builder: (context, flipped, __) {
                      return OverlayImageCard(
                        image: product.images.first,
                        summary: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(product.name,
                                style: context.textTheme.headlineMedium?.copyWith(color: Colors.white)),
                            const SizedBox(height: 8),
                            Text(product.brand, style: const TextStyle(color: Colors.white70)),
                          ],
                        ),
                        details: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(l10n.getString('overview'), style: context.textTheme.headlineMedium),
                            const SizedBox(height: 12),
                            Text(l10n.getString('overlayDetail')),
                          ],
                        ),
                        onClose: _overlayController.hide,
                        flipped: flipped,
                        onFlip: _overlayController.flip,
                      );
                    },
                  );
                },
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: StickyCTA(
        children: [
          ValueListenableBuilder(
            valueListenable: favorites.favoritesNotifier,
            builder: (context, _, __) {
              final isFav = isCurrentFavorite(favorites, widget.productId);
              return IconButton(
                onPressed: () {
                  final product = _controller.productNotifier.value;
                  if (product != null) {
                    favorites.toggleFavorite(product);
                  }
                },
                icon: Icon(isFav ? Icons.favorite : Icons.favorite_border),
              );
            },
          ),
          ElevatedButton(
            onPressed: () {
              final product = _controller.productNotifier.value;
              if (product != null) {
                compare.addProduct(product);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.getString('compare'))),
                );
              }
            },
            child: Text(l10n.getString('addToCompare')),
          ),
          ElevatedButton(
            onPressed: () {
              final product = _controller.productNotifier.value;
              if (product != null) {
                cart.add(product);
              }
            },
            child: Text(l10n.getString('addToCart')),
          ),
          ElevatedButton(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                ),
                builder: (context) => Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.getString('aiInfo'), style: context.textTheme.headlineMedium),
                      const SizedBox(height: 12),
                      Text(l10n.getString('aiInfoSoon')),
                      const SizedBox(height: 12),
                      const Text('TODO: Integrate AI insights here.'),
                    ],
                  ),
                ),
              );
            },
            child: Text(l10n.getString('aiInfo')),
          ),
        ],
      ),
    );
  }

  bool isCurrentFavorite(FavoritesController favoritesController, String id) {
    return favoritesController.favoritesNotifier.value.any((element) => element.id == id);
  }

  Widget _buildCallout(BuildContext context, ProductCallout callout) {
    final label = context.l10n.getString(callout.labelKey);
    final tag = CalloutTag(
      label: label,
      onTap: () => _showCalloutDetails(callout),
    );
    if (callout.centerX) {
      return Positioned(
        left: 0,
        right: 0,
        bottom: callout.bottom ?? 32,
        child: Center(child: tag),
      );
    }
    return Positioned(
      top: callout.top,
      left: callout.left,
      right: callout.right,
      bottom: callout.bottom,
      child: tag,
    );
  }

  void _showCalloutDetails(ProductCallout callout) {
    final l10n = context.l10n;
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.getString(callout.labelKey),
                style: context.textTheme.headlineMedium,
              ),
              const SizedBox(height: 12),
              Text(
                l10n.getString(callout.descriptionKey),
                style: context.textTheme.bodyLarge,
              ),
            ],
          ),
        );
      },
    );
  }
}
