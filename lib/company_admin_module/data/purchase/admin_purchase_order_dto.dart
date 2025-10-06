// New DTO: AdminPurchaseOrderDto.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:requirment_gathering_app/company_admin_module/data/purchase/admin_purchase_model.dart';

class AdminPurchaseOrderDto {
  final String id;
  final String supplierId;
  final String supplierName;
  final List<PurchaseItemDto> items;
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

  AdminPurchaseOrderDto({
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

  factory AdminPurchaseOrderDto.fromFirestore(Map<String, dynamic> data) {
    return AdminPurchaseOrderDto(
      id: data['id'] ?? '',
      supplierId: data['supplierId'] ?? '',
      supplierName: data['supplierName'] ?? '',
      items: (data['items'] as List? ?? [])
          .map((item) => PurchaseItemDto.fromMap(item))
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
      'items': items.map((item) => item.toMap()).toList(),
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

  factory AdminPurchaseOrderDto.fromModel(AdminPurchaseOrder model) {
    return AdminPurchaseOrderDto(
      id: model.id,
      supplierId: model.supplierId,
      supplierName: model.supplierName,
      items: model.items.map((item) => PurchaseItemDto.fromModel(item)).toList(),
      totalAmount: model.totalAmount,
      discount: model.discount,
      status: model.status,
      orderDate: model.orderDate,
      storeId: model.storeId,
      billNumber: model.billNumber,
      invoiceLastUpdatedBy: model.invoiceLastUpdatedBy,
      invoiceGeneratedDate: model.invoiceGeneratedDate,
      purchaseType: model.purchaseType,
      paymentStatus: model.paymentStatus,
      amountReceived: model.amountReceived,
      paymentDetails: model.paymentDetails,
      supplierLedgerId: model.supplierLedgerId,
      storeLedgerId: model.storeLedgerId,
    );
  }
}

class PurchaseItemDto {
  final String productId;
  final String productName;
  final double price;
  final int quantity;
  final double taxRate;
  final double taxAmount;

  PurchaseItemDto({
    required this.productId,
    required this.productName,
    required this.price,
    required this.quantity,
    required this.taxRate,
    required this.taxAmount,
  });

  factory PurchaseItemDto.fromModel(PurchaseItem item) {
    return PurchaseItemDto(
      productId: item.productId,
      productName: item.productName,
      price: item.price,
      quantity: item.quantity,
      taxRate: item.taxRate,
      taxAmount: item.taxAmount,
    );
  }

  factory PurchaseItemDto.fromMap(Map<String, dynamic> map) {
    return PurchaseItemDto(
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
}