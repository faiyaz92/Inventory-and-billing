import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:requirment_gathering_app/core_module/presentation/widget/custom_appbar.dart';
import 'package:requirment_gathering_app/core_module/service_locator/service_locator.dart';
import 'package:requirment_gathering_app/core_module/utils/AppColor.dart';
import 'package:requirment_gathering_app/core_module/utils/AppLabels.dart';
import 'package:requirment_gathering_app/super_admin_module/utils/user_type.dart';
import 'package:requirment_gathering_app/user_module/cart/data/order_model.dart';
import 'package:requirment_gathering_app/user_module/cart/presentation/admin_order_cubit.dart';

@RoutePage()
class AdminOrderDetailsPage extends StatelessWidget {
  final String orderId;

  const AdminOrderDetailsPage({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<AdminOrderCubit>()..fetchOrderById(orderId),
      child: Scaffold(
        appBar: const CustomAppBar(
          title: AppLabels.adminOrderDetailsTitle,
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
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: BlocListener<AdminOrderCubit, AdminOrderState>(
                listenWhen: (previous, current) =>
                current is AdminOrderFetchError ||
                    current is AdminOrderUpdateStatusError ||
                    current is AdminOrderSetDeliveryDateError ||
                    current is AdminOrderSetResponsibleError ||
                    current is AdminOrderSetDeliveredByError,
                listener: (context, state) {
                  String message = '';
                  if (state is AdminOrderFetchError) {
                    message = state.message;
                  } else if (state is AdminOrderUpdateStatusError) {
                    message = state.message;
                  } else if (state is AdminOrderSetDeliveryDateError) {
                    message = state.message;
                  } else if (state is AdminOrderSetResponsibleError) {
                    message = state.message;
                  } else if (state is AdminOrderSetDeliveredByError) {
                    message = state.message;
                  }
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (dialogContext) => AlertDialog(
                      title: const Text(
                        'Error',
                        style: TextStyle(
                          color: AppColors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      content: Text(
                        message,
                        style: const TextStyle(color: AppColors.textPrimary),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(dialogContext).pop();
                            context
                                .read<AdminOrderCubit>()
                                .fetchOrderById(orderId);
                          },
                          child: const Text(
                            'Retry',
                            style: TextStyle(color: AppColors.primary),
                          ),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(dialogContext).pop(),
                          child: const Text(
                            'Dismiss',
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                        ),
                      ],
                    ),
                  );
                },
                child: BlocBuilder<AdminOrderCubit, AdminOrderState>(
                  buildWhen: (previous, current) =>
                  current is AdminOrderFetchLoading ||
                      current is AdminOrderFetchSuccess ||
                      current is AdminOrderFetchError,
                  builder: (context, state) {
                    if (state is AdminOrderFetchLoading) {
                      return _buildLoading();
                    }
                    if (state is AdminOrderFetchError) {
                      return _buildError(state.message);
                    }
                    if (state is AdminOrderFetchSuccess) {
                      return _buildContent(context, state);
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: CircularProgressIndicator(color: AppColors.primary),
    );
  }

  Widget _buildError(String message) {
    return Center(
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        color: AppColors.cardBackground,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            '${AppLabels.error}: $message',
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.red,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, AdminOrderFetchSuccess state) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildOrderDetailsCard(state),
          const SizedBox(height: 16),
          _buildUpdateOrderCard(context, state),
          const SizedBox(height: 16),
          _buildOrderedItemsCard(state),
        ],
      ),
    );
  }

  Widget _buildOrderDetailsCard(AdminOrderFetchSuccess state) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: AppColors.cardBackground,
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
              _buildTableRow('Order ID', state.order.id,
                  isBold: true, valueColor: AppColors.textPrimary),
              _buildTableRow('Ordered By', state.order.userName,
                  isBold: true, valueColor: AppColors.textPrimary),
              _buildTableRow(
                  'Order Taken By', state.orderTakenByName ?? 'Not Assigned'),
              _buildTableRow('Store ID', state.order.storeId ?? 'Not Provided'), // Added
              if (state.lastUpdatedByName != null)
                _buildTableRow('Last Updated By', state.lastUpdatedByName!),
              _buildTableRow(
                'Status',
                state.order.status.capitalize(),
                isBold: true,
                valueColor: AppColors.textPrimary,
                backgroundColor: AppColors.primary.withOpacity(0.1),
              ),
              _buildTableRow('Placed On', state.orderDateFormatted),
              if (state.expectedDeliveryDateFormatted != null)
                _buildTableRow(
                    'Expected Delivery', state.expectedDeliveryDateFormatted!),
              if (state.orderDeliveryDateFormatted != null) // Added
                _buildTableRow('Delivered On', state.orderDeliveryDateFormatted!),
              if (state.responsibleForDeliveryName != null)
                _buildTableRow('Responsible for Delivery',
                    state.responsibleForDeliveryName!),
              if (state.orderDeliveredByName != null)
                _buildTableRow('Delivered By', state.orderDeliveredByName!),
              _buildTableRow('Subtotal (All Items)',
                  '₹${state.subtotal.toStringAsFixed(2)}',
                  valueWeight: FontWeight.w500,
                  valueColor: AppColors.textPrimary),
              _buildTableRow(
                  'Total Tax', '₹${state.totalTax.toStringAsFixed(2)}'),
              _buildTableRow(
                'Total',
                '₹${state.order.totalAmount.toStringAsFixed(2)}',
                isBold: true,
                valueColor: AppColors.textPrimary,
                backgroundColor: AppColors.primary.withOpacity(0.2),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  TableRow _buildTableRow(
      String label,
      String value, {
        bool isBold = false,
        FontWeight valueWeight = FontWeight.normal,
        Color? valueColor = AppColors.textSecondary,
        Color? backgroundColor,
        BorderRadius? borderRadius,
      }) {
    return TableRow(
      decoration: backgroundColor != null || borderRadius != null
          ? BoxDecoration(
        color: backgroundColor,
        borderRadius: borderRadius,
      )
          : null,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
          child: Align(
            alignment: Alignment.centerRight,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: valueColor,
                fontWeight: valueWeight,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUpdateOrderCard(
      BuildContext context, AdminOrderFetchSuccess state) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: AppColors.cardBackground,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Update Order',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: AppLabels.updateStatus,
                border: OutlineInputBorder(),
              ),
              value: state.normalizedStatus,
              items: const [
                DropdownMenuItem(value: 'pending', child: Text('Pending')),
                DropdownMenuItem(value: 'processing', child: Text('Processing')),
                DropdownMenuItem(value: 'shipped', child: Text('Shipped')),
                DropdownMenuItem(value: 'completed', child: Text('Completed')),
              ],
              onChanged: (value) {
                if (value != null) {
                  context
                      .read<AdminOrderCubit>()
                      .updateOrderStatus(state.order.id, value);
                }
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Assign Responsible for Delivery',
                border: OutlineInputBorder(),
              ),
              value: state.order.responsibleForDelivery,
              items: [
                const DropdownMenuItem(
                  value: null,
                  child: Text('Not Assigned'),
                ),
                ...state.users
                    .where((user) => user.userType == UserType.Employee)
                    .map((user) => DropdownMenuItem(
                  value: user.userId,
                  child: Text(user.name ?? 'Unknown'),
                )),
              ],
              onChanged: (value) {
                context
                    .read<AdminOrderCubit>()
                    .setResponsibleForDelivery(state.order.id, value ?? '');
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2026),
                );
                if (date != null) {
                  context
                      .read<AdminOrderCubit>()
                      .setExpectedDeliveryDate(state.order.id, date);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                AppLabels.setDeliveryDate,
                style: TextStyle(color: AppColors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderedItemsCard(AdminOrderFetchSuccess state) {
    return Container(
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
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: state.order.items.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = state.order.items[index];
              return _buildItemCard(item);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildItemCard(CartItem item) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: AppColors.cardBackground,
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
                  _buildTableRow(
                    'Subtotal (₹${item.price} x ${item.quantity})',
                    '₹${(item.price * item.quantity).toStringAsFixed(2)}',
                    valueWeight: FontWeight.w500,
                    valueColor: AppColors.textPrimary,
                  ),
                  _buildTableRow(
                    'Tax (${(item.taxRate * 100).toStringAsFixed(0)}%)',
                    '₹${item.taxAmount.toStringAsFixed(2)}',
                  ),
                  _buildTableRow(
                    'Total',
                    '₹${((item.price * item.quantity) + item.taxAmount).toStringAsFixed(2)}',
                    isBold: true,
                    valueColor: AppColors.textPrimary,
                    backgroundColor: AppColors.primary.withOpacity(0.2),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(12),
                      bottomRight: Radius.circular(12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }
}