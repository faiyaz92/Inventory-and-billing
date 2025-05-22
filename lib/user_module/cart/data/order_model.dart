import 'package:requirment_gathering_app/user_module/cart/data/order_dto.dart';

class Order {
  final String id;
  final String userId; // customer id
  final String userName;
  final List<CartItem> items;
  final double totalAmount;
  final String status;
  final DateTime orderDate;
  final DateTime? expectedDeliveryDate;
  final DateTime? orderDeliveryDate;
  final String? orderTakenBy;
  final String? orderDeliveredBy;
  final String? responsibleForDelivery;
  final String? lastUpdatedBy; // Added for last updated by

  Order({
    required this.id,
    required this.userId,
    required this.userName,
    required this.items,
    required this.totalAmount,
    required this.status,
    required this.orderDate,
    this.expectedDeliveryDate,
    this.orderDeliveryDate,
    this.orderTakenBy,
    this.orderDeliveredBy,
    this.responsibleForDelivery,
    this.lastUpdatedBy,
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
      orderDeliveryDate: dto.orderDeliveryDate,
      orderTakenBy: dto.orderTakenBy,
      orderDeliveredBy: dto.orderDeliveredBy,
      responsibleForDelivery: dto.responsibleForDelivery,
      lastUpdatedBy: dto.lastUpdatedBy,
    );
  }
}

class CartItem {
  final String productId;
  final String productName;
  final double price;
  final int quantity;
  final double taxRate;
  final double taxAmount;

  CartItem({
    required this.productId,
    required this.productName,
    required this.price,
    required this.quantity,
    required this.taxRate,
    required this.taxAmount,
  });

  factory CartItem.fromDto(CartItemDto dto) {
    return CartItem(
      productId: dto.productId,
      productName: dto.productName,
      price: dto.price,
      quantity: dto.quantity,
      taxRate: dto.taxRate,
      taxAmount: dto.taxAmount,
    );
  }
}
