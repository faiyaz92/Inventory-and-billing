// Updated CartItem class to include discountAmount and discountPercentage
import 'package:requirment_gathering_app/user_module/cart/data/order_dto.dart';

class CartItem {
  final String productId;
  final String productName;
  final double price;
  final int quantity;
  final double taxRate;
  final double taxAmount;
  final double discountAmount; // Added
  final double discountPercentage; // Added

  CartItem({
    required this.productId,
    required this.productName,
    required this.price,
    required this.quantity,
    required this.taxRate,
    required this.taxAmount,
    this.discountAmount = 0.0, // Default to 0.0
    this.discountPercentage = 0.0, // Default to 0.0
  });

  factory CartItem.fromDto(CartItemDto dto) {
    return CartItem(
      productId: dto.productId,
      productName: dto.productName,
      price: dto.price,
      quantity: dto.quantity,
      taxRate: dto.taxRate,
      taxAmount: dto.taxAmount,
      discountAmount: dto.discountAmount,
      discountPercentage: dto.discountPercentage,
    );
  }

  CartItem copyWith({
    String? productId,
    String? productName,
    double? price,
    int? quantity,
    double? taxRate,
    double? taxAmount,
    double? discountAmount,
    double? discountPercentage,
  }) {
    return CartItem(
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      taxRate: taxRate ?? this.taxRate,
      taxAmount: taxAmount ?? this.taxAmount,
      discountAmount: discountAmount ?? this.discountAmount,
      discountPercentage: discountPercentage ?? this.discountPercentage,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'productName': productName,
      'price': price,
      'quantity': quantity,
      'taxRate': taxRate,
      'taxAmount': taxAmount,
      'discountAmount': discountAmount,
      'discountPercentage': discountPercentage,
    };
  }
}

// Updated Order class to handle updated CartItem
class Order {
  final String id;
  final String userId;
  final String userName;
  final List<CartItem> items;
  final double totalAmount;
  final double? discount;
  final String status;
  final DateTime orderDate;
  final DateTime? expectedDeliveryDate;
  final DateTime? orderDeliveryDate;
  final String? orderTakenBy;
  final String? orderDeliveredBy;
  final String? responsibleForDelivery;
  final String? lastUpdatedBy;
  final String? storeId;
  final String? billNumber;
  final String? invoiceLastUpdatedBy;
  final DateTime? invoiceGeneratedDate;
  final String? invoiceType;
  final String? paymentStatus;
  final double? amountReceived;
  final List<Map<String, dynamic>>? paymentDetails;
  final int? slipNumber;
  final String? customerLedgerId;

  Order({
    required this.id,
    required this.userId,
    required this.userName,
    required this.items,
    required this.totalAmount,
    this.discount,
    required this.status,
    required this.orderDate,
    this.expectedDeliveryDate,
    this.orderDeliveryDate,
    this.orderTakenBy,
    this.orderDeliveredBy,
    this.responsibleForDelivery,
    this.lastUpdatedBy,
    this.storeId,
    this.billNumber,
    this.invoiceLastUpdatedBy,
    this.invoiceGeneratedDate,
    this.invoiceType,
    this.paymentStatus,
    this.amountReceived,
    this.paymentDetails,
    this.slipNumber,
    this.customerLedgerId,
  });

  factory Order.fromDto(OrderDto dto) {
    return Order(
      id: dto.id,
      userId: dto.userId,
      userName: dto.userName,
      items: dto.items.map((itemDto) => CartItem.fromDto(itemDto)).toList(),
      totalAmount: dto.totalAmount,
      discount: dto.discount,
      status: dto.status,
      orderDate: dto.orderDate,
      expectedDeliveryDate: dto.expectedDeliveryDate,
      orderDeliveryDate: dto.orderDeliveryDate,
      orderTakenBy: dto.orderTakenBy,
      orderDeliveredBy: dto.orderDeliveredBy,
      responsibleForDelivery: dto.responsibleForDelivery,
      lastUpdatedBy: dto.lastUpdatedBy,
      storeId: dto.storeId,
      billNumber: dto.billNumber,
      invoiceLastUpdatedBy: dto.invoiceLastUpdatedBy,
      invoiceGeneratedDate: dto.invoiceGeneratedDate,
      invoiceType: dto.invoiceType,
      paymentStatus: dto.paymentStatus,
      amountReceived: dto.amountReceived,
      paymentDetails: dto.paymentDetails,
      slipNumber: dto.slipNumber,
      customerLedgerId: dto.customerLedgerId,
    );
  }

  Order copyWith({
    String? id,
    String? userId,
    String? userName,
    List<CartItem>? items,
    double? totalAmount,
    double? discount,
    String? status,
    DateTime? orderDate,
    DateTime? expectedDeliveryDate,
    DateTime? orderDeliveryDate,
    String? orderTakenBy,
    String? orderDeliveredBy,
    String? responsibleForDelivery,
    String? lastUpdatedBy,
    String? storeId,
    String? billNumber,
    String? invoiceLastUpdatedBy,
    DateTime? invoiceGeneratedDate,
    String? invoiceType,
    String? paymentStatus,
    double? amountReceived,
    List<Map<String, dynamic>>? paymentDetails,
    int? slipNumber,
    String? customerLedgerId,
  }) {
    return Order(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      items: items ?? this.items,
      totalAmount: totalAmount ?? this.totalAmount,
      discount: discount ?? this.discount,
      status: status ?? this.status,
      orderDate: orderDate ?? this.orderDate,
      expectedDeliveryDate: expectedDeliveryDate ?? this.expectedDeliveryDate,
      orderDeliveryDate: orderDeliveryDate ?? this.orderDeliveryDate,
      orderTakenBy: orderTakenBy ?? this.orderTakenBy,
      orderDeliveredBy: orderDeliveredBy ?? this.orderDeliveredBy,
      responsibleForDelivery: responsibleForDelivery ?? this.responsibleForDelivery,
      lastUpdatedBy: lastUpdatedBy ?? this.lastUpdatedBy,
      storeId: storeId ?? this.storeId,
      billNumber: billNumber ?? this.billNumber,
      invoiceLastUpdatedBy: invoiceLastUpdatedBy ?? this.invoiceLastUpdatedBy,
      invoiceGeneratedDate: invoiceGeneratedDate ?? this.invoiceGeneratedDate,
      invoiceType: invoiceType ?? this.invoiceType,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      amountReceived: amountReceived ?? this.amountReceived,
      paymentDetails: paymentDetails ?? this.paymentDetails,
      slipNumber: slipNumber ?? this.slipNumber,
      customerLedgerId: customerLedgerId ?? this.customerLedgerId,
    );
  }
}
