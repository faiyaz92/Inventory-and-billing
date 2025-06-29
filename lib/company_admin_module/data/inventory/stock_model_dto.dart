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

  StockDto copyWith({
    String? id,
    String? productId,
    String? storeId,
    int? quantity,
    DateTime? lastUpdated,
    String? name,
    double? price,
    int? stock,
    String? category,
    String? categoryId,
    String? subcategoryId,
    String? subcategoryName,
    double? tax,
  }) {
    return StockDto(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      storeId: storeId ?? this.storeId,
      quantity: quantity ?? this.quantity,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      name: name ?? this.name,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      category: category ?? this.category,
      categoryId: categoryId ?? this.categoryId,
      subcategoryId: subcategoryId ?? this.subcategoryId,
      subcategoryName: subcategoryName ?? this.subcategoryName,
      tax: tax ?? this.tax,
    );
  }
}