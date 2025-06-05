import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:requirment_gathering_app/core_module/coordinator/coordinator.dart';
import 'package:requirment_gathering_app/core_module/presentation/widget/custom_appbar.dart';
import 'package:requirment_gathering_app/core_module/service_locator/service_locator.dart';
import 'package:requirment_gathering_app/core_module/utils/AppColor.dart';
import 'package:requirment_gathering_app/core_module/utils/AppLabels.dart';
import 'package:requirment_gathering_app/user_module/cart/presentation/order_cubit.dart';

@RoutePage()
class OrderListPage extends StatelessWidget {
  const OrderListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<OrderCubit>()..fetchOrders(),
      child: Scaffold(
        appBar: const CustomAppBar(
          title: AppLabels.orderListTitle,
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
                  // Date Range Filter
                  BlocBuilder<OrderCubit, OrderState>(
                    builder: (context, state) {
                      return Row(
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
                                  context.read<OrderCubit>().fetchOrders(
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
                                'Select Date Range',
                                style: TextStyle(color: AppColors.white),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () {
                              context.read<OrderCubit>().fetchOrders();
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
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  // Order List
                  Expanded(
                    child: BlocBuilder<OrderCubit, OrderState>(
                      builder: (context, state) {
                        if (state is OrderLoading) {
                          return const Center(
                            child: CircularProgressIndicator(color: AppColors.primary),
                          );
                        }
                        if (state is OrderError) {
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
                        if (state is OrderLoaded) {
                          if (state.orders.isEmpty) {
                            return Center(
                              child: Card(
                                elevation: 4,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: Text(
                                    'No orders found',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: AppColors.black87,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }
                          return ListView.separated(
                            itemCount: state.orders.length,
                            separatorBuilder: (context, index) => const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final order = state.orders[index];
                              return Card(
                                elevation: 4,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: InkWell(
                                  onTap: () => sl<Coordinator>().navigateToUserOrderDetailsPage(order.id),
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