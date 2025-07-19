import 'package:requirment_gathering_app/user_module/cart/data/order_model.dart';

abstract class IOrderService {
  Future<void> placeOrder(Order order);
  Future<List<Order>> getOrdersByUser();
  Future<List<Order>> getAllOrders();
  Future<void> updateOrderStatus(String orderId, String status);
  Future<void> setExpectedDeliveryDate(String orderId, DateTime date);
  Future<Order> getOrderById(String orderId);
  Future<void> setOrderDeliveryDate(String orderId, DateTime date);
  Future<void> setOrderDeliveredBy(String orderId, String? deliveredBy);
  Future<void> setResponsibleForDelivery(String orderId, String responsibleForDelivery);
  Future<void> updateOrder(Order order);
  Future<void> placeInvoice(Order order);
  Future<List<Order>> getInvoicesByUser();
  Future<List<Order>> getAllInvoices();
  Future<Order> getInvoiceById(String invoiceId);
  Future<void> updateInvoice(Order order);
  Future<void> setInvoiceGeneratedDate(String invoiceId, DateTime date);
  Future<void> setInvoiceType(String invoiceId, String invoiceType);
  Future<void> setPaymentStatus(String invoiceId, String paymentStatus);
}