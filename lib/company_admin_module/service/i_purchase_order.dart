// New Service Interface: IPurchaseOrderService.dart
import 'package:requirment_gathering_app/company_admin_module/data/purchase/admin_purchase_model.dart';

abstract class IPurchaseOrderService {
  Future<void> placePurchaseOrder(AdminPurchaseOrder order);
  Future<List<AdminPurchaseOrder>> getPurchaseOrdersBySupplier(String supplierId);
  Future<List<AdminPurchaseOrder>> getAllPurchaseOrders();
  Future<void> updatePurchaseOrderStatus(String orderId, String status);
  Future<AdminPurchaseOrder> getPurchaseOrderById(String orderId);
  Future<void> updatePurchaseOrder(AdminPurchaseOrder order);
  Future<void> placePurchaseInvoice(AdminPurchaseOrder order);
  Future<List<AdminPurchaseOrder>> getPurchaseInvoicesBySupplier(String supplierId);
  Future<List<AdminPurchaseOrder>> getAllPurchaseInvoices();
  Future<AdminPurchaseOrder> getPurchaseInvoiceById(String invoiceId);
  Future<void> updatePurchaseInvoice(AdminPurchaseOrder order);
  Future<void> setPaymentStatus(String invoiceId, String paymentStatus);
}