class Product {
  final String id;
  final String name;
  final double price;
  final int stock;
  final String category;
  final String categoryId;
  final String subcategoryId;
  final String subcategoryName;
  final double tax; // New field for tax percentage

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.stock,
    required this.category,
    required this.categoryId,
    required this.subcategoryId,
    required this.subcategoryName,
    required this.tax,
  });
}