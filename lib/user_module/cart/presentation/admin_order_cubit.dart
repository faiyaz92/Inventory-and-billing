import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:requirment_gathering_app/company_admin_module/service/employee_services.dart';
import 'package:requirment_gathering_app/super_admin_module/data/user_info.dart';
import 'package:requirment_gathering_app/user_module/cart/services/iorder_service.dart';
import 'package:requirment_gathering_app/user_module/cart/data/order_model.dart';

abstract class AdminOrderState {}

class AdminOrderInitial extends AdminOrderState {}

class AdminOrderLoading extends AdminOrderState {}

class AdminOrderLoaded extends AdminOrderState {
  final List<Order> orders;
  final List<UserInfo> users;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? status;
  final DateTime? expectedDeliveryStartDate;
  final DateTime? expectedDeliveryEndDate;

  AdminOrderLoaded(
      this.orders,
      this.users, {
        this.startDate,
        this.endDate,
        this.status,
        this.expectedDeliveryStartDate,
        this.expectedDeliveryEndDate,
      });
}

class AdminOrderError extends AdminOrderState {
  final String message;
  AdminOrderError(this.message);
}

class AdminOrderCubit extends Cubit<AdminOrderState> {
  final IOrderService orderService;
  final EmployeeServices employeeServices;

  AdminOrderCubit({
    required this.orderService,
    required this.employeeServices,
  }) : super(AdminOrderInitial());

  Future<void> fetchOrders({
    DateTime? startDate,
    DateTime? endDate,
    String? status,
    DateTime? expectedDeliveryStartDate,
    DateTime? expectedDeliveryEndDate,
  }) async {
    emit(AdminOrderLoading());
    try {
      // Fetch orders
      final orders = await orderService.getAllOrders();
      orders.sort((a, b) => b.orderDate.compareTo(a.orderDate));
      List<Order> filteredOrders = orders;

      // Apply date range filter for orderDate if provided
      if (startDate != null && endDate != null) {
        filteredOrders = filteredOrders.where((order) {
          return order.orderDate
              .isAfter(startDate.subtract(const Duration(days: 1))) &&
              order.orderDate.isBefore(endDate.add(const Duration(days: 1)));
        }).toList();
      }

      // Apply status filter if provided
      if (status != null) {
        filteredOrders = filteredOrders
            .where((order) => order.status.toLowerCase() == status.toLowerCase())
            .toList();
      }

      // Apply expected delivery date filter if provided
      if (expectedDeliveryStartDate != null && expectedDeliveryEndDate != null) {
        filteredOrders = filteredOrders.where((order) {
          if (order.expectedDeliveryDate == null) return false;
          return order.expectedDeliveryDate!.isAfter(
              expectedDeliveryStartDate.subtract(const Duration(days: 1))) &&
              order.expectedDeliveryDate!.isBefore(
                  expectedDeliveryEndDate.add(const Duration(days: 1)));
        }).toList();
      }

      // Fetch users for dropdowns
      final users = await employeeServices.getUsersFromTenantCompany();

      emit(AdminOrderLoaded(
        filteredOrders,
        users,
        startDate: startDate,
        endDate: endDate,
        status: status,
        expectedDeliveryStartDate: expectedDeliveryStartDate,
        expectedDeliveryEndDate: expectedDeliveryEndDate,
      ));
    } catch (e) {
      emit(AdminOrderError('Failed to fetch orders: ${e.toString()}'));
    }
  }

  Future<void> fetchOrderById(String orderId) async {
    emit(AdminOrderLoading());
    try {
      final order = await orderService.getOrderById(orderId);
      final users = await employeeServices.getUsersFromTenantCompany();
      emit(AdminOrderLoaded([order], users));
    } catch (e) {
      emit(AdminOrderError('Failed to fetch order: ${e.toString()}'));
    }
  }

  Future<void> updateOrderStatus(String orderId, String status,
      {String? deliveredBy}) async {
    try {
      await orderService.updateOrderStatus(orderId, status);
      if (status.toLowerCase() == 'completed' && deliveredBy != null) {
        await orderService.setOrderDeliveryDate(orderId, DateTime.now());
        await orderService.setOrderDeliveredBy(orderId, deliveredBy);
      }
      fetchOrders();
    } catch (e) {
      emit(AdminOrderError('Failed to update order status: ${e.toString()}'));
    }
  }

  Future<void> setExpectedDeliveryDate(String orderId, DateTime date) async {
    try {
      await orderService.setExpectedDeliveryDate(orderId, date);
      fetchOrders();
    } catch (e) {
      emit(AdminOrderError('Failed to set expected delivery date: ${e.toString()}'));
    }
  }

  Future<void> setOrderDeliveredBy(String orderId, String deliveredBy) async {
    try {
      await orderService.setOrderDeliveredBy(orderId, deliveredBy);
      fetchOrderById(orderId);
    } catch (e) {
      emit(AdminOrderError('Failed to set delivery person: ${e.toString()}'));
    }
  }

  Future<void> setResponsibleForDelivery(
      String orderId, String responsibleForDelivery) async {
    try {
      await orderService.setResponsibleForDelivery(orderId, responsibleForDelivery);
      fetchOrderById(orderId);
    } catch (e) {
      emit(AdminOrderError('Failed to set responsible for delivery: ${e.toString()}'));
    }
  }
}