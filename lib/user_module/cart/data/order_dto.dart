import 'package:cloud_firestore/cloud_firestore.dart' show Timestamp;
import 'package:requirment_gathering_app/user_module/cart/data/order_model.dart';

class OrderDto {
  final String id;
  final String userId;
  final String userName;
  final List<CartItemDto> items;
  final double totalAmount;
  final String status;
  final DateTime orderDate;
  final DateTime? expectedDeliveryDate;
  final DateTime? orderDeliveryDate;
  final String? orderTakenBy;
  final String? orderDeliveredBy;
  final String? responsibleForDelivery;
  final String? lastUpdatedBy; // Added for last updated by
  final String? storeId; // New field

  OrderDto({
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
     this.storeId, // New field
  });

  factory OrderDto.fromFirestore(Map<String, dynamic> data) {
    return OrderDto(
      id: data['id'] ?? '',
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      items: (data['items'] as List? ?? [])
          .map((item) => CartItemDto.fromMap(item))
          .toList(),
      totalAmount: (data['totalAmount'] as num?)?.toDouble() ?? 0.0,
      status: data['status'] ?? '',
      orderDate: (data['orderDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      expectedDeliveryDate: data['expectedDeliveryDate'] != null
          ? (data['expectedDeliveryDate'] as Timestamp).toDate()
          : null,
      orderDeliveryDate: data['orderDeliveryDate'] != null
          ? (data['orderDeliveryDate'] as Timestamp).toDate()
          : null,
      orderTakenBy: data['orderTakenBy'],
      orderDeliveredBy: data['orderDeliveredBy'],
      responsibleForDelivery: data['responsibleForDelivery'],
      lastUpdatedBy: data['lastUpdatedBy'],
      storeId: data['storeId'] ?? '', // New field
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
      'orderDeliveryDate': orderDeliveryDate != null
          ? Timestamp.fromDate(orderDeliveryDate!)
          : null,
      'orderTakenBy': orderTakenBy,
      'orderDeliveredBy': orderDeliveredBy,
      'responsibleForDelivery': responsibleForDelivery,
      'lastUpdatedBy': lastUpdatedBy,
      'storeId': storeId, // New field
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
      orderDeliveryDate: order.orderDeliveryDate,
      orderTakenBy: order.orderTakenBy,
      orderDeliveredBy: order.orderDeliveredBy,
      responsibleForDelivery: order.responsibleForDelivery,
      lastUpdatedBy: order.lastUpdatedBy,
      storeId: order.storeId, // New field
    );
  }
}

class CartItemDto {
  final String productId;
  final String productName;
  final double price;
  final int quantity;
  final double taxRate;
  final double taxAmount;

  CartItemDto({
    required this.productId,
    required this.productName,
    required this.price,
    required this.quantity,
    required this.taxRate,
    required this.taxAmount,
  });

  factory CartItemDto.fromModel(CartItem item) {
    return CartItemDto(
      productId: item.productId,
      productName: item.productName,
      price: item.price,
      quantity: item.quantity,
      taxRate: item.taxRate,
      taxAmount: item.taxAmount,
    );
  }

  factory CartItemDto.fromMap(Map<String, dynamic> map) {
    return CartItemDto(
      productId: map['productId'] ?? '',
      productName: map['productName'] ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      quantity: map['quantity'] ?? 0,
      taxRate: (map['taxRate'] as num?)?.toDouble() ?? 0.0,
      taxAmount: (map['taxAmount'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      'price': price,
      'quantity': quantity,
      'taxRate': taxRate,
      'taxAmount': taxAmount,
    };
  }

  CartItem toModel() {
    return CartItem(
      productId: productId,
      productName: productName,
      price: price,
      quantity: quantity,
      taxRate: taxRate,
      taxAmount: taxAmount,
    );
  }
}