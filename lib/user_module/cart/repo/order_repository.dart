import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:requirment_gathering_app/core_module/services/firestore_provider.dart';
import 'package:requirment_gathering_app/user_module/cart/data/order_dto.dart';

abstract class IOrderRepository {
  Future<void> addOrder(String companyId, OrderDto order);
  Future<List<OrderDto>> getOrdersByUser(String companyId, String userId);
  Future<List<OrderDto>> getAllOrders({
    required String companyId,
    String? storeId,
    DateTime? startDate,
    DateTime? endDate,
    String? status,
    DateTime? expectedDeliveryStartDate,
    DateTime? expectedDeliveryEndDate,
    String? orderTakenBy,
    String? orderDeliveredBy,
    DateTime? actualDeliveryStartDate,
    DateTime? actualDeliveryEndDate,
    String? userId,
    double? minTotalAmount,
    double? maxTotalAmount,
  });
  Future<void> updateOrderStatus(
      String companyId, String orderId, String status, String? lastUpdatedBy);
  Future<void> setExpectedDeliveryDate(
      String companyId, String orderId, DateTime date, String? lastUpdatedBy);
  Future<OrderDto> getOrderById(String companyId, String orderId);
  Future<void> setOrderDeliveryDate(
      String companyId, String orderId, DateTime date, String? lastUpdatedBy);
  Future<void> setOrderDeliveredBy(
      String companyId, String orderId, String? deliveredBy, String? lastUpdatedBy);
  Future<void> setResponsibleForDelivery(
      String companyId, String orderId, String responsibleForDelivery, String? lastUpdatedBy);
  Future<void> updateOrder(String companyId, OrderDto order);
  Future<void> addInvoice(String companyId, OrderDto order);
  Future<List<OrderDto>> getInvoicesByUser(String companyId, String userId);
  Future<List<OrderDto>> getAllInvoices({
    required String companyId,
    String? storeId,
    DateTime? startDate,
    DateTime? endDate,
    String? invoiceType,
    String? paymentStatus,
    String? invoiceLastUpdatedBy,
    String? userId,
    double? minTotalAmount,
    double? maxTotalAmount,
  });
  Future<OrderDto> getInvoiceById(String companyId, String invoiceId);
  Future<void> updateInvoice(String companyId, OrderDto order);
  Future<void> setInvoiceGeneratedDate(
      String companyId, String invoiceId, DateTime date, String? lastUpdatedBy);
  Future<void> setInvoiceType(
      String companyId, String invoiceId, String invoiceType, String? lastUpdatedBy);
  Future<void> setPaymentStatus(
      String companyId, String invoiceId, String paymentStatus, String? lastUpdatedBy);
}

class OrderRepositoryImpl implements IOrderRepository {
  final IFirestorePathProvider firestorePathProvider;

  OrderRepositoryImpl({
    required this.firestorePathProvider,
  });

  @override
  Future<void> addOrder(String companyId, OrderDto order) async {
    try {
      final ref = firestorePathProvider.getOrdersCollectionRef(companyId);
      await ref.doc(order.id).set(order.toFirestore());
    } catch (e) {
      throw Exception('Failed to add order: $e');
    }
  }

