import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:requirment_gathering_app/core_module/services/firestore_provider.dart';
import 'package:requirment_gathering_app/user_module/cart/data/order_dto.dart';

abstract class IOrderRepository {
  Future<void> addOrder(String companyId, OrderDto order);
  Future<List<OrderDto>> getOrdersByUser(String companyId, String userId);
  Future<List<OrderDto>> getAllOrders(String companyId, String? storeId);
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
  Future<List<OrderDto>> getAllInvoices(String companyId, String? storeId);
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
  Future<List<OrderDto>> getAllOrders(String companyId, String? storeId) async {
    try {
      final ref = firestorePathProvider.getOrdersCollectionRef(companyId);
      QuerySnapshot snapshot;

      if (storeId == null) {
        snapshot = await ref.get();
      } else {
        snapshot = await ref.where('storeId', isEqualTo: storeId).get();
      }

      return snapshot.docs
          .map((doc) => OrderDto.fromFirestore(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
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
  Future<List<OrderDto>> getAllInvoices(String companyId, String? storeId) async {
    try {
      final ref = firestorePathProvider.getInvoicesCollectionRef(companyId);
      QuerySnapshot snapshot;

      if (storeId == null) {
        snapshot = await ref.get();
      } else {
        snapshot = await ref.where('storeId', isEqualTo: storeId).get();
      }

      return snapshot.docs
          .map((doc) => OrderDto.fromFirestore(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
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