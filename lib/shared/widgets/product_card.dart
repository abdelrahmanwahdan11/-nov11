import 'package:flutter/material.dart';

import '../../core/utils/context_extensions.dart';
import '../models/product.dart';
import 'feature_tag.dart';
import 'rating_stars.dart';
import 'smart_network_image.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.product,
    this.onTap,
    this.onCompare,
    this.onFavorite,
    this.isFavorite = false,
  });

  final Product product;
  final VoidCallback? onTap;
  final VoidCallback? onCompare;
  final VoidCallback? onFavorite;
  final bool isFavorite;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currency = context.l10n.getString('currencySymbol');
    return GestureDetector(
      onTap: onTap,
      child: Hero(
        tag: 'product_${product.id}',
        child: Container(
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                child: AspectRatio(
                  aspectRatio: 3 / 4,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      SmartNetworkImage(imageUrl: product.images.first),
                      Positioned(
                        top: 16,
                        right: 16,
                        child: IconButton(
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.black54,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: onFavorite,
                          icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.brand.toUpperCase(),
                      style: context.textTheme.labelSmall?.copyWith(
                        letterSpacing: 1.2,
                        color: context.textTheme.labelSmall?.color?.withOpacity(0.8),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      product.name,
                      style: context.textTheme.headlineMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          '$currency${product.price.toStringAsFixed(0)}',
                          style: context.textTheme.headlineMedium,
                        ),
                        RatingStars(value: product.rating),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: product.tags
                          .take(3)
                          .map((tag) => FeatureTag(label: tag))
                          .toList(),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        TextButton(
                          onPressed: onCompare,
                          child: Text(context.l10n.getString('compare')),
                        ),
                        const Spacer(),
                        Icon(
                          Icons.arrow_forward,
                          size: 20,
                          color: theme.iconTheme.color,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
