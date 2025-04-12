import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:requirment_gathering_app/company_admin_module/data/product/product_model.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:requirment_gathering_app/company_admin_module/data/product/product_model.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:requirment_gathering_app/company_admin_module/data/product/product_model.dart';

class ProductDTO {
  final String? id; // Nullable ID
  final String? name; // Nullable Name
  final double? price; // Nullable Price
  final int? stock; // Nullable Stock
  final String? category; // Nullable Category
  final String? categoryId; // Nullable Category ID
  final String? subcategoryId; // Nullable Subcategory ID
  final String? subcategoryName; // Nullable Subcategory Name

  ProductDTO({
    this.id,
    this.name,
    this.price,
    this.stock,
    this.category,
    this.categoryId,
    this.subcategoryId,
    this.subcategoryName,
  });

  // Convert Firestore DocumentSnapshot to ProductDTO
  factory ProductDTO.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ProductDTO(
      id: doc.id,
      name: data['name'],
      price: (data['price'] as num?)?.toDouble(), // Nullable price
      stock: data['stock'],
      category: data['category'],
      categoryId: data['categoryId'],
      subcategoryId: data['subcategoryId'],
      subcategoryName: data['subcategoryName'],
    );
  }

  // Convert ProductDTO to Firestore Map
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'price': price,
      'stock': stock,
      'category': category,
      'categoryId': categoryId,
      'subcategoryId': subcategoryId,
      'subcategoryName': subcategoryName,
    };
  }

  // Convert ProductDTO to Product (for UI use)
  Product toDomainModel() {
    return Product(
      id: id ?? '', // Provide default empty string if null
      name: name ?? '', // Provide default empty string if null
      price: price ?? 0.0, // Provide default value if null
      stock: stock ?? 0, // Provide default value if null
      category: category ?? '', // Provide default empty string if null
      categoryId: categoryId ?? '', // Provide default empty string if null
      subcategoryId: subcategoryId ?? '', // Provide default empty string if null
      subcategoryName: subcategoryName ?? '', // Provide default empty string if null
    );
  }

  // Convert Product (UI model) to ProductDTO (for Firestore)
  static ProductDTO fromDomainModel(Product product) {
    return ProductDTO(
      id: product.id,
      name: product.name,
      price: product.price,
      stock: product.stock,
      category: product.category,
      categoryId: product.categoryId,
      subcategoryId: product.subcategoryId,
      subcategoryName: product.subcategoryName,
    );
  }
}
