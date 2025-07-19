import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:requirment_gathering_app/company_admin_module/repositories/stock_repository.dart';
import 'package:requirment_gathering_app/company_admin_module/service/store_services.dart';
import 'package:requirment_gathering_app/core_module/utils/AppColor.dart';
import 'package:requirment_gathering_app/super_admin_module/data/user_info.dart';
import 'package:requirment_gathering_app/user_module/cart/data/order_model.dart';
import 'package:requirment_gathering_app/user_module/cart/services/iorder_service.dart';
import 'package:requirment_gathering_app/company_admin_module/service/user_services.dart';

abstract class AdminInvoiceState {}

class AdminInvoiceInitial extends AdminInvoiceState {}

class AdminInvoiceListFetchLoading extends AdminInvoiceState {}

class AdminInvoiceListFetchSuccess extends AdminInvoiceState {
  final List<Order> invoices;
  final List<UserInfo> users;
  final List<StoreDto> stores;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? invoiceType;
  final String? paymentStatus;
  final String? invoiceLastUpdatedBy;
  final String? storeId;
  final String? userId;
  final double? minTotalAmount;
  final double? maxTotalAmount;
  final Map<String, List<Order>> groupedInvoices;
  final String dateRangeLabel;
  final List<Map<String, dynamic>> statistics;
  final bool showTodayStats;

  AdminInvoiceListFetchSuccess({
    required this.invoices,
    required this.users,
    required this.stores,
    this.startDate,
    this.endDate,
    this.invoiceType,
    this.paymentStatus,
    this.invoiceLastUpdatedBy,
    this.storeId,
    this.userId,
    this.minTotalAmount,
    this.maxTotalAmount,
    required this.groupedInvoices,
    required this.dateRangeLabel,
    required this.statistics,
    required this.showTodayStats,
  });
}

class AdminInvoiceListFetchError extends AdminInvoiceState {
  final String message;
  AdminInvoiceListFetchError(this.message);
}

class AdminInvoiceFetchLoading extends AdminInvoiceState {}

class AdminInvoiceFetchSuccess extends AdminInvoiceState {
  final Order invoice;
  final List<UserInfo> users;
  final String normalizedPaymentStatus;
  final double subtotal;
  final double totalTax;
  final String invoiceGeneratedDateFormatted;
  final String? invoiceLastUpdatedByName;

  AdminInvoiceFetchSuccess({
    required this.invoice,
    required this.users,
    required this.normalizedPaymentStatus,
    required this.subtotal,
    required this.totalTax,
    required this.invoiceGeneratedDateFormatted,
    this.invoiceLastUpdatedByName,
  });
}

class AdminInvoiceFetchError extends AdminInvoiceState {
  final String message;
  AdminInvoiceFetchError(this.message);
}

class AdminInvoiceCubit extends Cubit<AdminInvoiceState> {
  final IOrderService orderService;
  final UserServices employeeServices;
  final StoreService storeService;
  static final _dateFormatter = DateFormat('MMM dd, yyyy');
  static final _fullDateFormatter = DateFormat('yyyy-MM-dd HH:mm');
  String _searchQuery = '';
  List<Order> _allInvoices = [];

  AdminInvoiceCubit({
    required this.orderService,
    required this.employeeServices,
    required this.storeService,
  }) : super(AdminInvoiceInitial());

  bool _isToday(DateTime? date) {
    if (date == null) return false;
    final today = DateTime.now();
    return date.year == today.year &&
        date.month == today.month &&
        date.day == today.day;
  }

