import 'package:cloud_firestore/cloud_firestore.dart' show Timestamp;
import 'package:requirment_gathering_app/user_module/cart/order_model.dart';
import 'package:requirment_gathering_app/user_module/cart/order_model.dart';

class OrderDto {
  final String id;
  final String userId;
  final String userName;
  final List<CartItemDto> items;
  final double totalAmount;
  final String status;
  final DateTime orderDate;
  final DateTime? expectedDeliveryDate;

  OrderDto({
    required this.id,
    required this.userId,
    required this.userName,
    required this.items,
    required this.totalAmount,
    required this.status,
    required this.orderDate,
    this.expectedDeliveryDate,
  });

  factory OrderDto.fromFirestore(Map<String, dynamic> data) {
    return OrderDto(
      id: data['id'],
      userId: data['userId'],
      userName: data['userName'],
      items: (data['items'] as List).map((item) => CartItemDto.fromMap(item)).toList(),
      totalAmount: data['totalAmount'],
      status: data['status'],
      orderDate: (data['orderDate'] as Timestamp).toDate(),
      expectedDeliveryDate: data['expectedDeliveryDate'] != null
          ? (data['expectedDeliveryDate'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'items': items.map((item) => item.toMap()).toList(),
      'totalAmount': totalAmount,
      'status': status,
      'orderDate': Timestamp.fromDate(orderDate),
      'expectedDeliveryDate': expectedDeliveryDate != null
          ? Timestamp.fromDate(expectedDeliveryDate!)
          : null,
    };
  }

  factory OrderDto.fromModel(Order order) {
    return OrderDto(
      id: order.id,
      userId: order.userId,
      userName: order.userName,
      items: order.items.map((item) => CartItemDto.fromModel(item)).toList(),
      totalAmount: order.totalAmount,
      status: order.status,
      orderDate: order.orderDate,
      expectedDeliveryDate: order.expectedDeliveryDate,
    );
  }
}

class CartItemDto {
  final String productId;
  final String productName;
  final double price;
  final int quantity;

  CartItemDto({
    required this.productId,
    required this.productName,
    required this.price,
    required this.quantity,
  });

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      'price': price,
      'quantity': quantity,
    };
  }

  factory CartItemDto.fromMap(Map<String, dynamic> map) {
    return CartItemDto(
      productId: map['productId'],
      productName: map['productName'],
      price: map['price'],
      quantity: map['quantity'],
    );
  }

  factory CartItemDto.fromModel(CartItem item) {
    return CartItemDto(
      productId: item.productId,
      productName: item.productName,
      price: item.price,
      quantity: item.quantity,
    );
  }
}