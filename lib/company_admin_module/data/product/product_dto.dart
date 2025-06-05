import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:requirment_gathering_app/company_admin_module/data/product/product_model.dart';

class ProductDTO {
  final String? id;
  final String? name;
  final double? price;
  final int? stock;
  final String? category;
  final String? categoryId;
  final String? subcategoryId;
  final String? subcategoryName;
  final double? tax; // New field for tax

  ProductDTO({
    this.id,
    this.name,
    this.price,
    this.stock,
    this.category,
    this.categoryId,
    this.subcategoryId,
    this.subcategoryName,
    this.tax,
  });

  factory ProductDTO.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ProductDTO(
      id: doc.id,
      name: data['name'],
      price: (data['price'] as num?)?.toDouble(),
      stock: data['stock'],
      category: data['category'],
      categoryId: data['categoryId'],
      subcategoryId: data['subcategoryId'],
      subcategoryName: data['subcategoryName'],
      tax: (data['tax'] as num?)?.toDouble(), // Handle tax from Firestore
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'price': price,
      'stock': stock,
      'category': category,
      'categoryId': categoryId,
      'subcategoryId': subcategoryId,
      'subcategoryName': subcategoryName,
      'tax': tax, // Include tax in Firestore
    };
  }

  Product toDomainModel() {
    return Product(
      id: id ?? '',
      name: name ?? '',
      price: price ?? 0.0,
      stock: stock ?? 0,
      category: category ?? '',
      categoryId: categoryId ?? '',
      subcategoryId: subcategoryId ?? '',
      subcategoryName: subcategoryName ?? '',
      tax: tax ?? 0.0, // Default to 0.0 if null
    );
  }

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
      tax: product.tax, // Include tax
    );
  }
}