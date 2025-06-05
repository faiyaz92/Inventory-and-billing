import 'package:requirment_gathering_app/user_module/cart/data/user_product_dto.dart';

class UserProduct {
  final String id;
  final String name;
  final double price;
  final double taxRate;
  final double taxAmount;
  final double priceWithTax;

  UserProduct({
    required this.id,
    required this.name,
    required this.price,
    required this.taxRate,
    required this.taxAmount,
    required this.priceWithTax,
  });

  factory UserProduct.fromDto(UserProductDto dto) {
    return UserProduct(
      id: dto.id,
      name: dto.name,
      price: dto.price,
      taxRate: dto.taxRate,
      taxAmount: dto.taxAmount,
      priceWithTax: dto.priceWithTax,
    );
  }
}