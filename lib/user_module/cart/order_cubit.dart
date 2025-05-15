import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:requirment_gathering_app/core_module/repository/account_repository.dart';
import 'package:requirment_gathering_app/user_module/cart/order_model.dart';
import 'package:requirment_gathering_app/user_module/cart/order_service.dart';

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
  final OrderService orderService;
  final AccountRepository accountRepository;

  OrderCubit({
    required this.orderService,
    required this.accountRepository,
  }) : super(OrderInitial());

  Future<void> fetchOrders(String companyId, String userId) async {
    emit(OrderLoading());
    try {
      final orders = await orderService.getOrdersByUser(companyId, userId);
      emit(OrderLoaded(orders));
    } catch (e) {
      emit(OrderError(e.toString()));
    }
  }

  Future<void> placeOrder(String companyId, List<CartItem> items, double totalAmount) async {
    emit(OrderLoading());
    try {
      final userInfo = await accountRepository.getUserInfo();
      if (userInfo == null) throw Exception('User not logged in');
      final order = Order(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: userInfo.userId??'',
        userName: userInfo.userName??'',
        items: items,
        totalAmount: totalAmount,
        status: 'Pending',
        orderDate: DateTime.now(),
      );
      await orderService.placeOrder(companyId, order);
      emit(OrderPlaced());
    } catch (e) {
      emit(OrderError(e.toString()));
    }
  }
}