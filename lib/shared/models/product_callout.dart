class ProductCallout {
  const ProductCallout({
    required this.labelKey,
    required this.descriptionKey,
    this.top,
    this.left,
    this.right,
    this.bottom,
    this.centerX = false,
  });

  final String labelKey;
  final String descriptionKey;
  final double? top;
  final double? left;
  final double? right;
  final double? bottom;
  final bool centerX;
}
