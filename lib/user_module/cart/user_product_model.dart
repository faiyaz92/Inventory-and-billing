import 'package:requirment_gathering_app/user_module/cart/user_product_dto.dart';

class UserProduct {
  final String id;
  final String name;
  final double price;

  UserProduct({
    required this.id,
    required this.name,
    required this.price,
  });

  factory UserProduct.fromDto(UserProductDto dto) {
    return UserProduct(
      id: dto.id,
      name: dto.name,
      price: dto.price,
    );
  }
}