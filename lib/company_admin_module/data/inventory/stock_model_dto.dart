import 'package:cloud_firestore/cloud_firestore.dart';

class StockDto {
  final String id;
  final String productId;
  final String storeId;
  final int quantity;
  final DateTime lastUpdated;
  final String? name; // Added from Product, nullable
  final double? price; // Added from Product, nullable
  final int? stock; // Added from Product, nullable
  final String? category; // Added from Product, nullable
  final String? categoryId; // Added from Product, nullable
  final String? subcategoryId; // Added from Product, nullable
  final String? subcategoryName; // Added from Product, nullable
  final double? tax; // Added from Product, nullable

  StockDto({
    required this.id,
    required this.productId,
    required this.storeId,
    required this.quantity,
    required this.lastUpdated,
    this.name,
    this.price,
    this.stock,
    this.category,
    this.categoryId,
    this.subcategoryId,
    this.subcategoryName,
    this.tax,
  });

  factory StockDto.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return StockDto(
      id: doc.id,
      productId: data['productId'] ?? '',
      storeId: data['storeId'] ?? '',
      quantity: data['quantity'] ?? 0,
      lastUpdated: DateTime.parse(data['lastUpdated'] ?? DateTime.now().toIso8601String()),
      name: data['name'],
      price: (data['price'] as num?)?.toDouble(),
      stock: data['stock'],
      category: data['category'],
      categoryId: data['categoryId'],
      subcategoryId: data['subcategoryId'],
      subcategoryName: data['subcategoryName'],
      tax: (data['tax'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'productId': productId,
      'storeId': storeId,
      'quantity': quantity,
      'lastUpdated': lastUpdated.toIso8601String(),
      'name': name,
      'price': price,
      'stock': stock,
      'category': category,
      'categoryId': categoryId,
      'subcategoryId': subcategoryId,
      'subcategoryName': subcategoryName,
      'tax': tax,
    };
  }
}