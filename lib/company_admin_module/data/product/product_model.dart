class Product {
  final String id;
  final String name;
  final double price;
  final int stock;
  final String category;
  final String categoryId; // Added category ID for future reference
  final String subcategoryId; // Added subcategory ID for future reference
  final String subcategoryName; // Added subcategory name

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.stock,
    required this.category,
    required this.categoryId,  // Store category ID
    required this.subcategoryId, // Store subcategory ID
    required this.subcategoryName, // Store subcategory name
  });
}
