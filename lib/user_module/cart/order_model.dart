import 'package:requirment_gathering_app/user_module/cart/order_dto.dart';

class Order {
  final String id;
  final String userId;
  final String userName;
  final List<CartItem> items;
  final double totalAmount;
  final String status;
  final DateTime orderDate;
  final DateTime? expectedDeliveryDate;

  Order({
    required this.id,
    required this.userId,
    required this.userName,
    required this.items,
    required this.totalAmount,
    required this.status,
    required this.orderDate,
    this.expectedDeliveryDate,
  });

  factory Order.fromDto(OrderDto dto) {
    return Order(
      id: dto.id,
      userId: dto.userId,
      userName: dto.userName,
      items: dto.items.map((itemDto) => CartItem.fromDto(itemDto)).toList(),
      totalAmount: dto.totalAmount,
      status: dto.status,
      orderDate: dto.orderDate,
      expectedDeliveryDate: dto.expectedDeliveryDate,
    );
  }
}

class CartItem {
  final String productId;
  final String productName;
  final double price;
  final int quantity;

  CartItem({
    required this.productId,
    required this.productName,
    required this.price,
    required this.quantity,
  });

  factory CartItem.fromDto(CartItemDto dto) {
    return CartItem(
      productId: dto.productId,
      productName: dto.productName,
      price: dto.price,
      quantity: dto.quantity,
    );
  }
}