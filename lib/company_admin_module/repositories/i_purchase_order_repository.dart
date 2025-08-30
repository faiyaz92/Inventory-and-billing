import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:requirment_gathering_app/company_admin_module/data/purchase/admin_purchase_order_dto.dart';

abstract class IPurchaseOrderRepository {
  Future<void> addPurchaseOrder(String companyId, AdminPurchaseOrderDto order);
  Future<List<AdminPurchaseOrderDto>> getPurchaseOrdersBySupplier(String companyId, String supplierId);
  Future<List<AdminPurchaseOrderDto>> getAllPurchaseOrders(
      String companyId,
      String? storeId, {
        DateTime? startDate,
        DateTime? endDate,
        String? purchaseType,
        String? paymentStatus,
        String? invoiceLastUpdatedBy,
        String? supplierId,
        double? minTotalAmount,
        double? maxTotalAmount,
        String? searchQuery,
      });
  Future<void> updatePurchaseOrderStatus(
      String companyId, String orderId, String status, String? lastUpdatedBy);
  Future<AdminPurchaseOrderDto> getPurchaseOrderById(String companyId, String orderId);
  Future<void> updatePurchaseOrder(String companyId, AdminPurchaseOrderDto order);
  Future<void> addPurchaseInvoice(String companyId, AdminPurchaseOrderDto order);
  Future<List<AdminPurchaseOrderDto>> getPurchaseInvoicesBySupplier(String companyId, String supplierId);
  Future<List<AdminPurchaseOrderDto>> getAllPurchaseInvoices(String companyId, String? storeId);
  Future<AdminPurchaseOrderDto> getPurchaseInvoiceById(String companyId, String invoiceId);
  Future<void> updatePurchaseInvoice(String companyId, AdminPurchaseOrderDto order);
  Future<void> setPaymentStatus(
      String companyId, String invoiceId, String paymentStatus, String? lastUpdatedBy);
}