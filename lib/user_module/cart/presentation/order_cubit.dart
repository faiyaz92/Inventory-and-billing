import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:requirment_gathering_app/core_module/repository/account_repository.dart';
import 'package:requirment_gathering_app/user_module/cart/data/order_model.dart';
import 'package:requirment_gathering_app/user_module/cart/services/iorder_service.dart';
import 'package:requirment_gathering_app/user_module/cart/services/order_service.dart';

abstract class OrderState {}

class OrderInitial extends OrderState {}

class OrderLoading extends OrderState {}

class OrderLoaded extends OrderState {
  final List<Order> orders;

  OrderLoaded(this.orders);
}

class OrderError extends OrderState {
  final String message;

  OrderError(this.message);
}

class OrderPlaced extends OrderState {}

class OrderCubit extends Cubit<OrderState> {
  final IOrderService orderService;
  final AccountRepository accountRepository;

  OrderCubit({
    required this.orderService,
    required this.accountRepository,
  }) : super(OrderInitial());

  Future<void> fetchOrders({DateTime? startDate, DateTime? endDate}) async {
    emit(OrderLoading());
    try {
      final orders = await orderService.getOrdersByUser();
      // Sort orders by orderDate in descending order (latest first)
      orders.sort((a, b) => b.orderDate.compareTo(a.orderDate));
      // Apply date range filter if provided
      List<Order> filteredOrders = orders;
      if (startDate != null && endDate != null) {
        filteredOrders = orders.where((order) {
          return order.orderDate.isAfter(startDate.subtract(const Duration(days: 1))) &&
              order.orderDate.isBefore(endDate.add(const Duration(days: 1)));
        }).toList();
      }
      emit(OrderLoaded(filteredOrders));
    } catch (e) {
      emit(OrderError(e.toString()));
    }
  }

  Future<void> placeOrder(Order order1) async {
    emit(OrderLoading());
    try {
      final userInfo = await accountRepository.getUserInfo();
      if (userInfo == null) throw Exception('User not logged in');
      final order = Order(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: userInfo.userId ?? '',
        userName: userInfo.userName ?? '',
        items: order1.items,
        totalAmount: order1.totalAmount,
        status: 'Pending',
        orderDate: DateTime.now(),
      );
      await orderService.placeOrder(order);
      emit(OrderPlaced());
    } catch (e) {
      emit(OrderError(e.toString()));
    }
  }
  Future<void> placeOrderBySalesMan(Order order) async {
    emit(OrderLoading());
    try {
      final userInfo = await accountRepository.getUserInfo();
      if (userInfo == null) throw Exception('User not logged in');
      await orderService.placeOrder(order);
      emit(OrderPlaced());
    } catch (e) {
      emit(OrderError(e.toString()));
    }
  }

  Future<void> fetchOrderById(String orderId) async {
    emit(OrderLoading());
    try {
      final order = await orderService.getOrderById(orderId);
      emit(OrderLoaded([order]));
    } catch (e) {
      emit(OrderError(e.toString()));
    }
  }
}