import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:requirment_gathering_app/company_admin_module/repositories/stock_repository.dart';
import 'package:requirment_gathering_app/company_admin_module/service/store_services.dart';
import 'package:requirment_gathering_app/company_admin_module/service/user_services.dart';
import 'package:requirment_gathering_app/core_module/utils/AppColor.dart';
import 'package:requirment_gathering_app/super_admin_module/data/user_info.dart';
import 'package:requirment_gathering_app/user_module/cart/data/order_model.dart';
import 'package:requirment_gathering_app/user_module/cart/services/iorder_service.dart';

abstract class AdminOrderState {}

class AdminOrderInitial extends AdminOrderState {}

// States for AdminPanelPage
class AdminOrderListFetchLoading extends AdminOrderState {}

class AdminOrderListFetchSuccess extends AdminOrderState {
  final List<Order> orders;
  final List<UserInfo> users;
  final List<StoreDto> stores; // Added
  final DateTime? startDate;
  final DateTime? endDate;
  final DateTime? expectedDeliveryStartDate;
  final DateTime? expectedDeliveryEndDate;
  final String? status;
  final String? orderTakenBy;
  final String? orderDeliveredBy;
  final String? storeId; // Added
  final DateTime? actualDeliveryStartDate; // Added
  final DateTime? actualDeliveryEndDate; // Added
  final String? userId; // Added
  final double? minTotalAmount; // Added
  final double? maxTotalAmount; // Added
  final Map<String, List<Order>> groupedOrders;
  final String dateRangeLabel;
  final String expectedDeliveryRangeLabel;
  final List<Map<String, dynamic>> statistics;
  final bool showTodayStats;

  AdminOrderListFetchSuccess({
    required this.orders,
    required this.users,
    required this.stores, // Added
    this.startDate,
    this.endDate,
    this.expectedDeliveryStartDate,
    this.expectedDeliveryEndDate,
    this.status,
    this.orderTakenBy,
    this.orderDeliveredBy,
    this.storeId, // Added
    this.actualDeliveryStartDate, // Added
    this.actualDeliveryEndDate, // Added
    this.userId, // Added
    this.minTotalAmount, // Added
    this.maxTotalAmount, // Added
    required this.groupedOrders,
    required this.dateRangeLabel,
    required this.expectedDeliveryRangeLabel,
    required this.statistics,
    required this.showTodayStats,
  });
}
class AdminOrderListFetchError extends AdminOrderState {
  final String message;
  AdminOrderListFetchError(this.message);
}

// States for AdminOrderDetailsPage (unchanged)
class AdminOrderFetchLoading extends AdminOrderState {}

class AdminOrderFetchSuccess extends AdminOrderState {
  final Order order;
  final List<UserInfo> users;
  final String normalizedStatus;
  final double subtotal;
  final double totalTax;
  final String orderDateFormatted;
  final String? expectedDeliveryDateFormatted;
  final String? orderDeliveryDateFormatted; // Added
  final String? orderTakenByName;
  final String? lastUpdatedByName;
  final String? responsibleForDeliveryName;
  final String? orderDeliveredByName;

  AdminOrderFetchSuccess({
    required this.order,
    required this.users,
    required this.normalizedStatus,
    required this.subtotal,
    required this.totalTax,
    required this.orderDateFormatted,
    this.expectedDeliveryDateFormatted,
    this.orderDeliveryDateFormatted, // Added
    this.orderTakenByName,
    this.lastUpdatedByName,
    this.responsibleForDeliveryName,
    this.orderDeliveredByName,
  });
}




class AdminOrderFetchError extends AdminOrderState {
  final String message;
  AdminOrderFetchError(this.message);
}

class AdminOrderUpdateStatusLoading extends AdminOrderState {}

class AdminOrderUpdateStatusSuccess extends AdminOrderState {}

class AdminOrderUpdateStatusError extends AdminOrderState {
  final String message;
  AdminOrderUpdateStatusError(this.message);
}

class AdminOrderSetDeliveryDateLoading extends AdminOrderState {}

class AdminOrderSetDeliveryDateSuccess extends AdminOrderState {}

class AdminOrderSetDeliveryDateError extends AdminOrderState {
  final String message;
  AdminOrderSetDeliveryDateError(this.message);
}

class AdminOrderSetResponsibleLoading extends AdminOrderState {}

class AdminOrderSetResponsibleSuccess extends AdminOrderState {}

class AdminOrderSetResponsibleError extends AdminOrderState {
  final String message;
  AdminOrderSetResponsibleError(this.message);
}

class AdminOrderSetDeliveredByLoading extends AdminOrderState {}

