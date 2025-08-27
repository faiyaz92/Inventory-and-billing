// New Service: PurchaseOrderService.dart
import 'package:requirment_gathering_app/company_admin_module/data/purchase/admin_purchase_model.dart';
import 'package:requirment_gathering_app/company_admin_module/data/purchase/admin_purchase_order_dto.dart';
import 'package:requirment_gathering_app/company_admin_module/repositories/i_purchase_order_repository.dart';
import 'package:requirment_gathering_app/company_admin_module/service/i_purchase_order.dart';
import 'package:requirment_gathering_app/core_module/repository/account_repository.dart';
import 'package:requirment_gathering_app/super_admin_module/utils/roles.dart';

class PurchaseOrderService implements IPurchaseOrderService {
  final IPurchaseOrderRepository purchaseOrderRepository;
  final AccountRepository accountRepository;

  PurchaseOrderService({
    required this.purchaseOrderRepository,
    required this.accountRepository,
  });

  @override
  Future<void> placePurchaseOrder(AdminPurchaseOrder order) async {
    final userInfo = await accountRepository.getUserInfo();
    final orderDto = AdminPurchaseOrderDto.fromModel(order);
    await purchaseOrderRepository.addPurchaseOrder(userInfo?.companyId ?? '', orderDto);
  }

  @override
  Future<List<AdminPurchaseOrder>> getPurchaseOrdersBySupplier(String supplierId) async {
    final userInfo = await accountRepository.getUserInfo();
    final orderDtos = await purchaseOrderRepository.getPurchaseOrdersBySupplier(
        userInfo?.companyId ?? '', supplierId);
    return orderDtos.map((dto) => AdminPurchaseOrder.fromFirestore(dto.toFirestore())).toList();
  }

  @override
  Future<List<AdminPurchaseOrder>> getAllPurchaseOrders() async {
    final userInfo = await accountRepository.getUserInfo();
    final orderDtos = await purchaseOrderRepository.getAllPurchaseOrders(
        userInfo?.companyId ?? '',
        userInfo?.role == Role.COMPANY_ADMIN ? null : userInfo?.storeId);
    return orderDtos.map((dto) => AdminPurchaseOrder.fromFirestore(dto.toFirestore())).toList();
  }

  @override
  Future<void> updatePurchaseOrderStatus(String orderId, String status) async {
    final userInfo = await accountRepository.getUserInfo();
    await purchaseOrderRepository.updatePurchaseOrderStatus(
        userInfo?.companyId ?? '', orderId, status, userInfo?.userId);
  }

  @override
  Future<AdminPurchaseOrder> getPurchaseOrderById(String orderId) async {
    final userInfo = await accountRepository.getUserInfo();
    final orderDto =
    await purchaseOrderRepository.getPurchaseOrderById(userInfo?.companyId ?? '', orderId);
    return AdminPurchaseOrder.fromFirestore(orderDto.toFirestore());
  }

  @override
  Future<void> updatePurchaseOrder(AdminPurchaseOrder order) async {
    final userInfo = await accountRepository.getUserInfo();
    final orderDto = AdminPurchaseOrderDto.fromModel(order);
    await purchaseOrderRepository.updatePurchaseOrder(userInfo?.companyId ?? '', orderDto);
  }

  @override
  Future<void> placePurchaseInvoice(AdminPurchaseOrder order) async {
    final userInfo = await accountRepository.getUserInfo();
    final orderDto = AdminPurchaseOrderDto.fromModel(order);
    await purchaseOrderRepository.addPurchaseInvoice(userInfo?.companyId ?? '', orderDto);
  }

  @override
  Future<List<AdminPurchaseOrder>> getPurchaseInvoicesBySupplier(String supplierId) async {
    final userInfo = await accountRepository.getUserInfo();
    final orderDtos = await purchaseOrderRepository.getPurchaseInvoicesBySupplier(
        userInfo?.companyId ?? '', supplierId);
    return orderDtos.map((dto) => AdminPurchaseOrder.fromFirestore(dto.toFirestore())).toList();
  }

  @override
  Future<List<AdminPurchaseOrder>> getAllPurchaseInvoices() async {
    final userInfo = await accountRepository.getUserInfo();
    final orderDtos = await purchaseOrderRepository.getAllPurchaseInvoices(
        userInfo?.companyId ?? '',
        userInfo?.role == Role.COMPANY_ADMIN ? null : userInfo?.storeId);
    return orderDtos.map((dto) => AdminPurchaseOrder.fromFirestore(dto.toFirestore())).toList();
  }

  @override
  Future<AdminPurchaseOrder> getPurchaseInvoiceById(String invoiceId) async {
    final userInfo = await accountRepository.getUserInfo();
    final orderDto =
    await purchaseOrderRepository.getPurchaseInvoiceById(userInfo?.companyId ?? '', invoiceId);
    return AdminPurchaseOrder.fromFirestore(orderDto.toFirestore());
  }

  @override
  Future<void> updatePurchaseInvoice(AdminPurchaseOrder order) async {
    final userInfo = await accountRepository.getUserInfo();
    final orderDto = AdminPurchaseOrderDto.fromModel(order);
    await purchaseOrderRepository.updatePurchaseInvoice(userInfo?.companyId ?? '', orderDto);
  }

  @override
  Future<void> setPaymentStatus(String invoiceId, String paymentStatus) async {
    final userInfo = await accountRepository.getUserInfo();
    await purchaseOrderRepository.setPaymentStatus(
        userInfo?.companyId ?? '', invoiceId, paymentStatus, userInfo?.userId);
  }
}