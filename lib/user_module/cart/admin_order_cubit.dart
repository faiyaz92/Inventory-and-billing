import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:requirment_gathering_app/user_module/cart/order_model.dart';
import 'package:requirment_gathering_app/user_module/cart/order_service.dart';

abstract class AdminOrderState {}

class AdminOrderInitial extends AdminOrderState {}

class AdminOrderLoading extends AdminOrderState {}

class AdminOrderLoaded extends AdminOrderState {
  final List<Order> orders;
  AdminOrderLoaded(this.orders);
}

class AdminOrderError extends AdminOrderState {
  final String message;
  AdminOrderError(this.message);
}

class AdminOrderCubit extends Cubit<AdminOrderState> {
  final OrderService orderService;

  AdminOrderCubit({required this.orderService}) : super(AdminOrderInitial());

  Future<void> fetchOrders(String companyId) async {
    emit(AdminOrderLoading());
    try {
      final orders = await orderService.getAllOrders(companyId);
      emit(AdminOrderLoaded(orders));
    } catch (e) {
      emit(AdminOrderError(e.toString()));
    }
  }

  Future<void> updateOrderStatus(String companyId, String orderId, String status) async {
    try {
      await orderService.updateOrderStatus(companyId, orderId, status);
      fetchOrders(companyId);
    } catch (e) {
      emit(AdminOrderError(e.toString()));
    }
  }

  Future<void> setExpectedDeliveryDate(String companyId, String orderId, DateTime date) async {
    try {
      await orderService.setExpectedDeliveryDate(companyId, orderId, date);
      fetchOrders(companyId);
    } catch (e) {
      emit(AdminOrderError(e.toString()));
    }
  }
}