class AdminOrderSetDeliveredBySuccess extends AdminOrderState {}

class AdminOrderSetDeliveredByError extends AdminOrderState {
  final String message;
  AdminOrderSetDeliveredByError(this.message);
}

class AdminOrderCubit extends Cubit<AdminOrderState> {
  final IOrderService orderService;
  final UserServices employeeServices;
  final StoreService storeService;
  static final _dateFormatter = DateFormat('MMM dd, yyyy');
  static final _fullDateFormatter = DateFormat('yyyy-MM-dd HH:mm');

  AdminOrderCubit({
    required this.orderService,
    required this.employeeServices,
    required this.storeService,
  }) : super(AdminOrderInitial());

  bool _isToday(DateTime? date) {
    if (date == null) return false;
    final today = DateTime.now();
    return date.year == today.year &&
        date.month == today.month &&
        date.day == today.day;
  }

  String _formatDateRange(DateTime? start, DateTime? end) {
    if (start == null || end == null) return 'All Orders';
    if (start.day == end.day &&
        start.month == end.month &&
        start.year == end.year) {
      return 'Ordered on ${_dateFormatter.format(start)}';
    }
    return 'Ordered between ${_dateFormatter.format(start)} and ${_dateFormatter.format(end)}';
  }

  String _formatExpectedDeliveryRange(DateTime? start, DateTime? end) {
    if (start == null || end == null) return 'All Orders';
    if (start.day == end.day &&
        start.month == end.month &&
        start.year == end.year) {
      return 'Expected Delivery on ${_dateFormatter.format(start)}';
    }
    return 'Expected Delivery between ${_dateFormatter.format(start)} and ${_dateFormatter.format(end)}';
  }

  String formatOrderDate(DateTime date) {
    return _dateFormatter.format(date);
  }

  String getProductNames(List<CartItem> items) {
    return items.map((item) => item.productName).join(', ');
  }

  bool _shouldShowTodayStats(DateTime? start, DateTime? end) {
    if (start == null || end == null) return true;
    final today = DateTime.now();
    return start.year == today.year &&
        start.month == today.month &&
        start.day == today.day &&
        end.year == today.year &&
        end.month == today.month &&
        end.day == today.day;
  }

  Map<String, List<Order>> _groupOrdersByDate(List<Order> orders) {
    final grouped = <String, List<Order>>{};
    for (var order in orders) {
      final dateKey = _dateFormatter.format(order.orderDate);
      grouped.putIfAbsent(dateKey, () => []).add(order);
    }
    return grouped;
  }

  List<Map<String, dynamic>> _computeStatistics(
      List<Order> orders, bool showTodayStats) {
    final totalOrders = orders.length;
    final totalAmount =
    orders.fold<double>(0.0, (sum, order) => sum + order.totalAmount);
    final newOrders = orders.where((order) => _isToday(order.orderDate)).length;
    final pendingOrders =
        orders.where((order) => order.status.toLowerCase() == 'pending').length;
    final processingOrders =
        orders.where((order) => order.status.toLowerCase() == 'processing').length;
    final shippedOrders =
        orders.where((order) => order.status.toLowerCase() == 'shipped').length;
    final completedOrders =
        orders.where((order) => order.status.toLowerCase() == 'completed').length;
    final notCompletedOrders = totalOrders - completedOrders;
    final todayExpectedDeliveryCount =
        orders.where((order) => _isToday(order.expectedDeliveryDate)).length;
    final todayCompletedDeliveryCount = orders
        .where((order) =>
    order.status.toLowerCase() == 'completed' &&
        _isToday(order.orderDeliveryDate))
        .length;

    return [
      {
        'label': 'Total Orders',
        'value': totalOrders.toString(),
        'color': AppColors.textPrimary,
        'highlight': true
      },
      {
        'label': 'Total Amount',
        'value': '₹${totalAmount.toStringAsFixed(2)}',
        'color': AppColors.textPrimary,
        'highlight': true
      },
      {
        'label': 'Pending',
        'value': pendingOrders.toString(),
        'color': Colors.orange,
        'highlight': true
      },
      {
        'label': 'Processing',
        'value': processingOrders.toString(),
        'color': Colors.blue,
        'highlight': true
      },
      {
        'label': 'Shipped',
        'value': shippedOrders.toString(),
        'color': AppColors.textSecondary,
        'highlight': false
      },
      {
        'label': 'Completed',
        'value': completedOrders.toString(),
        'color': AppColors.textSecondary,
        'highlight': false
      },
      {
        'label': 'Completed vs Not Completed',
        'value': '$completedOrders/$notCompletedOrders',
        'color': Colors.purple,
        'highlight': true
      },
      if (showTodayStats)
        {
          'label': "Today's Orders",
          'value': newOrders.toString(),
          'color': Colors.green,
          'highlight': true
        },
      {
        'label': "Today's Expected",
        'value': todayExpectedDeliveryCount.toString(),
        'color': AppColors.textSecondary,
        'highlight': false
      },
      {
        'label': "Today's Completed",
        'value': todayCompletedDeliveryCount.toString(),
        'color': AppColors.textSecondary,
        'highlight': true
      },
    ];
  }