  String _formatDateRange(DateTime? start, DateTime? end) {
    if (start == null || end == null) return 'All Invoices';
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

  Map<String, List<Order>> _groupInvoicesByDate(List<Order> invoices) {
    final grouped = <String, List<Order>>{};
    for (var invoice in invoices) {
      final dateKey = invoice.invoiceGeneratedDate != null
          ? _dateFormatter.format(invoice.invoiceGeneratedDate!)
          : 'No Date';
      grouped.putIfAbsent(dateKey, () => []).add(invoice);
    }
    return grouped;
  }

  List<Map<String, dynamic>> _computeStatistics(
      List<Order> invoices, bool showTodayStats) {
    final totalInvoices = invoices.length;
    final totalAmount =
    invoices.fold<double>(0.0, (sum, invoice) => sum + invoice.totalAmount);
    final newInvoices =
        invoices.where((invoice) => _isToday(invoice.invoiceGeneratedDate)).length;
    final cashSales = invoices
        .where((invoice) => invoice.invoiceType == 'Cash')
        .fold<double>(0.0, (sum, invoice) => sum + invoice.totalAmount);
    final creditSales = invoices
        .where((invoice) => invoice.invoiceType == 'Credit')
        .fold<double>(0.0, (sum, invoice) => sum + invoice.totalAmount);
    final paidInvoices = invoices
        .where((invoice) => invoice.paymentStatus == 'Paid')
        .length;
    final partialPaidInvoices = invoices
        .where((invoice) => invoice.paymentStatus == 'Partial Paid')
        .length;
    final notPaidInvoices = invoices
        .where((invoice) => invoice.paymentStatus == 'Not Paid')
        .length;

    return [
      {
        'label': 'Total Invoices',
        'value': totalInvoices.toString(),
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
        'label': 'Cash Sales',
        'value': '₹${cashSales.toStringAsFixed(2)}',
        'color': Colors.green,
        'highlight': true
      },
      {
        'label': 'Credit Sales',
        'value': '₹${creditSales.toStringAsFixed(2)}',
        'color': Colors.blue,
        'highlight': true
      },
      {
        'label': 'Paid',
        'value': paidInvoices.toString(),
        'color': Colors.green,
        'highlight': true
      },
      {
        'label': 'Partial Paid',
        'value': partialPaidInvoices.toString(),
        'color': Colors.orange,
        'highlight': true
      },
      {
        'label': 'Not Paid',
        'value': notPaidInvoices.toString(),
        'color': Colors.red,
        'highlight': true
      },
      if (showTodayStats)
        {
          'label': "Today's Invoices",
          'value': newInvoices.toString(),
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
    return users.firstWhere(
          (user) => user.userId == userId,
      orElse: () => UserInfo(userId: userId, userName: 'Unknown'),
    ).userName ?? 'Unknown';
  }

  Future<void> fetchInvoices({
    DateTime? startDate,
    DateTime? endDate,
    String? invoiceType,
    String? paymentStatus,
    String? invoiceLastUpdatedBy,
    String? storeId,
    String? userId,
    double? minTotalAmount,
    double? maxTotalAmount,
  }) async {
    emit(AdminInvoiceListFetchLoading());
    try {
      final invoices = await orderService.getAllInvoices();
      _allInvoices = invoices;
      final users = await employeeServices.getUsersFromTenantCompany(storeId: storeId);
      final stores = await storeService.getStores();

      invoices.sort((a, b) => (b.invoiceGeneratedDate ?? b.orderDate)
          .compareTo(a.invoiceGeneratedDate ?? a.orderDate));
      List<Order> filteredInvoices = invoices;

      if (startDate != null && endDate != null) {
        filteredInvoices = filteredInvoices.where((invoice) {
          final date = invoice.invoiceGeneratedDate ?? invoice.orderDate;
          return date.isAfter(startDate) &&
              date.isBefore(endDate.add(const Duration(days: 1)));
        }).toList();
      }

      if (invoiceType != null) {
        filteredInvoices = filteredInvoices
            .where((invoice) => invoice.invoiceType == invoiceType)
            .toList();
      }

      if (paymentStatus != null) {
        filteredInvoices = filteredInvoices
            .where((invoice) => invoice.paymentStatus == paymentStatus)
            .toList();
      }

      if (invoiceLastUpdatedBy != null) {
        filteredInvoices = filteredInvoices
            .where((invoice) => invoice.invoiceLastUpdatedBy == invoiceLastUpdatedBy)
            .toList();
      }

      if (storeId != null) {
        filteredInvoices = filteredInvoices
            .where((invoice) => invoice.storeId == storeId)
            .toList();
      }

      if (userId != null) {
        filteredInvoices = filteredInvoices
            .where((invoice) => invoice.userId == userId)
            .toList();
      }

      if (minTotalAmount != null && maxTotalAmount != null) {
        filteredInvoices = filteredInvoices.where((invoice) =>
        invoice.totalAmount >= minTotalAmount &&
            invoice.totalAmount <= maxTotalAmount).toList();
      }

      if (_searchQuery.isNotEmpty) {
        filteredInvoices = filteredInvoices
            .where((invoice) => invoice.id.toLowerCase().contains(_searchQuery.toLowerCase()))
            .toList();
      }

      final showTodayStats = _shouldShowTodayStats(startDate, endDate);
      emit(AdminInvoiceListFetchSuccess(
        invoices: filteredInvoices,
        users: users,
        stores: stores,
        startDate: startDate,
        endDate: endDate,
        invoiceType: invoiceType,
        paymentStatus: paymentStatus,
        invoiceLastUpdatedBy: invoiceLastUpdatedBy,
        storeId: storeId,
        userId: userId,
        minTotalAmount: minTotalAmount,
        maxTotalAmount: maxTotalAmount,
        groupedInvoices: _groupInvoicesByDate(filteredInvoices),
        dateRangeLabel: _formatDateRange(startDate, endDate),
        statistics: _computeStatistics(filteredInvoices, showTodayStats),
        showTodayStats: showTodayStats,
      ));
    } catch (e) {
      emit(AdminInvoiceListFetchError('Failed to fetch invoices: ${e.toString()}'));
    }
  }

  void filterInvoicesById(String query) {
    _searchQuery = query;
    if (state is AdminInvoiceListFetchSuccess) {
      final currentState = state as AdminInvoiceListFetchSuccess;
      List<Order> filteredInvoices = _allInvoices;

      if (_searchQuery.isNotEmpty) {
        filteredInvoices = filteredInvoices
            .where((invoice) => invoice.id.toLowerCase().contains(_searchQuery.toLowerCase()))
            .toList();
      }

      if (currentState.startDate != null && currentState.endDate != null) {
        filteredInvoices = filteredInvoices.where((invoice) {
          final date = invoice.invoiceGeneratedDate ?? invoice.orderDate;
          return date.isAfter(currentState.startDate!) &&
              date.isBefore(currentState.endDate!.add(const Duration(days: 1)));
        }).toList();
      }

      if (currentState.invoiceType != null) {
        filteredInvoices = filteredInvoices
            .where((invoice) => invoice.invoiceType == currentState.invoiceType)
            .toList();
      }

      if (currentState.paymentStatus != null) {
        filteredInvoices = filteredInvoices
            .where((invoice) => invoice.paymentStatus == currentState.paymentStatus)
            .toList();
      }

      if (currentState.invoiceLastUpdatedBy != null) {
        filteredInvoices = filteredInvoices
            .where((invoice) => invoice.invoiceLastUpdatedBy == currentState.invoiceLastUpdatedBy)
            .toList();
      }

      if (currentState.storeId != null) {
        filteredInvoices = filteredInvoices
            .where((invoice) => invoice.storeId == currentState.storeId)
            .toList();
      }

      if (currentState.userId != null) {
        filteredInvoices = filteredInvoices
            .where((invoice) => invoice.userId == currentState.userId)
            .toList();
      }

      if (currentState.minTotalAmount != null && currentState.maxTotalAmount != null) {
        filteredInvoices = filteredInvoices.where((invoice) =>
        invoice.totalAmount >= currentState.minTotalAmount! &&
            invoice.totalAmount <= currentState.maxTotalAmount!).toList();
      }

      final showTodayStats = _shouldShowTodayStats(currentState.startDate, currentState.endDate);
      emit(AdminInvoiceListFetchSuccess(
        invoices: filteredInvoices,
        users: currentState.users,
        stores: currentState.stores,
        startDate: currentState.startDate,
        endDate: currentState.endDate,
        invoiceType: currentState.invoiceType,
        paymentStatus: currentState.paymentStatus,
        invoiceLastUpdatedBy: currentState.invoiceLastUpdatedBy,
        storeId: currentState.storeId,
        userId: currentState.userId,
        minTotalAmount: currentState.minTotalAmount,
        maxTotalAmount: currentState.maxTotalAmount,
        groupedInvoices: _groupInvoicesByDate(filteredInvoices),
        dateRangeLabel: _formatDateRange(currentState.startDate, currentState.endDate),
        statistics: _computeStatistics(filteredInvoices, showTodayStats),
        showTodayStats: showTodayStats,
      ));
    }
  }

  Future<void> fetchInvoiceById(String invoiceId) async {
    emit(AdminInvoiceFetchLoading());
    try {
      final invoice = await orderService.getInvoiceById(invoiceId);
      final users = await employeeServices.getUsersFromTenantCompany();
      emit(AdminInvoiceFetchSuccess(
        invoice: invoice,
        users: users,
        normalizedPaymentStatus: invoice.paymentStatus?.toLowerCase() ?? 'not paid',
        subtotal: invoice.items.fold(
            0.0, (sum, item) => sum + (item.price * item.quantity)),
        totalTax: invoice.items.fold(0.0, (sum, item) => sum + item.taxAmount),
        invoiceGeneratedDateFormatted: invoice.invoiceGeneratedDate != null
            ? _fullDateFormatter.format(invoice.invoiceGeneratedDate!)
            : 'No Date',
        invoiceLastUpdatedByName: getUserNameById(invoice.invoiceLastUpdatedBy, users),
      ));
    } catch (e) {
      emit(AdminInvoiceFetchError('Failed to fetch invoice: ${e.toString()}'));
    }
  }
}