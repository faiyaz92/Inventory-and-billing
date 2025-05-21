import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:requirment_gathering_app/user_module/cart/services/iorder_service.dart';
import 'package:requirment_gathering_app/user_module/cart/data/order_model.dart';
import 'package:requirment_gathering_app/user_module/cart/services/order_service.dart';

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
  final IOrderService orderService;

  AdminOrderCubit({required this.orderService}) : super(AdminOrderInitial());

  Future<void> fetchOrders({
    DateTime? startDate,
    DateTime? endDate,
    String? status,
    DateTime? expectedDeliveryStartDate,
    DateTime? expectedDeliveryEndDate,
  }) async {
    emit(AdminOrderLoading());
    try {
      final orders = await orderService.getAllOrders();
      // Sort orders by orderDate in descending order (latest first)
      orders.sort((a, b) => b.orderDate.compareTo(a.orderDate));
      // Apply date range filter for orderDate if provided
      List<Order> filteredOrders = orders;
      if (startDate != null && endDate != null) {
        filteredOrders = filteredOrders.where((order) {
          return order.orderDate.isAfter(startDate.subtract(const Duration(days: 1))) &&
              order.orderDate.isBefore(endDate.add(const Duration(days: 1)));
        }).toList();
      }
      // Apply status filter if provided
      if (status != null) {
        filteredOrders = filteredOrders.where((order) => order.status.toLowerCase() == status.toLowerCase()).toList();
      }
      // Apply expected delivery date filter if provided
      if (expectedDeliveryStartDate != null && expectedDeliveryEndDate != null) {
        filteredOrders = filteredOrders.where((order) {
          // Skip orders where expectedDeliveryDate is null
          if (order.expectedDeliveryDate == null) return false;
          return order.expectedDeliveryDate!.isAfter(expectedDeliveryStartDate.subtract(const Duration(days: 1))) &&
              order.expectedDeliveryDate!.isBefore(expectedDeliveryEndDate.add(const Duration(days: 1)));
        }).toList();
      }
      emit(AdminOrderLoaded(filteredOrders));
    } catch (e) {
      emit(AdminOrderError(e.toString()));
    }
  }

  Future<void> updateOrderStatus(String orderId, String status, {String? deliveredBy}) async {
    try {
      await orderService.updateOrderStatus(orderId, status);
      if (status.toLowerCase() == 'completed' /*&& deliveredBy != null*/) {
        await orderService.setOrderDeliveryDate(orderId, DateTime.now());
        // await orderService.setOrderDeliveredBy(orderId, deliveredBy);
      }
      fetchOrders();
    } catch (e) {
      emit(AdminOrderError(e.toString()));
    }
  }

  Future<void> setExpectedDeliveryDate(String orderId, DateTime date) async {
    try {
      await orderService.setExpectedDeliveryDate(orderId, date);
      fetchOrders();
    } catch (e) {
      emit(AdminOrderError(e.toString()));
    }
  }

  Future<void> fetchOrderById(String orderId) async {
    emit(AdminOrderLoading());
    try {
      final order = await orderService.getOrderById(orderId);
      emit(AdminOrderLoaded([order]));
    } catch (e) {
      emit(AdminOrderError(e.toString()));
    }
  }
}