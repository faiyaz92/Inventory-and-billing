import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:requirment_gathering_app/company_admin_module/data/purchase/admin_purchase_model.dart';
import 'package:requirment_gathering_app/company_admin_module/repositories/stock_repository.dart';
import 'package:requirment_gathering_app/company_admin_module/service/i_purchase_order.dart';
import 'package:requirment_gathering_app/company_admin_module/service/store_services.dart';
import 'package:requirment_gathering_app/company_admin_module/service/user_services.dart';
import 'package:requirment_gathering_app/core_module/utils/AppColor.dart';
import 'package:requirment_gathering_app/super_admin_module/data/user_info.dart';

abstract class AdminPurchaseState {}

class AdminPurchaseInitial extends AdminPurchaseState {}

class AdminPurchaseLoading extends AdminPurchaseState {}

class AdminPurchaseSuccess extends AdminPurchaseState {
  final AdminPurchaseOrder purchaseOrder;

  AdminPurchaseSuccess(this.purchaseOrder);
}

class AdminPurchaseError extends AdminPurchaseState {
  final String message;

  AdminPurchaseError(this.message);
}

class AdminPurchaseListFetchLoading extends AdminPurchaseState {}

class AdminPurchaseListFetchSuccess extends AdminPurchaseState {
  final List<AdminPurchaseOrder> purchaseOrders;
  final List<UserInfo> users;
  final List<StoreDto> stores;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? purchaseType;
  final String? paymentStatus;
  final String? invoiceLastUpdatedBy;
  final String? storeId;
  final String? supplierId;
  final double? minTotalAmount;
  final double? maxTotalAmount;
  final Map<String, List<AdminPurchaseOrder>> groupedPurchaseOrders;
  final String dateRangeLabel;
  final List<Map<String, dynamic>> statistics;
  final bool showTodayStats;

  AdminPurchaseListFetchSuccess({
    required this.purchaseOrders,
    required this.users,
    required this.stores,
    this.startDate,
    this.endDate,
    this.purchaseType,
    this.paymentStatus,
    this.invoiceLastUpdatedBy,
    this.storeId,
    this.supplierId,
    this.minTotalAmount,
    this.maxTotalAmount,
    required this.groupedPurchaseOrders,
    required this.dateRangeLabel,
    required this.statistics,
    required this.showTodayStats,
  });
}

class AdminPurchaseListFetchError extends AdminPurchaseState {
  final String message;

  AdminPurchaseListFetchError(this.message);
}

class AdminPurchaseFetchLoading extends AdminPurchaseState {}

class AdminPurchaseFetchSuccess extends AdminPurchaseState {
  final AdminPurchaseOrder purchaseOrder;
  final List<UserInfo> users;
  final String normalizedPaymentStatus;
  final double subtotal;
  final double totalTax;
  final String invoiceGeneratedDateFormatted;
  final String? invoiceLastUpdatedByName;

  AdminPurchaseFetchSuccess({
    required this.purchaseOrder,
    required this.users,
    required this.normalizedPaymentStatus,
    required this.subtotal,
    required this.totalTax,
    required this.invoiceGeneratedDateFormatted,
    this.invoiceLastUpdatedByName,
  });
}

class AdminPurchaseFetchError extends AdminPurchaseState {
  final String message;

  AdminPurchaseFetchError(this.message);
}

class AdminPurchaseCubit extends Cubit<AdminPurchaseState> {
  final IPurchaseOrderService purchaseOrderService;
  final UserServices userServices;
  final StoreService storeService;
  static final _dateFormatter = DateFormat('MMM dd, yyyy');
  static final _fullDateFormatter = DateFormat('yyyy-MM-dd HH:mm');
  String _searchQuery = '';

  AdminPurchaseCubit({
    required this.purchaseOrderService,
    required this.userServices,
    required this.storeService,
  }) : super(AdminPurchaseInitial());

  Future<void> createPurchaseOrder(AdminPurchaseOrder order) async {
    emit(AdminPurchaseLoading());
    try {
      await purchaseOrderService.placePurchaseOrder(order);
      await purchaseOrderService.placePurchaseInvoice(order);
      emit(AdminPurchaseSuccess(order));
    } catch (e) {
      emit(AdminPurchaseError('Failed to create purchase order: $e'));
    }
  }

  bool _isToday(DateTime? date) {
    if (date == null) return false;
    final today = DateTime.now();
    return date.year == today.year &&
        date.month == today.month &&
        date.day == today.day;
  }

  String _formatDateRange(DateTime? start, DateTime? end) {
    if (start == null || end == null) return 'All Purchase Orders';
    if (start.day == end.day &&
        start.month == end.month &&
        start.year == end.year) {
      return 'Invoiced on ${_dateFormatter.format(start)}';
    }
    return 'Invoiced between ${_dateFormatter.format(start)} and ${_dateFormatter.format(end)}';
  }

