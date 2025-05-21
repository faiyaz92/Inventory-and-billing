import 'package:requirment_gathering_app/company_admin_module/data/inventory/stock_model.dart';

class UserProductDto {
  final String id;
  final String name;
  final double price;
  final double taxRate;
  final double taxAmount;
  final double priceWithTax;

  UserProductDto({
    required this.id,
    required this.name,
    required this.price,
    this.taxRate = 0.05, // Static 5% tax
  })  : taxAmount = price * 0.05,
        priceWithTax = price + (price * 0.05);

  factory UserProductDto.fromStock(StockModel stock) {
    return UserProductDto(
      id: stock.productId,
      name: stock.productId, // Using productId as name for simplicity
      price: 10.0, // Default price as per instructions
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'taxRate': taxRate,
      'taxAmount': taxAmount,
      'priceWithTax': priceWithTax,
    };
  }

  factory UserProductDto.fromMap(Map<String, dynamic> map) {
    return UserProductDto(
      id: map['id'],
      name: map['name'],
      price: map['price'],
      taxRate: map['taxRate'] ?? 0.05,
    );
  }
}