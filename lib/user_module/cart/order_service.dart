
import 'package:requirment_gathering_app/user_module/cart/order_dto.dart';
import 'package:requirment_gathering_app/user_module/cart/order_model.dart';
import 'package:requirment_gathering_app/user_module/cart/order_repository.dart';

class OrderService {
  final IOrderRepository orderRepository;

  OrderService({required this.orderRepository});

  Future<void> placeOrder(String companyId, Order order) async {
    final orderDto = OrderDto.fromModel(order);
    await orderRepository.addOrder(companyId, orderDto);
  }

  Future<List<Order>> getOrdersByUser(String companyId, String userId) async {
    final orderDtos = await orderRepository.getOrdersByUser(companyId, userId);
    return orderDtos.map((dto) => Order.fromDto(dto)).toList();
  }

  Future<List<Order>> getAllOrders(String companyId) async {
    final orderDtos = await orderRepository.getAllOrders(companyId);
    return orderDtos.map((dto) => Order.fromDto(dto)).toList();
  }

  Future<void> updateOrderStatus(String companyId, String orderId, String status) async {
    await orderRepository.updateOrderStatus(companyId, orderId, status);
  }

  Future<void> setExpectedDeliveryDate(String companyId, String orderId, DateTime date) async {
    await orderRepository.setExpectedDeliveryDate(companyId, orderId, date);
  }
}