  @override
  Future<List<OrderDto>> getOrdersByUser(String companyId, String userId) async {
    try {
      final ref = firestorePathProvider.getOrdersCollectionRef(companyId);
      final snapshot = await ref.where('userId', isEqualTo: userId).get();
      return snapshot.docs
          .map((doc) => OrderDto.fromFirestore(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch orders: $e');
    }
  }

  @override
  Future<List<OrderDto>> getAllOrders({
    required String companyId,
    String? storeId,
    DateTime? startDate,
    DateTime? endDate,
    String? status,
    DateTime? expectedDeliveryStartDate,
    DateTime? expectedDeliveryEndDate,
    String? orderTakenBy,
    String? orderDeliveredBy,
    DateTime? actualDeliveryStartDate,
    DateTime? actualDeliveryEndDate,
    String? userId,
    double? minTotalAmount,
    double? maxTotalAmount,
  }) async {
    try {
      Query<Object?> ref = firestorePathProvider.getOrdersCollectionRef(companyId);

      if (storeId != null) {
        ref = ref.where('storeId', isEqualTo: storeId);
      }
      if (startDate != null) {
        ref = ref.where('orderDate', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
      }
      if (endDate != null) {
        ref = ref.where('orderDate', isLessThanOrEqualTo: Timestamp.fromDate(endDate.add(const Duration(days: 1))));
      }
      if (status != null) {
        ref = ref.where('status', isEqualTo: status);
      }
      if (expectedDeliveryStartDate != null) {
        ref = ref.where('expectedDeliveryDate', isGreaterThanOrEqualTo: Timestamp.fromDate(expectedDeliveryStartDate));
      }
      if (expectedDeliveryEndDate != null) {
        ref = ref.where('expectedDeliveryDate', isLessThanOrEqualTo: Timestamp.fromDate(expectedDeliveryEndDate.add(const Duration(days: 1))));
      }
      if (orderTakenBy != null) {
        ref = ref.where('orderTakenBy', isEqualTo: orderTakenBy);
      }
      if (orderDeliveredBy != null) {
        ref = ref.where('orderDeliveredBy', isEqualTo: orderDeliveredBy);
      }
      if (actualDeliveryStartDate != null) {
        ref = ref.where('orderDeliveryDate', isGreaterThanOrEqualTo: Timestamp.fromDate(actualDeliveryStartDate));
      }
      if (actualDeliveryEndDate != null) {
        ref = ref.where('orderDeliveryDate', isLessThanOrEqualTo: Timestamp.fromDate(actualDeliveryEndDate.add(const Duration(days: 1))));
      }
      if (userId != null) {
        ref = ref.where('userId', isEqualTo: userId);
      }
      if (minTotalAmount != null) {
        ref = ref.where('totalAmount', isGreaterThanOrEqualTo: minTotalAmount);
      }
      if (maxTotalAmount != null) {
        ref = ref.where('totalAmount', isLessThanOrEqualTo: maxTotalAmount);
      }

      ref = ref.orderBy('orderDate', descending: true);

      final snapshot = await ref.get();

      return snapshot.docs
          .map((doc) => OrderDto.fromFirestore(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print(e.toString());
      throw Exception('Failed to fetch orders: $e');
    }
  }

  @override
  Future<void> updateOrderStatus(
      String companyId, String orderId, String status, String? lastUpdatedBy) async {
    try {
      final ref = firestorePathProvider.getOrdersCollectionRef(companyId);
      await ref.doc(orderId).update({
        'status': status,
        'lastUpdatedBy': lastUpdatedBy,
      });
    } catch (e) {
      throw Exception('Failed to update order status: $e');
    }
  }

  @override
  Future<void> setExpectedDeliveryDate(
      String companyId, String orderId, DateTime date, String? lastUpdatedBy) async {
    try {
      final ref = firestorePathProvider.getOrdersCollectionRef(companyId);
      await ref.doc(orderId).update({
        'expectedDeliveryDate': Timestamp.fromDate(date),
        'lastUpdatedBy': lastUpdatedBy,
      });
    } catch (e) {
      throw Exception('Failed to set delivery date: $e');
    }
  }

  @override
  Future<OrderDto> getOrderById(String companyId, String orderId) async {
    try {
      final ref = firestorePathProvider.getOrdersCollectionRef(companyId).doc(orderId);
      final doc = await ref.get();
      if (!doc.exists) {
        throw Exception('Order not found');
      }
      return OrderDto.fromFirestore(doc.data() as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to fetch order: $e');
    }
  }

  @override
  Future<void> setOrderDeliveryDate(
      String companyId, String orderId, DateTime date, String? lastUpdatedBy) async {
    try {
      final ref = firestorePathProvider.getOrdersCollectionRef(companyId);
      await ref.doc(orderId).update({
        'orderDeliveryDate': Timestamp.fromDate(date),
        'lastUpdatedBy': lastUpdatedBy,
      });
    } catch (e) {
      throw Exception('Failed to set order delivery date: $e');
    }
  }

  @override
  Future<void> setOrderDeliveredBy(
      String companyId, String orderId, String? deliveredBy, String? lastUpdatedBy) async {
    try {
      final ref = firestorePathProvider.getOrdersCollectionRef(companyId);
      await ref.doc(orderId).update({
        'orderDeliveredBy': deliveredBy,
        'lastUpdatedBy': lastUpdatedBy,
      });
    } catch (e) {
      throw Exception('Failed to set order delivered by: $e');
    }
  }

  @override
  Future<void> setResponsibleForDelivery(
      String companyId, String orderId, String responsibleForDelivery, String? lastUpdatedBy) async {
    try {
      final ref = firestorePathProvider.getOrdersCollectionRef(companyId);
      await ref.doc(orderId).update({
        'responsibleForDelivery': responsibleForDelivery,
        'lastUpdatedBy': lastUpdatedBy,
      });
    } catch (e) {
      throw Exception('Failed to set responsible for delivery: $e');
    }
  }

  @override
  Future<void> updateOrder(String companyId, OrderDto order) async {
    try {
      final ref = firestorePathProvider.getOrdersCollectionRef(companyId);
      await ref.doc(order.id).set(order.toFirestore(), SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to update order: $e');
    }
  }

  @override
  Future<void> addInvoice(String companyId, OrderDto order) async {
    try {
      final ref = firestorePathProvider.getInvoicesCollectionRef(companyId);
      await ref.doc(order.id).set(order.toFirestore());
    } catch (e) {
      throw Exception('Failed to add invoice: $e');
    }
  }

  @override
  Future<List<OrderDto>> getInvoicesByUser(String companyId, String userId) async {
    try {
      final ref = firestorePathProvider.getInvoicesCollectionRef(companyId);
      final snapshot = await ref.where('userId', isEqualTo: userId).get();
      return snapshot.docs
          .map((doc) => OrderDto.fromFirestore(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch invoices: $e');
    }
  }

  @override
  Future<List<OrderDto>> getAllInvoices({
    required String companyId,
    String? storeId,
    DateTime? startDate,
    DateTime? endDate,
    String? invoiceType,
    String? paymentStatus,
    String? invoiceLastUpdatedBy,
    String? userId,
    double? minTotalAmount,
    double? maxTotalAmount,
  }) async {
    try {
      Query<Object?> ref = firestorePathProvider.getInvoicesCollectionRef(companyId);

      if (storeId != null) {
        ref = ref.where('storeId', isEqualTo: storeId);
      }
      if (startDate != null) {
        ref = ref.where('invoiceGeneratedDate', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
      }
      if (endDate != null) {
        ref = ref.where('invoiceGeneratedDate', isLessThanOrEqualTo: Timestamp.fromDate(endDate.add(const Duration(days: 1))));
      }
      if (invoiceType != null) {
        ref = ref.where('invoiceType', isEqualTo: invoiceType);
      }
      if (paymentStatus != null) {
        ref = ref.where('paymentStatus', isEqualTo: paymentStatus);
      }
      if (invoiceLastUpdatedBy != null) {
        ref = ref.where('invoiceLastUpdatedBy', isEqualTo: invoiceLastUpdatedBy);
      }
      if (userId != null) {
        ref = ref.where('userId', isEqualTo: userId);
      }
      if (minTotalAmount != null) {
        ref = ref.where('totalAmount', isGreaterThanOrEqualTo: minTotalAmount);
      }
      if (maxTotalAmount != null) {
        ref = ref.where('totalAmount', isLessThanOrEqualTo: maxTotalAmount);
      }

      ref = ref.orderBy('invoiceGeneratedDate', descending: true);

      final snapshot = await ref.get();

      return snapshot.docs
          .map((doc) => OrderDto.fromFirestore(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print(e.toString());
      throw Exception('Failed to fetch invoices: $e');
    }
  }

  @override
  Future<OrderDto> getInvoiceById(String companyId, String invoiceId) async {
    try {
      final ref = firestorePathProvider.getInvoicesCollectionRef(companyId).doc(invoiceId);
      final doc = await ref.get();
      if (!doc.exists) {
        throw Exception('Invoice not found');
      }
      return OrderDto.fromFirestore(doc.data() as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to fetch invoice: $e');
    }
  }

  @override
  Future<void> updateInvoice(String companyId, OrderDto order) async {
    try {
      final ref = firestorePathProvider.getInvoicesCollectionRef(companyId);
      await ref.doc(order.id).set(order.toFirestore(), SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to update invoice: $e');
    }
  }

  @override
  Future<void> setInvoiceGeneratedDate(
      String companyId, String invoiceId, DateTime date, String? lastUpdatedBy) async {
    try {
      final ref = firestorePathProvider.getInvoicesCollectionRef(companyId);
      await ref.doc(invoiceId).update({
        'invoiceGeneratedDate': Timestamp.fromDate(date),
        'invoiceLastUpdatedBy': lastUpdatedBy,
      });
    } catch (e) {
      throw Exception('Failed to set invoice generated date: $e');
    }
  }

  @override
  Future<void> setInvoiceType(
      String companyId, String invoiceId, String invoiceType, String? lastUpdatedBy) async {
    try {
      final ref = firestorePathProvider.getInvoicesCollectionRef(companyId);
      await ref.doc(invoiceId).update({
        'invoiceType': invoiceType,
        'invoiceLastUpdatedBy': lastUpdatedBy,
      });
    } catch (e) {
      throw Exception('Failed to set invoice type: $e');
    }
  }

  @override
  Future<void> setPaymentStatus(
      String companyId, String invoiceId, String paymentStatus, String? lastUpdatedBy) async {
    try {
      final ref = firestorePathProvider.getInvoicesCollectionRef(companyId);
      await ref.doc(invoiceId).update({
        'paymentStatus': paymentStatus,
        'invoiceLastUpdatedBy': lastUpdatedBy,
      });
    } catch (e) {
      throw Exception('Failed to set payment status: $e');
    }
  }
}