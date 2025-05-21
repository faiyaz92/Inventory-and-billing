import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:requirment_gathering_app/core_module/coordinator/coordinator.dart';
import 'package:requirment_gathering_app/core_module/presentation/widget/custom_appbar.dart';
import 'package:requirment_gathering_app/core_module/service_locator/service_locator.dart';
import 'package:requirment_gathering_app/core_module/utils/AppColor.dart';
import 'package:requirment_gathering_app/core_module/utils/AppLabels.dart';
import 'package:requirment_gathering_app/user_module/cart/data/order_model.dart';
import 'package:requirment_gathering_app/user_module/cart/presentation/admin_order_cubit.dart';
import 'package:intl/intl.dart';
import 'package:sticky_headers/sticky_headers.dart';

@RoutePage()
class AdminPanelPage extends StatelessWidget {
  const AdminPanelPage({Key? key}) : super(key: key);

  // Utility to check if a date is today
  bool _isToday(DateTime? date) {
    if (date == null) return false;
    final today = DateTime.now();
    return date.year == today.year && date.month == today.month && date.day == today.day;
  }

  // Format DateTime range for order dates
  String _formatDateRange(DateTime? start, DateTime? end) {
    if (start == null || end == null) return 'All Orders';
    final formatter = DateFormat('MMM dd, yyyy');
    if (start.day == end.day && start.month == end.month && start.year == end.year) {
      return 'Ordered on ${formatter.format(start)}';
    }
    return 'Ordered between ${formatter.format(start)} and ${formatter.format(end)}';
  }

  // Format DateTime range for expected delivery dates
  String _formatExpectedDeliveryRange(DateTime? start, DateTime? end) {
    if (start == null || end == null) return 'All Orders';
    final formatter = DateFormat('MMM dd, yyyy');
    if (start.day == end.day && start.month == end.month && start.year == end.year) {
      return 'Expected Delivery on ${formatter.format(start)}';
    }
    return 'Expected Delivery between ${formatter.format(start)} and ${formatter.format(end)}';
  }

  // Format single order date
  String _formatOrderDate(DateTime date) {
    final formatter = DateFormat('MMM dd, yyyy');
    return formatter.format(date);
  }

  // Get comma-separated product names
  String _getProductNames(List<CartItem> items) {
    return items.map((item) => item.productName).join(', ');
  }

  // Check if Today's Orders should be shown
  bool _shouldShowTodayStats(DateTime? start, DateTime? end) {
    if (start == null || end == null) return true; // Initial load, no range selected
    final today = DateTime.now();
    return start.year == today.year &&
        start.month == today.month &&
        start.day == today.day &&
        end.year == today.year &&
        end.month == today.month &&
        end.day == today.day;
  }

  // Group orders by date for sticky headers
  Map<String, List<Order>> _groupOrdersByDate(List<Order> orders) {
    final grouped = <String, List<Order>>{};
    final formatter = DateFormat('MMM dd, yyyy');
    for (var order in orders) {
      final dateKey = formatter.format(order.orderDate);
      if (!grouped.containsKey(dateKey)) {
        grouped[dateKey] = [];
      }
      grouped[dateKey]!.add(order);
    }
    return grouped;
  }

