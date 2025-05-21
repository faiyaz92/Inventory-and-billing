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

// class CartItemDto {
//   final String productId;
//   final String productName;
//   final double price;
//   final int quantity;
//   final double taxRate;
//   final double taxAmount;
//
//   CartItemDto({
//     required this.productId,
//     required this.productName,
//     required this.price,
//     required this.quantity,
//     required this.taxRate,
//     required this.taxAmount,
//   });
//
//   factory CartItemDto.fromModel(CartItem item) {
//     return CartItemDto(
//       productId: item.productId,
//       productName: item.productName,
//       price: item.price,
//       quantity: item.quantity,
//       taxRate: item.taxRate,
//       taxAmount: item.taxAmount,
//     );
//   }
//
//   factory CartItemDto.fromMap(Map<String, dynamic> map) {
//     return CartItemDto(
//       productId: map['productId'] ?? '',
//       productName: map['productName'] ?? '',
//       price: (map['price'] as num?)?.toDouble() ?? 0.0,
//       quantity: map['quantity'] ?? 0,
//       taxRate: (map['taxRate'] as num?)?.toDouble() ?? 0.0,
//       taxAmount: (map['taxAmount'] as num?)?.toDouble() ?? 0.0,
//     );
//   }
//
//   Map<String, dynamic> toMap() {
//     return {
//       'productId': productId,
//       'productName': productName,
//       'price': price,
//       'quantity': quantity,
//       'taxRate': taxRate,
//       'taxAmount': taxAmount,
//     };
//   }
//
//   CartItem toModel() {
//     return CartItem(
//       productId: productId,
//       productName: productName,
//       price: price,
//       quantity: quantity,
//       taxRate: taxRate,
//       taxAmount: taxAmount,
//     );
//   }
// }