import 'package:requirment_gathering_app/company_admin_module/data/inventory/stock_model.dart';

class UserProductDto {
  final String id;
  final String name;
  final double price;

  UserProductDto({
    required this.id,
    required this.name,
    required this.price,
  });

  factory UserProductDto.fromStock(StockModel stock) {
    return UserProductDto(
      id: stock.productId,
      name: stock.productId, // Using productId as name for simplicity
      price: 10.0, // Default price as per instructions
    );
  }
}