// New Model: AdminPurchaseOrderModel.dart
import 'package:cloud_firestore/cloud_firestore.dart' show Timestamp;

class AdminPurchaseOrder {
  final String id;
  final String supplierId;
  final String supplierName;
  final List<PurchaseItem> items;
  final double totalAmount;
  final double? discount;
  final String status;
  final DateTime orderDate;
  final String? storeId;
  final String? billNumber;
  final String? invoiceLastUpdatedBy;
  final DateTime? invoiceGeneratedDate;
  final String? purchaseType;
  final String? paymentStatus;
  final double? amountReceived;
  final List<Map<String, dynamic>>? paymentDetails;
  final String? supplierLedgerId;
  final String? storeLedgerId;

  AdminPurchaseOrder({
    required this.id,
    required this.supplierId,
    required this.supplierName,
    required this.items,
    required this.totalAmount,
    this.discount,
    required this.status,
    required this.orderDate,
    this.storeId,
    this.billNumber,
    this.invoiceLastUpdatedBy,
    this.invoiceGeneratedDate,
    this.purchaseType,
    this.paymentStatus,
    this.amountReceived,
    this.paymentDetails,
    this.supplierLedgerId,
    this.storeLedgerId,
  });

  factory AdminPurchaseOrder.fromFirestore(Map<String, dynamic> data) {
    return AdminPurchaseOrder(
      id: data['id'] ?? '',
      supplierId: data['supplierId'] ?? '',
      supplierName: data['supplierName'] ?? '',
      items: (data['items'] as List? ?? [])
          .map((item) => PurchaseItem.fromFirestore(item))
          .toList(),
      totalAmount: (data['totalAmount'] as num?)?.toDouble() ?? 0.0,
      discount: (data['discount'] as num?)?.toDouble(),
      status: data['status'] ?? '',
      orderDate: (data['orderDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      storeId: data['storeId'],
      billNumber: data['billNumber'],
      invoiceLastUpdatedBy: data['invoiceLastUpdatedBy'],
      invoiceGeneratedDate: data['invoiceGeneratedDate'] != null
          ? (data['invoiceGeneratedDate'] as Timestamp).toDate()
          : null,
      purchaseType: data['purchaseType'],
      paymentStatus: data['paymentStatus'],
      amountReceived: (data['amountReceived'] as num?)?.toDouble(),
      paymentDetails: (data['paymentDetails'] as List<dynamic>?)
          ?.map((item) => Map<String, dynamic>.from(item))
          .toList(),
      supplierLedgerId: data['supplierLedgerId'],
      storeLedgerId: data['storeLedgerId'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'supplierId': supplierId,
      'supplierName': supplierName,
      'items': items.map((item) => item.toFirestore()).toList(),
      'totalAmount': totalAmount,
      'discount': discount,
      'status': status,
      'orderDate': Timestamp.fromDate(orderDate),
      'storeId': storeId,
      'billNumber': billNumber,
      'invoiceLastUpdatedBy': invoiceLastUpdatedBy,
      'invoiceGeneratedDate': invoiceGeneratedDate != null
          ? Timestamp.fromDate(invoiceGeneratedDate!)
          : null,
      'purchaseType': purchaseType,
      'paymentStatus': paymentStatus,
      'amountReceived': amountReceived,
      'paymentDetails': paymentDetails,
      'supplierLedgerId': supplierLedgerId,
      'storeLedgerId': storeLedgerId,
    };
  }

  AdminPurchaseOrder copyWith({
    String? id,
    String? supplierId,
    String? supplierName,
    List<PurchaseItem>? items,
    double? totalAmount,
    double? discount,
    String? status,
    DateTime? orderDate,
    String? storeId,
    String? billNumber,
    String? invoiceLastUpdatedBy,
    DateTime? invoiceGeneratedDate,
    String? purchaseType,
    String? paymentStatus,
    double? amountReceived,
    List<Map<String, dynamic>>? paymentDetails,
    String? supplierLedgerId,
    String? storeLedgerId,
  }) {
    return AdminPurchaseOrder(
      id: id ?? this.id,
      supplierId: supplierId ?? this.supplierId,
      supplierName: supplierName ?? this.supplierName,
      items: items ?? this.items,
      totalAmount: totalAmount ?? this.totalAmount,
      discount: discount ?? this.discount,
      status: status ?? this.status,
      orderDate: orderDate ?? this.orderDate,
      storeId: storeId ?? this.storeId,
      billNumber: billNumber ?? this.billNumber,
      invoiceLastUpdatedBy: invoiceLastUpdatedBy ?? this.invoiceLastUpdatedBy,
      invoiceGeneratedDate: invoiceGeneratedDate ?? this.invoiceGeneratedDate,
      purchaseType: purchaseType ?? this.purchaseType,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      amountReceived: amountReceived ?? this.amountReceived,
      paymentDetails: paymentDetails ?? this.paymentDetails,
      supplierLedgerId: supplierLedgerId ?? this.supplierLedgerId,
      storeLedgerId: storeLedgerId ?? this.storeLedgerId,
    );
  }
}

class PurchaseItem {
  final String productId;
  final String productName;
  final double price;
  final int quantity;
  final double taxRate;
  final double taxAmount;

  PurchaseItem({
    required this.productId,
    required this.productName,
    required this.price,
    required this.quantity,
    required this.taxRate,
    required this.taxAmount,
  });

  factory PurchaseItem.fromFirestore(Map<String, dynamic> data) {
    return PurchaseItem(
      productId: data['productId'] ?? '',
      productName: data['productName'] ?? '',
      price: (data['price'] as num?)?.toDouble() ?? 0.0,
      quantity: (data['quantity'] as num?)?.toInt() ?? 0,
      taxRate: (data['taxRate'] as num?)?.toDouble() ?? 0.0,
      taxAmount: (data['taxAmount'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'productId': productId,
      'productName': productName,
      'price': price,
      'quantity': quantity,
      'taxRate': taxRate,
      'taxAmount': taxAmount,
    };
  }
}