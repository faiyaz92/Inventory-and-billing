import 'package:requirment_gathering_app/user_module/cart/data/order_dto.dart';
import 'package:requirment_gathering_app/user_module/cart/data/order_model.dart';

class CartDto {
  final String userId;
  final List<CartItemDto> items;

  CartDto({
    required this.userId,
    required this.items,
  });

  factory CartDto.fromMap(Map<String, dynamic> map) {
    return CartDto(
      userId: map['userId'] ?? '',
      items: (map['items'] as List<dynamic>? ?? [])
          .map((item) => CartItemDto.fromMap(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'items': items.map((item) => item.toMap()).toList(),
    };
  }

  List<CartItem> toModel() {
    return items.map((dto) => dto.toModel()).toList();
  }
}
