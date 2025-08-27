// New Repository: PurchaseOrderRepositoryImpl.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:requirment_gathering_app/company_admin_module/data/purchase/admin_purchase_order_dto.dart';
import 'package:requirment_gathering_app/company_admin_module/repositories/i_purchase_order_repository.dart';
import 'package:requirment_gathering_app/core_module/services/firestore_provider.dart';

class PurchaseOrderRepositoryImpl implements IPurchaseOrderRepository {
  final IFirestorePathProvider firestorePathProvider;

  PurchaseOrderRepositoryImpl({
    required this.firestorePathProvider,
  });

  @override
  Future<void> addPurchaseOrder(String companyId, AdminPurchaseOrderDto order) async {
    try {
      final ref = firestorePathProvider.getPurchaseOrdersCollectionRef(companyId);
      await ref.doc(order.id).set(order.toFirestore());
    } catch (e) {
      throw Exception('Failed to add purchase order: $e');
    }
  }

  @override
  Future<List<AdminPurchaseOrderDto>> getPurchaseOrdersBySupplier(String companyId, String supplierId) async {
    try {
      final ref = firestorePathProvider.getPurchaseOrdersCollectionRef(companyId);
      final snapshot = await ref.where('supplierId', isEqualTo: supplierId).get();
      return snapshot.docs
          .map((doc) => AdminPurchaseOrderDto.fromFirestore(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch purchase orders: $e');
    }
  }

  @override
  Future<List<AdminPurchaseOrderDto>> getAllPurchaseOrders(String companyId, String? storeId) async {
    try {
      final ref = firestorePathProvider.getPurchaseOrdersCollectionRef(companyId);
      QuerySnapshot snapshot;

      if (storeId == null) {
        snapshot = await ref.get();
      } else {
        snapshot = await ref.where('storeId', isEqualTo: storeId).get();
      }

      return snapshot.docs
          .map((doc) => AdminPurchaseOrderDto.fromFirestore(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch purchase orders: $e');
    }
  }

  @override
  Future<void> updatePurchaseOrderStatus(
      String companyId, String orderId, String status, String? lastUpdatedBy) async {
    try {
      final ref = firestorePathProvider.getPurchaseOrdersCollectionRef(companyId);
      await ref.doc(orderId).update({
        'status': status,
        'lastUpdatedBy': lastUpdatedBy,
      });
    } catch (e) {
      throw Exception('Failed to update purchase order status: $e');
    }
  }

  @override
  Future<AdminPurchaseOrderDto> getPurchaseOrderById(String companyId, String orderId) async {
    try {
      final ref = firestorePathProvider.getPurchaseOrdersCollectionRef(companyId).doc(orderId);
      final doc = await ref.get();
      if (!doc.exists) {
        throw Exception('Purchase order not found');
      }
      return AdminPurchaseOrderDto.fromFirestore(doc.data() as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to fetch purchase order: $e');
    }
  }

  @override
  Future<void> updatePurchaseOrder(String companyId, AdminPurchaseOrderDto order) async {
    try {
      final ref = firestorePathProvider.getPurchaseOrdersCollectionRef(companyId);
      await ref.doc(order.id).set(order.toFirestore(), SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to update purchase order: $e');
    }
  }

  @override
  Future<void> addPurchaseInvoice(String companyId, AdminPurchaseOrderDto order) async {
    try {
      final ref = firestorePathProvider.getPurchaseInvoicesCollectionRef(companyId);
      await ref.doc(order.id).set(order.toFirestore());
    } catch (e) {
      throw Exception('Failed to add purchase invoice: $e');
    }
  }

  @override
  Future<List<AdminPurchaseOrderDto>> getPurchaseInvoicesBySupplier(String companyId, String supplierId) async {
    try {
      final ref = firestorePathProvider.getPurchaseInvoicesCollectionRef(companyId);
      final snapshot = await ref.where('supplierId', isEqualTo: supplierId).get();
      return snapshot.docs
          .map((doc) => AdminPurchaseOrderDto.fromFirestore(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch purchase invoices: $e');
    }
  }

  @override
  Future<List<AdminPurchaseOrderDto>> getAllPurchaseInvoices(String companyId, String? storeId) async {
    try {
      final ref = firestorePathProvider.getPurchaseInvoicesCollectionRef(companyId);
      QuerySnapshot snapshot;

      if (storeId == null) {
        snapshot = await ref.get();
      } else {
        snapshot = await ref.where('storeId', isEqualTo: storeId).get();
      }

      return snapshot.docs
          .map((doc) => AdminPurchaseOrderDto.fromFirestore(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch purchase invoices: $e');
    }
  }

  @override
  Future<AdminPurchaseOrderDto> getPurchaseInvoiceById(String companyId, String invoiceId) async {
    try {
      final ref = firestorePathProvider.getPurchaseInvoicesCollectionRef(companyId).doc(invoiceId);
      final doc = await ref.get();
      if (!doc.exists) {
        throw Exception('Purchase invoice not found');
      }
      return AdminPurchaseOrderDto.fromFirestore(doc.data() as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to fetch purchase invoice: $e');
    }
  }

  @override
  Future<void> updatePurchaseInvoice(String companyId, AdminPurchaseOrderDto order) async {
    try {
      final ref = firestorePathProvider.getPurchaseInvoicesCollectionRef(companyId);
      await ref.doc(order.id).set(order.toFirestore(), SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to update purchase invoice: $e');
    }
  }

  @override
  Future<void> setPaymentStatus(
      String companyId, String invoiceId, String paymentStatus, String? lastUpdatedBy) async {
    try {
      final ref = firestorePathProvider.getPurchaseInvoicesCollectionRef(companyId);
      await ref.doc(invoiceId).update({
        'paymentStatus': paymentStatus,
        'invoiceLastUpdatedBy': lastUpdatedBy,
      });
    } catch (e) {
      throw Exception('Failed to set payment status: $e');
    }
  }
}