  // Show statistics dialog
  void _showStatsDialog(BuildContext context, AdminOrderLoaded state) {
    final totalOrders = state.orders.length;
    final totalAmount = state.orders.fold<double>(0.0, (sum, order) => sum + order.totalAmount);
    final newOrders = state.orders.where((order) => _isToday(order.orderDate)).length;
    final pendingOrders = state.orders.where((order) => order.status.toLowerCase() == 'pending').length;
    final processingOrders = state.orders.where((order) => order.status.toLowerCase() == 'processing').length;
    final shippedOrders = state.orders.where((order) => order.status.toLowerCase() == 'shipped').length;
    final completedOrders = state.orders.where((order) => order.status.toLowerCase() == 'completed').length;
    final notCompletedOrders = totalOrders - completedOrders;
    final todayExpectedDeliveryCount = state.orders.where((order) => _isToday(order.expectedDeliveryDate)).length;
    final todayCompletedDeliveryCount = state.orders
        .where((order) => order.status.toLowerCase() == 'completed' && _isToday(order.orderDeliveryDate))
        .length;

    final showTodayOrders = _shouldShowTodayStats(state.startDate, state.endDate);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Order Statistics',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppColors.textSecondary.withOpacity(0.5),
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Table(
                  border: TableBorder(
                    verticalInside: BorderSide(
                      color: AppColors.textSecondary.withOpacity(0.5),
                      width: 1,
                    ),
                    horizontalInside: BorderSide(
                      color: AppColors.textSecondary.withOpacity(0.5),
                      width: 1,
                    ),
                  ),
                  columnWidths: const {
                    0: FlexColumnWidth(3),
                    1: FlexColumnWidth(2),
                  },
                  children: [
                    TableRow(
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                      ),
                      children: [
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Total Orders',
                              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              totalOrders.toString(),
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    TableRow(
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                      ),
                      children: [
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Total Amount',
                              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              '₹${totalAmount.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    TableRow(
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                      ),
                      children: [
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Pending',
                              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              pendingOrders.toString(),
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.orange,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    TableRow(
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                      ),
                      children: [
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Processing',
                              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              processingOrders.toString(),
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    TableRow(
                      children: [
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Shipped',
                              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              shippedOrders.toString(),
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    TableRow(
                      children: [
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Completed',
                              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              completedOrders.toString(),
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    TableRow(
                      decoration: BoxDecoration(
                        color: Colors.purple.withOpacity(0.1),
                      ),
                      children: [
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Completed vs Not Completed',
                              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              '$completedOrders/$notCompletedOrders',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.purple,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (showTodayOrders)
                      TableRow(
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                        ),
                        children: [
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "Today's Orders",
                                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                newOrders.toString(),
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    TableRow(
                      children: [
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Today's Expected",
                              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              todayExpectedDeliveryCount.toString(),
                              style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
                            ),
                          ),
                        ),
                      ],
                    ),
                    TableRow(
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(12),
                          bottomRight: Radius.circular(12),
                        ),
                      ),
                      children: [
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Today's Completed",
                              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              todayCompletedDeliveryCount.toString(),
                              style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.center,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  child: const Text(
                    'Close',
                    style: TextStyle(color: AppColors.white, fontSize: 14),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AdminOrderCubit>()..fetchOrders(), // No parameters for initial load
      child: Scaffold(
        appBar: const CustomAppBar(
          title: AppLabels.adminPanelTitle,
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Theme.of(context).primaryColor.withOpacity(0.1),
                Theme.of(context).primaryColor.withOpacity(0.3),
              ],
            ),
          ),
          child: SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.all(16.0),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // Date Range and Status Filter
                      BlocBuilder<AdminOrderCubit, AdminOrderState>(
                        buildWhen: (previous, current) =>
                        current is AdminOrderLoading ||
                            current is AdminOrderLoaded ||
                            current is AdminOrderError,
                        builder: (context, state) {
                          DateTime? orderStartDate;
                          DateTime? orderEndDate;
                          DateTime? expectedStartDate;
                          DateTime? expectedEndDate;
                          String? selectedStatus;

                          if (state is AdminOrderLoaded && state.orders.isNotEmpty) {
                            orderStartDate = state.startDate ??
                                state.orders
                                    .map((order) => order.orderDate)
                                    .reduce((a, b) => a.isBefore(b) ? a : b);
                            orderEndDate = state.endDate ??
                                state.orders
                                    .map((order) => order.orderDate)
                                    .reduce((a, b) => a.isAfter(b) ? a : b);
                            expectedStartDate = state.expectedDeliveryStartDate;
                            expectedEndDate = state.expectedDeliveryEndDate;
                          }

                          return Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        final dateRange = await showDateRangePicker(
                                          context: context,
                                          firstDate: DateTime(2020),
                                          lastDate: DateTime.now(),
                                          initialDateRange: DateTimeRange(
                                            start: DateTime.now().subtract(const Duration(days: 30)),
                                            end: DateTime.now(),
                                          ),
                                        );
                                        if (dateRange != null) {
                                          context.read<AdminOrderCubit>().fetchOrders(
                                            startDate: dateRange.start,
                                            endDate: dateRange.end,
                                            status: selectedStatus,
                                            expectedDeliveryStartDate: expectedStartDate,
                                            expectedDeliveryEndDate: expectedEndDate,
                                          );
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.primary,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                      ),
                                      child: const Text(
                                        'Date Range: Order',
                                        style: TextStyle(color: AppColors.white, fontSize: 14),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        final dateRange = await showDateRangePicker(
                                          context: context,
                                          firstDate: DateTime(2020),
                                          lastDate: DateTime.now().add(const Duration(days: 365)),
                                          initialDateRange: DateTimeRange(
                                            start: DateTime.now(),
                                            end: DateTime.now().add(const Duration(days: 30)),
                                          ),
                                        );
                                        if (dateRange != null) {
                                          context.read<AdminOrderCubit>().fetchOrders(
                                            startDate: orderStartDate,
                                            endDate: orderEndDate,
                                            status: selectedStatus,
                                            expectedDeliveryStartDate: dateRange.start,
                                            expectedDeliveryEndDate: dateRange.end,
                                          );
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.green,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                      ),
                                      child: const Text(
                                        'Date : Expected Delivery',
                                        style: TextStyle(color: AppColors.white, fontSize: 14),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: DropdownButtonFormField<String>(
                                      decoration: const InputDecoration(
                                        labelText: 'Filter by Status',
                                        border: OutlineInputBorder(),
                                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                      ),
                                      value: selectedStatus,
                                      hint: const Text('All Statuses'),
                                      items: [
                                        const DropdownMenuItem(
                                          value: null,
                                          child: Text('All Statuses'),
                                        ),
                                        ...['pending', 'processing', 'shipped', 'completed']
                                            .map((status) => DropdownMenuItem(
                                          value: status,
                                          child: Text(
                                            status[0].toUpperCase() + status.substring(1),
                                          ),
                                        ))
                                            .toList(),
                                      ],
                                      onChanged: (value) {
                                        selectedStatus = value;
                                        context.read<AdminOrderCubit>().fetchOrders(
                                          startDate: orderStartDate,
                                          endDate: orderEndDate,
                                          status: value,
                                          expectedDeliveryStartDate: expectedStartDate,
                                          expectedDeliveryEndDate: expectedEndDate,
                                        );
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  ElevatedButton(
                                    onPressed: () {
                                      selectedStatus = null;
                                      context.read<AdminOrderCubit>().fetchOrders();
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.red,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                    ),
                                    child: const Text(
                                      'Clear',
                                      style: TextStyle(color: AppColors.white, fontSize: 14),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      // Order Statistics
                      BlocBuilder<AdminOrderCubit, AdminOrderState>(
                        buildWhen: (previous, current) =>
                        current is AdminOrderLoading ||
                            current is AdminOrderLoaded ||
                            current is AdminOrderError,
                        builder: (context, state) {
                          if (state is AdminOrderLoading) {
                            return const Center(
                              child: CircularProgressIndicator(color: AppColors.primary),
                            );
                          }
                          if (state is AdminOrderError) {
                            return Card(
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Text(
                                  '${AppLabels.error}: ${state.message}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: AppColors.red,
                                  ),
                                ),
                              ),
                            );
                          }
                          if (state is AdminOrderLoaded) {
                            final totalOrders = state.orders.length;
                            final totalAmount = state.orders.fold<double>(0.0, (sum, order) => sum + order.totalAmount);
                            final newOrders = state.orders.where((order) => _isToday(order.orderDate)).length;
                            final pendingOrders = state.orders.where((order) => order.status.toLowerCase() == 'pending').length;
                            final processingOrders = state.orders.where((order) => order.status.toLowerCase() == 'processing').length;
                            final shippedOrders = state.orders.where((order) => order.status.toLowerCase() == 'shipped').length;
                            final completedOrders = state.orders.where((order) => order.status.toLowerCase() == 'completed').length;
                            final notCompletedOrders = totalOrders - completedOrders;
                            final todayExpectedDeliveryCount = state.orders.where((order) => _isToday(order.expectedDeliveryDate)).length;
                            final todayCompletedDeliveryCount = state.orders
                                .where((order) => order.status.toLowerCase() == 'completed' && _isToday(order.orderDeliveryDate))
                                .length;

                            final showTodayOrders = _shouldShowTodayStats(state.startDate, state.endDate);

                            // Statistics data for grid
                            final stats = [
                              {'label': 'Total Orders', 'value': totalOrders.toString(), 'color': AppColors.textPrimary, 'highlight': true},
                              {'label': 'Total Amount', 'value': '₹${totalAmount.toStringAsFixed(2)}', 'color': AppColors.textPrimary, 'highlight': true},
                              {'label': 'Pending', 'value': pendingOrders.toString(), 'color': Colors.orange, 'highlight': true},
                              {'label': 'Processing', 'value': processingOrders.toString(), 'color': Colors.blue, 'highlight': true},
                              {'label': 'Shipped', 'value': shippedOrders.toString(), 'color': AppColors.textSecondary, 'highlight': false},
                              {'label': 'Completed', 'value': completedOrders.toString(), 'color': AppColors.textSecondary, 'highlight': false},
                              {
                                'label': 'Completed vs Not Completed',
                                'value': '$completedOrders/$notCompletedOrders',
                                'color': Colors.purple,
                                'highlight': true
                              },
                              if (showTodayOrders)
                                {'label': "Today's Orders", 'value': newOrders.toString(), 'color': Colors.green, 'highlight': true},
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

                            return Card(
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text(
                                          'Order Statistics',
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                        ElevatedButton(
                                          onPressed: () => _showStatsDialog(context, state),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: AppColors.primary,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                            minimumSize: const Size(40, 40),
                                          ),
                                          child: const Text(
                                            'View',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: AppColors.white,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    GridView.builder(
                                      shrinkWrap: true,
                                      physics: const NeverScrollableScrollPhysics(),
                                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 4,
                                        childAspectRatio: 3,
                                        mainAxisSpacing: 8,
                                        crossAxisSpacing: 8,
                                      ),
                                      itemCount: stats.length * 2, // Label and value for each stat
                                      itemBuilder: (context, index) {
                                        final statIndex = index ~/ 2;
                                        final isLabel = index % 2 == 0;
                                        final stat = stats[statIndex];
                                        return Container(
                                          decoration: BoxDecoration(
                                            color: stat['highlight'] == true
                                                ? (stat['color'] as Color).withOpacity(0.1)
                                                : Colors.transparent,
                                            border: Border.all(
                                              color: AppColors.textSecondary.withOpacity(0.5),
                                              width: 1,
                                            ),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                                          child: Align(
                                            alignment: isLabel ? Alignment.centerLeft : Alignment.centerRight,
                                            child: Text(
                                              isLabel ? stat['label'] as String : stat['value'] as String,
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: isLabel
                                                    ? AppColors.textSecondary
                                                    : (stat['color'] as Color),
                                                fontWeight: stat['highlight'] == true && !isLabel
                                                    ? FontWeight.bold
                                                    : FontWeight.normal,
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                      const SizedBox(height: 16),
                      // Dynamic Expected Delivery Label
                      BlocBuilder<AdminOrderCubit, AdminOrderState>(
                        buildWhen: (previous, current) =>
                        current is AdminOrderLoaded || current is AdminOrderLoading || current is AdminOrderError,
                        builder: (context, state) {
                          DateTime? expectedStartDate;
                          DateTime? expectedEndDate;
                          if (state is AdminOrderLoaded) {
                            expectedStartDate = state.expectedDeliveryStartDate;
                            expectedEndDate = state.expectedDeliveryEndDate;
                          }
                          return Container(
                            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _formatExpectedDeliveryRange(expectedStartDate, expectedEndDate),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.white,
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 8),
                    ]),
                  ),
                ),
                // Order List with Sticky Headers
                BlocBuilder<AdminOrderCubit, AdminOrderState>(
                  buildWhen: (previous, current) =>
                  current is AdminOrderLoading || current is AdminOrderLoaded || current is AdminOrderError,
                  builder: (context, state) {
                    if (state is AdminOrderLoaded) {
                      final groupedOrders = _groupOrdersByDate(state.orders);
                      final dates = groupedOrders.keys.toList()
                        ..sort((a, b) => DateFormat('MMM dd, yyyy')
                            .parse(b)
                            .compareTo(DateFormat('MMM dd, yyyy').parse(a)));

                      return SliverList(
                        delegate: SliverChildBuilderDelegate(
                              (context, index) {
                            final date = dates[index];
                            final orders = groupedOrders[date]!;
                            return StickyHeader(
                              header: Container(
                                width: double.infinity,
                                color: Theme.of(context).scaffoldBackgroundColor,
                                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                                child: Text(
                                  date,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                              content: Column(
                                children: orders.map((order) {
                                  final statusColor = order.status.toLowerCase() == 'pending'
                                      ? Colors.orange
                                      : order.status.toLowerCase() == 'processing'
                                      ? Colors.blue
                                      : AppColors.textSecondary;
                                  final statusBackgroundColor = order.status.toLowerCase() == 'pending'
                                      ? Colors.orange.withOpacity(0.1)
                                      : order.status.toLowerCase() == 'processing'
                                      ? Colors.blue.withOpacity(0.1)
                                      : Colors.transparent;
                                  return Card(
                                    elevation: 4,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
                                    child: InkWell(
                                      onTap: () => sl<Coordinator>().navigateToAdminOrderDetailsPage(order.id),
                                      borderRadius: BorderRadius.circular(12),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                const Icon(
                                                  Icons.receipt,
                                                  color: AppColors.primary,
                                                  size: 36,
                                                ),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        'Order #${order.id}',
                                                        style: const TextStyle(
                                                          fontSize: 18,
                                                          fontWeight: FontWeight.bold,
                                                          color: AppColors.textPrimary,
                                                        ),
                                                      ),
                                                      Text(
                                                        'Customer: ${order.userName}',
                                                        style: const TextStyle(
                                                          fontSize: 14,
                                                          color: AppColors.textSecondary,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 8),
                                            Container(
                                              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  color: AppColors.textSecondary.withOpacity(0.5),
                                                  width: 1,
                                                ),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                _formatOrderDate(order.orderDate),
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: AppColors.textSecondary,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Align(
                                              alignment: Alignment.centerRight,
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                    color: AppColors.textSecondary.withOpacity(0.5),
                                                    width: 1,
                                                  ),
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                                child: Table(
                                                  border: TableBorder(
                                                    verticalInside: BorderSide(
                                                      color: AppColors.textSecondary.withOpacity(0.5),
                                                      width: 1,
                                                    ),
                                                    horizontalInside: BorderSide(
                                                      color: AppColors.textSecondary.withOpacity(0.5),
                                                      width: 1,
                                                    ),
                                                  ),
                                                  columnWidths: const {
                                                    0: FlexColumnWidth(3),
                                                    1: FlexColumnWidth(2),
                                                  },
                                                  children: [
                                                    TableRow(
                                                      children: [
                                                        const Padding(
                                                          padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                                                          child: Align(
                                                            alignment: Alignment.centerLeft,
                                                            child: Text(
                                                              'Products',
                                                              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                                                            ),
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                                                          child: Align(
                                                            alignment: Alignment.centerRight,
                                                            child: Text(
                                                              _getProductNames(order.items),
                                                              style: const TextStyle(
                                                                fontSize: 14,
                                                                color: AppColors.textSecondary,
                                                              ),
                                                              maxLines: 2,
                                                              overflow: TextOverflow.ellipsis,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    TableRow(
                                                      decoration: BoxDecoration(
                                                        color: statusBackgroundColor,
                                                      ),
                                                      children: [
                                                        const Padding(
                                                          padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                                                          child: Align(
                                                            alignment: Alignment.centerLeft,
                                                            child: Text(
                                                              'Status',
                                                              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                                                            ),
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                                                          child: Align(
                                                            alignment: Alignment.centerRight,
                                                            child: Text(
                                                              order.status,
                                                              style: TextStyle(
                                                                fontSize: 14,
                                                                color: statusColor,
                                                                fontWeight: order.status.toLowerCase() == 'pending' ||
                                                                    order.status.toLowerCase() == 'processing'
                                                                    ? FontWeight.bold
                                                                    : FontWeight.normal,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    TableRow(
                                                      decoration: BoxDecoration(
                                                        color: AppColors.primary.withOpacity(0.1),
                                                        borderRadius: const BorderRadius.only(
                                                          bottomLeft: Radius.circular(12),
                                                          bottomRight: Radius.circular(12),
                                                        ),
                                                      ),
                                                      children: [
                                                        const Padding(
                                                          padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                                                          child: Align(
                                                            alignment: Alignment.centerLeft,
                                                            child: Text(
                                                              'Total',
                                                              style: TextStyle(
                                                                fontSize: 14,
                                                                color: AppColors.textPrimary,
                                                                fontWeight: FontWeight.bold,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                                                          child: Align(
                                                            alignment: Alignment.centerRight,
                                                            child: Text(
                                                              '₹${order.totalAmount.toStringAsFixed(2)}',
                                                              style: const TextStyle(
                                                                fontSize: 14,
                                                                color: AppColors.textPrimary,
                                                                fontWeight: FontWeight.bold,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            );
                          },
                          childCount: dates.length,
                        ),
                      );
                    }
                    return const SliverToBoxAdapter(child: SizedBox.shrink());
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}