  Map<String, Color> getStatusColors(String status) {
    final normalizedStatus = status.toLowerCase();
    return {
      'color': normalizedStatus == 'pending'
          ? Colors.orange
          : normalizedStatus == 'processing'
          ? Colors.blue
          : AppColors.textSecondary,
      'backgroundColor': normalizedStatus == 'pending'
          ? Colors.orange.withOpacity(0.1)
          : normalizedStatus == 'processing'
          ? Colors.blue.withOpacity(0.1)
          : Colors.transparent,
    };
  }

  String? getUserNameById(String? userId, List<UserInfo> users) {
    if (userId == null || userId.isEmpty) return null;
    return users.firstWhere(
          (user) => user.userId == userId,
      orElse: () => UserInfo(userId: userId, userName: 'Unknown'),
    ).userName ?? 'Unknown';
  }

  Future<void> fetchOrders({
    DateTime? startDate,
    DateTime? endDate,
    String? status,
    DateTime? expectedDeliveryStartDate,
    DateTime? expectedDeliveryEndDate,
    String? orderTakenBy,
    String? orderDeliveredBy,
    String? storeId,
    DateTime? actualDeliveryStartDate,
    DateTime? actualDeliveryEndDate,
    String? userId,
    double? minTotalAmount,
    double? maxTotalAmount,
  }) async {
    emit(AdminOrderListFetchLoading());
    try {
      final orders = await orderService.getAllOrders();
      final users = await employeeServices.getUsersFromTenantCompany(storeId: storeId);
      final stores = await storeService.getStores();

      orders.sort((a, b) => b.orderDate.compareTo(a.orderDate));
      List<Order> filteredOrders = orders;

      if (startDate != null && endDate != null) {
        filteredOrders = filteredOrders.where((order) {
          return order.orderDate.isAfter(startDate.subtract(const Duration(days: 1))) &&
              order.orderDate.isBefore(endDate.add(const Duration(days: 1)));
        }).toList();
      }

      if (status != null) {
        filteredOrders = filteredOrders
            .where((order) => order.status.toLowerCase() == status.toLowerCase())
            .toList();
      }

      if (expectedDeliveryStartDate != null && expectedDeliveryEndDate != null) {
        filteredOrders = filteredOrders.where((order) {
          if (order.expectedDeliveryDate == null) return false;
          return order.expectedDeliveryDate!.isAfter(
              expectedDeliveryStartDate.subtract(const Duration(days: 1))) &&
              order.expectedDeliveryDate!.isBefore(
                  expectedDeliveryEndDate.add(const Duration(days: 1)));
        }).toList();
      }

      if (orderTakenBy != null) {
        filteredOrders = filteredOrders
            .where((order) => order.orderTakenBy == orderTakenBy)
            .toList();
      }

      if (orderDeliveredBy != null) {
        filteredOrders = filteredOrders
            .where((order) => order.orderDeliveredBy == orderDeliveredBy)
            .toList();
      }

      if (storeId != null) {
        filteredOrders = filteredOrders.where((order) => order.storeId == storeId).toList();
      }

      if (actualDeliveryStartDate != null && actualDeliveryEndDate != null) {
        filteredOrders = filteredOrders.where((order) {
          if (order.orderDeliveryDate == null) return false;
          return order.orderDeliveryDate!.isAfter(
              actualDeliveryStartDate.subtract(const Duration(days: 1))) &&
              order.orderDeliveryDate!.isBefore(
                  actualDeliveryEndDate.add(const Duration(days: 1)));
        }).toList();
      }

      if (userId != null) {
        filteredOrders = filteredOrders.where((order) => order.userId == userId).toList();
      }

      if (minTotalAmount != null && maxTotalAmount != null) {
        filteredOrders = filteredOrders.where((order) =>
        order.totalAmount >= minTotalAmount && order.totalAmount <= maxTotalAmount).toList();
      }

      final showTodayStats = _shouldShowTodayStats(startDate, endDate);
      emit(AdminOrderListFetchSuccess(
        orders: filteredOrders,
        users: users,
        stores: stores,
        startDate: startDate,
        endDate: endDate,
        expectedDeliveryStartDate: expectedDeliveryStartDate,
        expectedDeliveryEndDate: expectedDeliveryEndDate,
        status: status,
        orderTakenBy: orderTakenBy,
        orderDeliveredBy: orderDeliveredBy,
        storeId: storeId,
        actualDeliveryStartDate: actualDeliveryStartDate,
        actualDeliveryEndDate: actualDeliveryEndDate,
        userId: userId,
        minTotalAmount: minTotalAmount,
        maxTotalAmount: maxTotalAmount,
        groupedOrders: _groupOrdersByDate(filteredOrders),
        dateRangeLabel: _formatDateRange(startDate, endDate),
        expectedDeliveryRangeLabel: _formatExpectedDeliveryRange(
            expectedDeliveryStartDate, expectedDeliveryEndDate),
        statistics: _computeStatistics(filteredOrders, showTodayStats),
        showTodayStats: showTodayStats,
      ));
    } catch (e) {
      emit(AdminOrderListFetchError('Failed to fetch orders: ${e.toString()}'));
    }
  }

