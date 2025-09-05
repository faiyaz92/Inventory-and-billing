import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:requirment_gathering_app/core_module/presentation/widget/custom_appbar.dart';
import 'package:requirment_gathering_app/core_module/service_locator/service_locator.dart';
import 'package:requirment_gathering_app/core_module/utils/AppColor.dart';
import 'package:requirment_gathering_app/core_module/utils/AppLabels.dart';
import 'package:requirment_gathering_app/user_module/cart/presentation/order_cubit.dart';

@RoutePage()
class UserOrderDetailsPage extends StatelessWidget {
  final String orderId;

  const UserOrderDetailsPage({Key? key, required this.orderId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<OrderCubit>()..fetchOrderById(orderId),
      child: Builder(
        builder: (newContext) {
          return Scaffold(
            appBar: const CustomAppBar(
              title: 'Order Details',
            ),
            body: Container(
              height: double.maxFinite,
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
                child: BlocBuilder<OrderCubit, OrderState>(
                  builder: (context, state) {
                    if (state is OrderLoading) {
                      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                    } else if (state is OrderLoaded) {
                      final order = state.orders.first;
                      final subtotal = order.items.fold(0.0, (sum, item) => sum + (item.price * item.quantity));
                      final totalTax = order.items.fold(0.0, (sum, item) => sum + item.taxAmount);
                      return SingleChildScrollView(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Card(
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
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
                                                'Order ID',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: AppColors.textSecondary,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                                            child: Align(
                                              alignment: Alignment.centerRight,
                                              child: Text(
                                                order.id,
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
                                                'Status',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: AppColors.textSecondary,
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
                                                order.status,
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
                                        children: [
                                          const Padding(
                                            padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                                            child: Align(
                                              alignment: Alignment.centerLeft,
                                              child: Text(
                                                'Order Date',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: AppColors.textSecondary,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                                            child: Align(
                                              alignment: Alignment.centerRight,
                                              child: Text(
                                                order.orderDate.toString(),
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  color: AppColors.textSecondary,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      if (order.expectedDeliveryDate != null)
                                        TableRow(
                                          children: [
                                            const Padding(
                                              padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                                              child: Align(
                                                alignment: Alignment.centerLeft,
                                                child: Text(
                                                  'Expected Delivery',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: AppColors.textSecondary,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                                              child: Align(
                                                alignment: Alignment.centerRight,
                                                child: Text(
                                                  order.expectedDeliveryDate.toString(),
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
                                                'Subtotal (All Items)',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: AppColors.textSecondary,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                                            child: Align(
                                              alignment: Alignment.centerRight,
                                              child: Text(
                                                'IQD ${subtotal.toStringAsFixed(2)}',
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  color: AppColors.textPrimary,
                                                  fontWeight: FontWeight.w500,
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
                                                'Total Tax',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: AppColors.textSecondary,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                                            child: Align(
                                              alignment: Alignment.centerRight,
                                              child: Text(
                                                'IQD ${totalTax.toStringAsFixed(2)}',
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
                                          color: AppColors.primary.withOpacity(0.2),
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
                                                'IQD ${order.totalAmount.toStringAsFixed(2)}',
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
                            ),
                            const SizedBox(height: 16),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: AppColors.primary.withOpacity(0.5),
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(12),
                                color: AppColors.primary.withOpacity(0.05),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Ordered Items',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  ...order.items.map(
                                        (item) => Card(
                                      elevation: 4,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              item.productName,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.textPrimary,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 8),
                                            Container(
                                              decoration: BoxDecoration(
                                                color: Colors.white,
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
                                                      Padding(
                                                        padding: const EdgeInsets.symmetric(
                                                            vertical: 4.0, horizontal: 8.0),
                                                        child: Align(
                                                          alignment: Alignment.centerLeft,
                                                          child: Text(
                                                            'Subtotal (IQD ${item.price} x ${item.quantity})',
                                                            style: const TextStyle(
                                                              fontSize: 14,
                                                              color: AppColors.textSecondary,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding: const EdgeInsets.symmetric(
                                                            vertical: 4.0, horizontal: 8.0),
                                                        child: Align(
                                                          alignment: Alignment.centerRight,
                                                          child: Text(
                                                            'IQD ${(item.price * item.quantity).toStringAsFixed(2)}',
                                                            style: const TextStyle(
                                                              fontSize: 14,
                                                              color: AppColors.textPrimary,
                                                              fontWeight: FontWeight.w500,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  TableRow(
                                                    children: [
                                                      Padding(
                                                        padding: const EdgeInsets.symmetric(
                                                            vertical: 4.0, horizontal: 8.0),
                                                        child: Align(
                                                          alignment: Alignment.centerLeft,
                                                          child: Text(
                                                            'Tax (${(item.taxRate * 100).toStringAsFixed(0)}%)',
                                                            style: const TextStyle(
                                                              fontSize: 14,
                                                              color: AppColors.textSecondary,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding: const EdgeInsets.symmetric(
                                                            vertical: 4.0, horizontal: 8.0),
                                                        child: Align(
                                                          alignment: Alignment.centerRight,
                                                          child: Text(
                                                            'IQD ${item.taxAmount.toStringAsFixed(2)}',
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
                                                      color: AppColors.primary.withOpacity(0.2),
                                                      borderRadius: const BorderRadius.only(
                                                        bottomLeft: Radius.circular(12),
                                                        bottomRight: Radius.circular(12),
                                                      ),
                                                    ),
                                                    children: [
                                                      const Padding(
                                                        padding: EdgeInsets.symmetric(
                                                            vertical: 4.0, horizontal: 8.0),
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
                                                            vertical: 4.0, horizontal: 8.0),
                                                        child: Align(
                                                          alignment: Alignment.centerRight,
                                                          child: Text(
                                                            'IQD ${((item.price * item.quantity) + item.taxAmount).toStringAsFixed(2)}',
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
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    } else if (state is OrderError) {
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
                    return Center(
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text(
                            'No order data available',
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.black87,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}