import 'package:requirment_gathering_app/core_module/repository/account_repository.dart';
import 'package:requirment_gathering_app/super_admin_module/utils/roles.dart';
import 'package:requirment_gathering_app/user_module/cart/data/order_dto.dart';
import 'package:requirment_gathering_app/user_module/cart/data/order_model.dart';
import 'package:requirment_gathering_app/user_module/cart/repo/order_repository.dart';
import 'package:requirment_gathering_app/user_module/cart/services/iorder_service.dart';

class OrderService implements IOrderService {
  final IOrderRepository orderRepository;
  final AccountRepository accountRepository;

  OrderService({
    required this.orderRepository,
    required this.accountRepository,
  });

  @override
  Future<void> placeOrder(Order order) async {
    final userInfo = await accountRepository.getUserInfo();
    final orderDto = OrderDto.fromModel(order);
    await orderRepository.addOrder(userInfo?.companyId ?? '', orderDto);
  }

  @override
  Future<List<Order>> getOrdersByUser() async {
    final userInfo = await accountRepository.getUserInfo();
    final orderDtos = await orderRepository.getOrdersByUser(
        userInfo?.companyId ?? '', userInfo?.userId ?? '');
    return orderDtos.map((dto) => Order.fromDto(dto)).toList();
  }

  @override
  Future<List<Order>> getAllOrders() async {
    final userInfo = await accountRepository.getUserInfo();
    final orderDtos = await orderRepository.getAllOrders(
        userInfo?.companyId ?? '',
        userInfo?.role == Role.COMPANY_ADMIN ? null : userInfo?.storeId);
    return orderDtos.map((dto) => Order.fromDto(dto)).toList();
  }

  @override
  Future<void> updateOrderStatus(String orderId, String status) async {
    final userInfo = await accountRepository.getUserInfo();
    await orderRepository.updateOrderStatus(
        userInfo?.companyId ?? '', orderId, status, userInfo?.userId);
  }

  @override
  Future<void> setExpectedDeliveryDate(String orderId, DateTime date) async {
    final userInfo = await accountRepository.getUserInfo();
    await orderRepository.setExpectedDeliveryDate(
        userInfo?.companyId ?? '', orderId, date, userInfo?.userId);
  }

  @override
  Future<Order> getOrderById(String orderId) async {
    final userInfo = await accountRepository.getUserInfo();
    final orderDto =
    await orderRepository.getOrderById(userInfo?.companyId ?? '', orderId);
    return Order.fromDto(orderDto);
  }

  @override
  Future<void> setOrderDeliveryDate(String orderId, DateTime date) async {
    final userInfo = await accountRepository.getUserInfo();
    await orderRepository.setOrderDeliveryDate(
        userInfo?.companyId ?? '', orderId, date, userInfo?.userId);
  }

  @override
  Future<void> setOrderDeliveredBy(String orderId, String? deliveredBy) async {
    final userInfo = await accountRepository.getUserInfo();
    await orderRepository.setOrderDeliveredBy(userInfo?.companyId ?? '',
        orderId, deliveredBy ?? userInfo?.userId, userInfo?.userId);
  }

  @override
  Future<void> setResponsibleForDelivery(
      String orderId, String responsibleForDelivery) async {
    final userInfo = await accountRepository.getUserInfo();
    await orderRepository.setResponsibleForDelivery(userInfo?.companyId ?? '',
        orderId, responsibleForDelivery, userInfo?.userId);
  }

  @override
  Future<void> updateOrder(Order order) async {
    final userInfo = await accountRepository.getUserInfo();
    final orderDto = OrderDto.fromModel(order);
    await orderRepository.updateOrder(userInfo?.companyId ?? '', orderDto);
  }
}