  String formatInvoiceDate(DateTime date) {
    return _dateFormatter.format(date);
  }

  String getProductNames(List<PurchaseItem> items) {
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

  Map<String, List<AdminPurchaseOrder>> _groupPurchaseOrdersByDate(
      List<AdminPurchaseOrder> purchaseOrders) {
    final grouped = <String, List<AdminPurchaseOrder>>{};
    for (var order in purchaseOrders) {
      final dateKey = order.invoiceGeneratedDate != null
          ? _dateFormatter.format(order.invoiceGeneratedDate!)
          : 'No Date';
      grouped.putIfAbsent(dateKey, () => []).add(order);
    }
    return grouped;
  }

  List<Map<String, dynamic>> _computeStatistics(
      List<AdminPurchaseOrder> purchaseOrders, bool showTodayStats) {
    final totalPurchaseOrders = purchaseOrders.length;
    final totalAmount = purchaseOrders.fold<double>(
        0.0, (sum, order) => sum + order.totalAmount);
    final newPurchaseOrders = purchaseOrders
        .where((order) => _isToday(order.invoiceGeneratedDate))
        .length;
    final cashPurchases = purchaseOrders
        .where((order) => order.purchaseType == 'Cash')
        .fold<double>(0.0, (sum, order) => sum + order.totalAmount);
    final creditPurchases = purchaseOrders
        .where((order) => order.purchaseType == 'Credit')
        .fold<double>(0.0, (sum, order) => sum + order.totalAmount);
    final paidPurchaseOrders =
        purchaseOrders.where((order) => order.paymentStatus == 'Paid').length;
    final partialPaidPurchaseOrders = purchaseOrders
        .where((order) => order.paymentStatus == 'Partial Paid')
        .length;
    final notPaidPurchaseOrders = purchaseOrders
        .where((order) => order.paymentStatus == 'Not Paid')
        .length;
    final totalPaidAmount = purchaseOrders
        .where((order) =>
    order.paymentStatus == 'Paid' || order.paymentStatus == 'Partial Paid')
        .fold<double>(
        0.0, (sum, order) => sum + (order.amountReceived ?? 0.0));
    final totalNotPaidAmount = purchaseOrders
        .where((order) =>
    order.paymentStatus == 'Not Paid' ||
        order.paymentStatus == 'Partial Paid')
        .fold<double>(0.0,
            (sum, order) => sum + (order.totalAmount - (order.amountReceived ?? 0.0)));

    return [
      {
        'label': 'Total Purchase Orders',
        'value': totalPurchaseOrders.toString(),
        'color': AppColors.textPrimary,
        'highlight': true
      },
      {
        'label': 'Total Amount',
        'value': totalAmount.toStringAsFixed(2),
        'color': AppColors.textPrimary,
        'highlight': true
      },
      {
        'label': 'Cash Purchases',
        'value': cashPurchases.toStringAsFixed(2),
        'color': Colors.green,
        'highlight': true
      },
      {
        'label': 'Credit Purchases',
        'value': creditPurchases.toStringAsFixed(2),
        'color': Colors.blue,
        'highlight': true
      },
      {
        'label': 'Paid',
        'value': paidPurchaseOrders.toString(),
        'color': Colors.green,
        'highlight': true
      },
      {
        'label': 'Partial Paid',
        'value': partialPaidPurchaseOrders.toString(),
        'color': Colors.orange,
        'highlight': true
      },
      {
        'label': 'Not Paid',
        'value': notPaidPurchaseOrders.toString(),
        'color': Colors.red,
        'highlight': true
      },
      {
        'label': 'Total Paid Amount',
        'value': totalPaidAmount.toStringAsFixed(2),
        'color': Colors.green,
        'highlight': true
      },
      {
        'label': 'Total Not Paid Amount',
        'value': totalNotPaidAmount.toStringAsFixed(2),
        'color': Colors.red,
        'highlight': true
      },
      if (showTodayStats)
        {
          'label': "Today's Purchase Orders",
          'value': newPurchaseOrders.toString(),
          'color': Colors.green,
          'highlight': true
        },
    ];
  }

  Map<String, Color> getStatusColors(String? status) {
    final normalizedStatus = status?.toLowerCase() ?? 'not paid';
    return {
      'color': normalizedStatus == 'paid'
          ? Colors.green
          : normalizedStatus == 'partial paid'
          ? Colors.orange
          : Colors.red,
      'backgroundColor': normalizedStatus == 'paid'
          ? Colors.green.withOpacity(0.1)
          : normalizedStatus == 'partial paid'
          ? Colors.orange.withOpacity(0.1)
          : Colors.red.withOpacity(0.1),
    };
  }

  String? getUserNameById(String? userId, List<UserInfo> users) {
    if (userId == null || userId.isEmpty) return null;
    return users
        .firstWhere(
          (user) => user.userId == userId,
      orElse: () => UserInfo(userId: userId, userName: 'Unknown'),
    )
        .userName ??
        'Unknown';
  }

  Future<void> fetchPurchaseOrders({
    DateTime? startDate,
    DateTime? endDate,
    String? purchaseType,
    String? paymentStatus,
    String? invoiceLastUpdatedBy,
    String? storeId,
    String? supplierId,
    double? minTotalAmount,
    double? maxTotalAmount,
  }) async {
    emit(AdminPurchaseListFetchLoading());
    try {
      final purchaseOrders = await purchaseOrderService.getAllPurchaseOrders(
        storeId: storeId,
        startDate: startDate,
        endDate: endDate,
        purchaseType: purchaseType,
        paymentStatus: paymentStatus,
        invoiceLastUpdatedBy: invoiceLastUpdatedBy,
        supplierId: supplierId,
        minTotalAmount: minTotalAmount,
        maxTotalAmount: maxTotalAmount,
        searchQuery: _searchQuery.isNotEmpty ? _searchQuery : null,
      );
      final users =
      await userServices.getUsersFromTenantCompany(storeId: storeId);
      final stores = await storeService.getStores();

      // Sort purchase orders by date (descending)
      purchaseOrders.sort((a, b) => (b.invoiceGeneratedDate ?? b.orderDate)
          .compareTo(a.invoiceGeneratedDate ?? a.orderDate));

      final showTodayStats = _shouldShowTodayStats(startDate, endDate);
      emit(AdminPurchaseListFetchSuccess(
        purchaseOrders: purchaseOrders,
        users: users,
        stores: stores,
        startDate: startDate,
        endDate: endDate,
        purchaseType: purchaseType,
        paymentStatus: paymentStatus,
        invoiceLastUpdatedBy: invoiceLastUpdatedBy,
        storeId: storeId,
        supplierId: supplierId,
        minTotalAmount: minTotalAmount,
        maxTotalAmount: maxTotalAmount,
        groupedPurchaseOrders: _groupPurchaseOrdersByDate(purchaseOrders),
        dateRangeLabel: _formatDateRange(startDate, endDate),
        statistics: _computeStatistics(purchaseOrders, showTodayStats),
        showTodayStats: showTodayStats,
      ));
    } catch (e) {
      emit(AdminPurchaseListFetchError(
          'Failed to fetch purchase orders: ${e.toString()}'));
    }
  }

  void filterPurchaseOrdersById(String query) {
    _searchQuery = query;
    if (state is AdminPurchaseListFetchSuccess) {
      final currentState = state as AdminPurchaseListFetchSuccess;
      // Trigger fetchPurchaseOrders with the updated search query
      fetchPurchaseOrders(
        startDate: currentState.startDate,
        endDate: currentState.endDate,
        purchaseType: currentState.purchaseType,
        paymentStatus: currentState.paymentStatus,
        invoiceLastUpdatedBy: currentState.invoiceLastUpdatedBy,
        storeId: currentState.storeId,
        supplierId: currentState.supplierId,
        minTotalAmount: currentState.minTotalAmount,
        maxTotalAmount: currentState.maxTotalAmount,
      );
    }
  }

  Future<void> fetchPurchaseOrderById(String purchaseOrderId) async {
    emit(AdminPurchaseFetchLoading());
    try {
      final purchaseOrder =
      await purchaseOrderService.getPurchaseOrderById(purchaseOrderId);
      final users = await userServices.getUsersFromTenantCompany();
      emit(AdminPurchaseFetchSuccess(
        purchaseOrder: purchaseOrder,
        users: users,
        normalizedPaymentStatus:
        purchaseOrder.paymentStatus?.toLowerCase() ?? 'not paid',
        subtotal: purchaseOrder.items
            .fold(0.0, (sum, item) => sum + (item.price * item.quantity)),
        totalTax:
        purchaseOrder.items.fold(0.0, (sum, item) => sum + item.taxAmount),
        invoiceGeneratedDateFormatted:
        purchaseOrder.invoiceGeneratedDate != null
            ? _fullDateFormatter.format(purchaseOrder.invoiceGeneratedDate!)
            : 'No Date',
        invoiceLastUpdatedByName:
        getUserNameById(purchaseOrder.invoiceLastUpdatedBy, users),
      ));
    } catch (e) {
      emit(AdminPurchaseFetchError(
          'Failed to fetch purchase order: ${e.toString()}'));
    }
  }
}