  Future<void> fetchOrderById(String orderId) async {
    emit(AdminOrderFetchLoading());
    try {
      final order = await orderService.getOrderById(orderId);
      final users = await employeeServices.getUsersFromTenantCompany();
      emit(AdminOrderFetchSuccess(
        order: order,
        users: users,
        normalizedStatus: order.status.toLowerCase(),
        subtotal: order.items.fold(
            0.0, (sum, item) => sum + (item.price * item.quantity)),
        totalTax: order.items.fold(0.0, (sum, item) => sum + item.taxAmount),
        orderDateFormatted: _fullDateFormatter.format(order.orderDate),
        expectedDeliveryDateFormatted: order.expectedDeliveryDate != null
            ? _fullDateFormatter.format(order.expectedDeliveryDate!)
            : null,
        orderDeliveryDateFormatted: order.orderDeliveryDate != null // Added
            ? _fullDateFormatter.format(order.orderDeliveryDate!)
            : null,
        orderTakenByName: getUserNameById(order.orderTakenBy, users),
        lastUpdatedByName: getUserNameById(order.lastUpdatedBy, users),
        responsibleForDeliveryName:
        getUserNameById(order.responsibleForDelivery, users),
        orderDeliveredByName: getUserNameById(order.orderDeliveredBy, users),
      ));
    } catch (e) {
      emit(AdminOrderFetchError('Failed to fetch order: ${e.toString()}'));
    }
  }
  Future<void> updateOrderStatus(String orderId, String status) async {
    emit(AdminOrderUpdateStatusLoading());
    try {
      await orderService.updateOrderStatus(orderId, status);
      if (status.toLowerCase() == 'completed') {
        await orderService.setOrderDeliveryDate(orderId, DateTime.now());
        await orderService.setOrderDeliveredBy(orderId, null);
      }
      emit(AdminOrderUpdateStatusSuccess());
      await fetchOrderById(orderId);
    } catch (e) {
      emit(AdminOrderUpdateStatusError(
          'Failed to update order status: ${e.toString()}'));
    }
  }

  Future<void> setExpectedDeliveryDate(String orderId, DateTime date) async {
    emit(AdminOrderSetDeliveryDateLoading());
    try {
      await orderService.setExpectedDeliveryDate(orderId, date);
      emit(AdminOrderSetDeliveryDateSuccess());
      await fetchOrderById(orderId);
    } catch (e) {
      emit(AdminOrderSetDeliveryDateError(
          'Failed to set expected delivery date: ${e.toString()}'));
    }
  }

  Future<void> setOrderDeliveredBy(String orderId, String deliveredBy) async {
    emit(AdminOrderSetDeliveredByLoading());
    try {
      await orderService.setOrderDeliveredBy(orderId, deliveredBy);
      emit(AdminOrderSetDeliveredBySuccess());
      await fetchOrderById(orderId);
    } catch (e) {
      emit(AdminOrderSetDeliveredByError(
          'Failed to set delivery person: ${e.toString()}'));
    }
  }

  Future<void> setResponsibleForDelivery(
      String orderId, String responsibleForDelivery) async {
    emit(AdminOrderSetResponsibleLoading());
    try {
      await orderService.setResponsibleForDelivery(
          orderId, responsibleForDelivery);
      emit(AdminOrderSetResponsibleSuccess());
      await fetchOrderById(orderId);
    } catch (e) {
      emit(AdminOrderSetResponsibleError(
          'Failed to set responsible for delivery: ${e.toString()}'));
    }
  }
}