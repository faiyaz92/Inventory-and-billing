import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:requirment_gathering_app/core_module/coordinator/coordinator.dart';
import 'package:requirment_gathering_app/core_module/presentation/widget/custom_appbar.dart';
import 'package:requirment_gathering_app/core_module/service_locator/service_locator.dart';
import 'package:requirment_gathering_app/core_module/utils/AppColor.dart';
import 'package:requirment_gathering_app/core_module/utils/AppLabels.dart';
import 'package:requirment_gathering_app/user_module/cart/presentation/admin_order_cubit.dart';

@RoutePage()
class AdminPanelPage extends StatelessWidget {
  const AdminPanelPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AdminOrderCubit>()..fetchOrders(),
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
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Date Range and Status Filter
                  BlocBuilder<AdminOrderCubit, AdminOrderState>(
                    builder: (context, state) {
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
                                      );
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: const Text(
                                    'Select Order Date Range',
                                    style: TextStyle(color: AppColors.white),
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
                                  ),
                                  child: const Text(
                                    'Select Expected Delivery Range',
                                    style: TextStyle(color: AppColors.white),
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
                                  value: null,
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
                                    // Fetch orders with the selected status filter
                                    DateTime? startDate;
                                    DateTime? endDate;
                                    if (state is AdminOrderLoaded) {
                                      // Preserve existing date range if any
                                      final orders = state.orders;
                                      if (orders.isNotEmpty) {
                                        startDate = orders
                                            .map((order) => order.orderDate)
                                            .reduce((a, b) => a.isBefore(b) ? a : b);
                                        endDate = orders
                                            .map((order) => order.orderDate)
                                            .reduce((a, b) => a.isAfter(b) ? a : b);
                                      }
                                    }
                                    context.read<AdminOrderCubit>().fetchOrders(
                                      startDate: startDate,
                                      endDate: endDate,
                                      status: value,
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: () {
                                  context.read<AdminOrderCubit>().fetchOrders();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.red,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text(
                                  'Clear',
                                  style: TextStyle(color: AppColors.white),
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  // Main Content
                  Expanded(
                    child: BlocBuilder<AdminOrderCubit, AdminOrderState>(
                      builder: (context, state) {
                        if (state is AdminOrderLoading) {
                          return const Center(
                            child: CircularProgressIndicator(color: AppColors.primary),
                          );
                        }
                        if (state is AdminOrderError) {
                          return Center(
                            child: Card(
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
                            ),
                          );
                        }
                        if (state is AdminOrderLoaded) {
                          final pendingOrders =
                              state.orders.where((order) => order.status.toLowerCase() == 'pending').length;
                          final processingOrders =
                              state.orders.where((order) => order.status.toLowerCase() == 'processing').length;
                          final shippedOrders =
                              state.orders.where((order) => order.status.toLowerCase() == 'shipped').length;
                          final completedOrders =
                              state.orders.where((order) => order.status.toLowerCase() == 'completed').length;
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Card(
                                elevation: 4,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
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
                                                color: Colors.orange.withOpacity(0.1), // Highlight Pending row
                                              ),
                                              children: [
                                                const Padding(
                                                  padding: EdgeInsets.symmetric(
                                                    vertical: 4.0,
                                                    horizontal: 8.0,
                                                  ),
                                                  child: Align(
                                                    alignment: Alignment.centerLeft,
                                                    child: Text(
                                                      'Pending',
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        color: AppColors.textSecondary,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets.symmetric(
                                                    vertical: 4.0,
                                                    horizontal: 8.0,
                                                  ),
                                                  child: Align(
                                                    alignment: Alignment.centerRight,
                                                    child: Text(
                                                      pendingOrders.toString(),
                                                      style: const TextStyle(
                                                        fontSize: 14,
                                                        color: Colors.orange, // Highlight count
                                                        fontWeight: FontWeight.bold, // Bold count
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            TableRow(
                                              decoration: BoxDecoration(
                                                color: Colors.blue.withOpacity(0.1), // Highlight Processing row
                                              ),
                                              children: [
                                                const Padding(
                                                  padding: EdgeInsets.symmetric(
                                                    vertical: 4.0,
                                                    horizontal: 8.0,
                                                  ),
                                                  child: Align(
                                                    alignment: Alignment.centerLeft,
                                                    child: Text(
                                                      'Processing',
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        color: AppColors.textSecondary,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets.symmetric(
                                                    vertical: 4.0,
                                                    horizontal: 8.0,
                                                  ),
                                                  child: Align(
                                                    alignment: Alignment.centerRight,
                                                    child: Text(
                                                      processingOrders.toString(),
                                                      style: const TextStyle(
                                                        fontSize: 14,
                                                        color: Colors.blue, // Highlight count
                                                        fontWeight: FontWeight.bold, // Bold count
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            TableRow(
                                              children: [
                                                const Padding(
                                                  padding: EdgeInsets.symmetric(
                                                    vertical: 4.0,
                                                    horizontal: 8.0,
                                                  ),
                                                  child: Align(
                                                    alignment: Alignment.centerLeft,
                                                    child: Text(
                                                      'Shipped',
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        color: AppColors.textSecondary,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets.symmetric(
                                                    vertical: 4.0,
                                                    horizontal: 8.0,
                                                  ),
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
                                              decoration: BoxDecoration(
                                                color: AppColors.primary.withOpacity(0.1),
                                                borderRadius: const BorderRadius.only(
                                                  bottomLeft: Radius.circular(12),
                                                  bottomRight: Radius.circular(12),
                                                ),
                                              ),
                                              children: [
                                                const Padding(
                                                  padding: EdgeInsets.symmetric(
                                                    vertical: 4.0,
                                                    horizontal: 8.0,
                                                  ),
                                                  child: Align(
                                                    alignment: Alignment.centerLeft,
                                                    child: Text(
                                                      'Completed',
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        color: AppColors.textSecondary,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets.symmetric(
                                                    vertical: 4.0,
                                                    horizontal: 8.0,
                                                  ),
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
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'All Orders',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Expanded(
                                child: ListView.separated(
                                  itemCount: state.orders.length,
                                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                                  itemBuilder: (context, index) {
                                    final order = state.orders[index];
                                    // Highlight colors for pending and processing status only
                                    final statusColor = order.status.toLowerCase() == 'pending'
                                        ? Colors.orange // Highlight pending in orange
                                        : order.status.toLowerCase() == 'processing'
                                        ? Colors.blue // Highlight processing in blue
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
                                      child: InkWell(
                                        onTap: () => sl<Coordinator>().navigateToAdminOrderDetailsPage(order.id),
                                        borderRadius: BorderRadius.circular(12),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
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
                                                    child: Text(
                                                      'Order #${order.id}',
                                                      style: const TextStyle(
                                                        fontSize: 18,
                                                        fontWeight: FontWeight.bold,
                                                        color: AppColors.textPrimary,
                                                      ),
                                                    ),
                                                  ),
                                                ],
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
                                                        decoration: BoxDecoration(
                                                          color: statusBackgroundColor, // Highlight status cell
                                                        ),
                                                        children: [
                                                          const Padding(
                                                            padding: EdgeInsets.symmetric(
                                                              vertical: 4.0,
                                                              horizontal: 8.0,
                                                            ),
                                                            child: Align(
                                                              alignment: Alignment.centerLeft,
                                                              child: Text(
                                                                'Status',
                                                                style: TextStyle(
                                                                  fontSize: 14,
                                                                  color: AppColors.textSecondary,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          Padding(
                                                            padding: const EdgeInsets.symmetric(
                                                              vertical: 4.0,
                                                              horizontal: 8.0,
                                                            ),
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
                                                            padding: EdgeInsets.symmetric(
                                                              vertical: 4.0,
                                                              horizontal: 8.0,
                                                            ),
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
                                                            padding: const EdgeInsets.symmetric(
                                                              vertical: 4.0,
                                                              horizontal: 8.0,
                                                            ),
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
                                  },
                                ),
                              ),
                            ],
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}