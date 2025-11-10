class Product {
  Product({
    required this.id,
    required this.name,
    required this.brand,
    required this.images,
    this.frames360,
    required this.price,
    required this.rating,
    required this.tags,
    required this.specs,
    this.noiseLevelDb,
    this.powerW,
    this.hepaClass,
  });

  final String id;
  final String name;
  final String brand;
  final List<String> images;
  final List<String>? frames360;
  final double price;
  final double rating;
  final List<String> tags;
  final Map<String, String> specs;
  final int? noiseLevelDb;
  final int? powerW;
  final String? hepaClass;
}
