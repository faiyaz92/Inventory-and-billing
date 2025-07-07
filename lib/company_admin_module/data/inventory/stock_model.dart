import 'package:requirment_gathering_app/company_admin_module/data/inventory/stock_model_dto.dart';

class StockModel {
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

  StockModel({
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

  factory StockModel.fromDto(StockDto dto) {
    return StockModel(
      id: dto.id,
      productId: dto.productId,
      storeId: dto.storeId,
      quantity: dto.quantity,
      lastUpdated: dto.lastUpdated,
      name: dto.name,
      price: dto.price,
      stock: dto.stock,
      category: dto.category,
      categoryId: dto.categoryId,
      subcategoryId: dto.subcategoryId,
      subcategoryName: dto.subcategoryName,
      tax: dto.tax,
    );
  }

  StockDto toDto() {
    return StockDto(
      id: id,
      productId: productId,
      storeId: storeId,
      quantity: quantity,
      lastUpdated: lastUpdated,
      name: name,
      price: price,
      stock: stock,
      category: category,
      categoryId: categoryId,
      subcategoryId: subcategoryId,
      subcategoryName: subcategoryName,
      tax: tax,
    );
  }

  StockModel copyWith({
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
    return StockModel(
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