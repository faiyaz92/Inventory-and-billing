import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:requirment_gathering_app/core_module/presentation/widget/custom_appbar.dart';
import 'package:requirment_gathering_app/core_module/service_locator/service_locator.dart';
import 'package:requirment_gathering_app/core_module/utils/AppColor.dart';
import 'package:requirment_gathering_app/core_module/utils/AppLabels.dart';
import 'package:requirment_gathering_app/super_admin_module/data/user_info.dart';
import 'package:requirment_gathering_app/user_module/cart/presentation/admin_order_cubit.dart';

@RoutePage()
class AdminOrderDetailsPage extends StatelessWidget {
  final String orderId;

  const AdminOrderDetailsPage({Key? key, required this.orderId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<AdminOrderCubit>()..fetchOrderById(orderId),
      child: Builder(
        builder: (newContext) {
          return Scaffold(
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
                  child: BlocConsumer<AdminOrderCubit, AdminOrderState>(
                    listenWhen: (previous, current) =>
                    current is AdminOrderError,
                    listener: (context, state) {
                      if (state is AdminOrderError) {
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (dialogContext) {
                            return AlertDialog(
                              title: const Text(
                                'Error',
                                style: TextStyle(
                                  color: AppColors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              content: Text(
                                state.message,
                                style:
                                const TextStyle(color: AppColors.textPrimary),
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
                                  onPressed: () {
                                    Navigator.of(dialogContext).pop();
                                  },
                                  child: const Text(
                                    'Dismiss',
                                    style:
                                    TextStyle(color: AppColors.textSecondary),
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      }
                    },
                    builder: (context, state) {
                      if (state is AdminOrderLoading) {
                        return const Center(
                          child: CircularProgressIndicator(
                              color: AppColors.primary),
                        );
                      }
                      if (state is AdminOrderError) {
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
                        final order = state.orders.first;
                        final normalizedStatus = order.status.toLowerCase();
                        final subtotal = order.items.fold(
                            0.0,
                                (sum, item) => sum + (item.price * item.quantity));
                        final totalTax = order.items
                            .fold(0.0, (sum, item) => sum + item.taxAmount);

                        return SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Card(
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
                                        color: AppColors.textSecondary
                                            .withOpacity(0.5),
                                        width: 1,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Table(
                                      border: TableBorder(
                                        verticalInside: BorderSide(
                                          color: AppColors.textSecondary
                                              .withOpacity(0.5),
                                          width: 1,
                                        ),
                                        horizontalInside: BorderSide(
                                          color: AppColors.textSecondary
                                              .withOpacity(0.5),
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
                                                  horizontal: 8.0),
                                              child: Align(
                                                alignment: Alignment.centerLeft,
                                                child: Text(
                                                  'Order ID',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color:
                                                    AppColors.textSecondary,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.symmetric(
                                                  vertical: 4.0,
                                                  horizontal: 8.0),
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
                                          children: [
                                            const Padding(
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 4.0,
                                                  horizontal: 8.0),
                                              child: Align(
                                                alignment: Alignment.centerLeft,
                                                child: Text(
                                                  'Ordered By',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color:
                                                    AppColors.textSecondary,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.symmetric(
                                                  vertical: 4.0,
                                                  horizontal: 8.0),
                                              child: Align(
                                                alignment: Alignment.centerRight,
                                                child: Text(
                                                  order.userName,
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
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 4.0,
                                                  horizontal: 8.0),
                                              child: Align(
                                                alignment: Alignment.centerLeft,
                                                child: Text(
                                                  'Order Taken By',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color:
                                                    AppColors.textSecondary,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.symmetric(
                                                  vertical: 4.0,
                                                  horizontal: 8.0),
                                              child: Align(
                                                alignment: Alignment.centerRight,
                                                child: Text(
                                                  order.orderTakenBy ??
                                                      'Not Assigned',
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    color:
                                                    AppColors.textSecondary,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        TableRow(
                                          decoration: BoxDecoration(
                                            color:
                                            AppColors.primary.withOpacity(0.1),
                                          ),
                                          children: [
                                            const Padding(
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 4.0,
                                                  horizontal: 8.0),
                                              child: Align(
                                                alignment: Alignment.centerLeft,
                                                child: Text(
                                                  'Status',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color:
                                                    AppColors.textSecondary,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.symmetric(
                                                  vertical: 4.0,
                                                  horizontal: 8.0),
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
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 4.0,
                                                  horizontal: 8.0),
                                              child: Align(
                                                alignment: Alignment.centerLeft,
                                                child: Text(
                                                  'Placed On',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color:
                                                    AppColors.textSecondary,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.symmetric(
                                                  vertical: 4.0,
                                                  horizontal: 8.0),
                                              child: Align(
                                                alignment: Alignment.centerRight,
                                                child: Text(
                                                  order.orderDate.toString(),
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    color:
                                                    AppColors.textSecondary,
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
                                                padding: EdgeInsets.symmetric(
                                                    vertical: 4.0,
                                                    horizontal: 8.0),
                                                child: Align(
                                                  alignment: Alignment.centerLeft,
                                                  child: Text(
                                                    'Expected Delivery',
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      color:
                                                      AppColors.textSecondary,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.symmetric(
                                                    vertical: 4.0,
                                                    horizontal: 8.0),
                                                child: Align(
                                                  alignment: Alignment.centerRight,
                                                  child: Text(
                                                    order.expectedDeliveryDate
                                                        .toString(),
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                      color:
                                                      AppColors.textSecondary,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        if (order.responsibleForDelivery != null)
                                          TableRow(
                                            children: [
                                              const Padding(
                                                padding: EdgeInsets.symmetric(
                                                    vertical: 4.0,
                                                    horizontal: 8.0),
                                                child: Align(
                                                  alignment: Alignment.centerLeft,
                                                  child: Text(
                                                    'Responsible for Delivery',
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      color:
                                                      AppColors.textSecondary,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.symmetric(
                                                    vertical: 4.0,
                                                    horizontal: 8.0),
                                                child: Align(
                                                  alignment: Alignment.centerRight,
                                                  child: Text(
                                                    state.users
                                                        .firstWhere(
                                                          (user) =>
                                                      user.userId ==
                                                          order
                                                              .responsibleForDelivery,
                                                      orElse: () =>
                                                          UserInfo(
                                                              userId: order
                                                                  .responsibleForDelivery!,
                                                              userName:
                                                              'Unknown'),
                                                    )
                                                        .userName ??
                                                        'Unknown',
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                      color:
                                                      AppColors.textSecondary,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        if (order.orderDeliveredBy != null)
                                          TableRow(
                                            children: [
                                              const Padding(
                                                padding: EdgeInsets.symmetric(
                                                    vertical: 4.0,
                                                    horizontal: 8.0),
                                                child: Align(
                                                  alignment: Alignment.centerLeft,
                                                  child: Text(
                                                    'Delivered By',
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      color:
                                                      AppColors.textSecondary,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.symmetric(
                                                    vertical: 4.0,
                                                    horizontal: 8.0),
                                                child: Align(
                                                  alignment: Alignment.centerRight,
                                                  child: Text(
                                                    state.users
                                                        .firstWhere(
                                                          (user) =>
                                                      user.userId ==
                                                          order
                                                              .orderDeliveredBy,
                                                      orElse: () =>
                                                          UserInfo(
                                                              userId: order
                                                                  .orderDeliveredBy!,
                                                              userName:
                                                              'Unknown'),
                                                    )
                                                        .userName ??
                                                        'Unknown',
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                      color:
                                                      AppColors.textSecondary,
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
                                                  horizontal: 8.0),
                                              child: Align(
                                                alignment: Alignment.centerLeft,
                                                child: Text(
                                                  'Subtotal (All Items)',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color:
                                                    AppColors.textSecondary,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.symmetric(
                                                  vertical: 4.0,
                                                  horizontal: 8.0),
                                              child: Align(
                                                alignment: Alignment.centerRight,
                                                child: Text(
                                                  '₹${subtotal.toStringAsFixed(2)}',
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
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 4.0,
                                                  horizontal: 8.0),
                                              child: Align(
                                                alignment: Alignment.centerLeft,
                                                child: Text(
                                                  'Total Tax',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color:
                                                    AppColors.textSecondary,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.symmetric(
                                                  vertical: 4.0,
                                                  horizontal: 8.0),
                                              child: Align(
                                                alignment: Alignment.centerRight,
                                                child: Text(
                                                  '₹${totalTax.toStringAsFixed(2)}',
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    color:
                                                    AppColors.textSecondary,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        TableRow(
                                          decoration: BoxDecoration(
                                            color:
                                            AppColors.primary.withOpacity(0.2),
                                            borderRadius: const BorderRadius.only(
                                              bottomLeft: Radius.circular(12),
                                              bottomRight: Radius.circular(12),
                                            ),
                                          ),
                                          children: [
                                            const Padding(
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 4.0,
                                                  horizontal: 8.0),
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
                                                  horizontal: 8.0),
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
                              ),
                              const SizedBox(height: 16),
                              Card(
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
                                        value: normalizedStatus,
                                        items: [
                                          'pending',
                                          'processing',
                                          'shipped',
                                          'completed'
                                        ]
                                            .map((status) => DropdownMenuItem(
                                          value: status,
                                          child: Text(status.capitalize()),
                                        ))
                                            .toList(),
                                        onChanged: (value) {
                                          if (value != null) {
                                            newContext
                                                .read<AdminOrderCubit>()
                                                .updateOrderStatus(order.id, value);
                                          }
                                        },
                                      ),
                                      const SizedBox(height: 16),
                                      DropdownButtonFormField<String>(
                                        decoration: const InputDecoration(
                                          labelText: 'Assign Responsible for Delivery',
                                          border: OutlineInputBorder(),
                                        ),
                                        value: order.responsibleForDelivery,
                                        items: [
                                          const DropdownMenuItem(
                                            value: null,
                                            child: Text('Not Assigned'),
                                          ),
                                          ...state.users.map((user) =>
                                              DropdownMenuItem(
                                                value: user.userId,
                                                child:
                                                Text(user.userName ?? 'Unknown'),
                                              )),
                                        ],
                                        onChanged: (value) {
                                          newContext
                                              .read<AdminOrderCubit>()
                                              .setResponsibleForDelivery(
                                              order.id, value ?? '');
                                        },
                                      ),
                                      const SizedBox(height: 16),
                                      DropdownButtonFormField<String>(
                                        decoration: const InputDecoration(
                                          labelText: 'Assign Delivery Person',
                                          border: OutlineInputBorder(),
                                        ),
                                        value: order.orderDeliveredBy,
                                        items: [
                                          const DropdownMenuItem(
                                            value: null,
                                            child: Text('Not Assigned'),
                                          ),
                                          ...state.users.map((user) =>
                                              DropdownMenuItem(
                                                value: user.userId,
                                                child:
                                                Text(user.userName ?? 'Unknown'),
                                              )),
                                        ],
                                        onChanged: (value) {
                                          newContext
                                              .read<AdminOrderCubit>()
                                              .setOrderDeliveredBy(
                                              order.id, value ?? '');
                                        },
                                      ),
                                      const SizedBox(height: 16),
                                      ElevatedButton(
                                        onPressed: () async {
                                          final date = await showDatePicker(
                                            context: newContext,
                                            initialDate: DateTime.now(),
                                            firstDate: DateTime.now(),
                                            lastDate: DateTime(2026),
                                          );
                                          if (date != null) {
                                            newContext
                                                .read<AdminOrderCubit>()
                                                .setExpectedDeliveryDate(
                                                order.id, date);
                                          }
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.primary,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                            BorderRadius.circular(12),
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
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    ListView.separated(
                                      shrinkWrap: true,
                                      physics:
                                      const NeverScrollableScrollPhysics(),
                                      itemCount: order.items.length,
                                      separatorBuilder: (context, index) =>
                                      const SizedBox(height: 12),
                                      itemBuilder: (context, index) {
                                        final item = order.items[index];
                                        return Card(
                                          elevation: 4,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                            BorderRadius.circular(12),
                                          ),
                                          color: AppColors.cardBackground,
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 8.0, horizontal: 12.0),
                                            child: Column(
                                              crossAxisAlignment:
                                              CrossAxisAlignment.start,
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
                                                      color: AppColors
                                                          .textSecondary
                                                          .withOpacity(0.5),
                                                      width: 1,
                                                    ),
                                                    borderRadius:
                                                    BorderRadius.circular(12),
                                                  ),
                                                  child: Table(
                                                    border: TableBorder(
                                                      verticalInside: BorderSide(
                                                        color: AppColors
                                                            .textSecondary
                                                            .withOpacity(0.5),
                                                        width: 1,
                                                      ),
                                                      horizontalInside: BorderSide(
                                                        color: AppColors
                                                            .textSecondary
                                                            .withOpacity(0.5),
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
                                                            padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                              vertical: 4.0,
                                                              horizontal: 8.0,
                                                            ),
                                                            child: Align(
                                                              alignment:
                                                              Alignment
                                                                  .centerLeft,
                                                              child: Text(
                                                                'Subtotal (₹${item.price} x ${item.quantity})',
                                                                style:
                                                                const TextStyle(
                                                                  fontSize: 14,
                                                                  color: AppColors
                                                                      .textSecondary,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          Padding(
                                                            padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                              vertical: 4.0,
                                                              horizontal: 8.0,
                                                            ),
                                                            child: Align(
                                                              alignment:
                                                              Alignment
                                                                  .centerRight,
                                                              child: Text(
                                                                '₹${(item.price * item.quantity).toStringAsFixed(2)}',
                                                                style:
                                                                const TextStyle(
                                                                  fontSize: 14,
                                                                  color: AppColors
                                                                      .textPrimary,
                                                                  fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      TableRow(
                                                        children: [
                                                          Padding(
                                                            padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                              vertical: 4.0,
                                                              horizontal: 8.0,
                                                            ),
                                                            child: Align(
                                                              alignment:
                                                              Alignment
                                                                  .centerLeft,
                                                              child: Text(
                                                                'Tax (${(item.taxRate * 100).toStringAsFixed(0)}%)',
                                                                style:
                                                                const TextStyle(
                                                                  fontSize: 14,
                                                                  color: AppColors
                                                                      .textSecondary,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          Padding(
                                                            padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                              vertical: 4.0,
                                                              horizontal: 8.0,
                                                            ),
                                                            child: Align(
                                                              alignment:
                                                              Alignment
                                                                  .centerRight,
                                                              child: Text(
                                                                '₹${item.taxAmount.toStringAsFixed(2)}',
                                                                style:
                                                                const TextStyle(
                                                                  fontSize: 14,
                                                                  color: AppColors
                                                                      .textSecondary,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      TableRow(
                                                        decoration: BoxDecoration(
                                                          color: AppColors.primary
                                                              .withOpacity(0.2),
                                                          borderRadius:
                                                          const BorderRadius
                                                              .only(
                                                            bottomLeft:
                                                            Radius.circular(
                                                                12),
                                                            bottomRight:
                                                            Radius.circular(
                                                                12),
                                                          ),
                                                        ),
                                                        children: [
                                                          const Padding(
                                                            padding: EdgeInsets
                                                                .symmetric(
                                                              vertical: 4.0,
                                                              horizontal: 8.0,
                                                            ),
                                                            child: Align(
                                                              alignment: Alignment
                                                                  .centerLeft,
                                                              child: Text(
                                                                'Total',
                                                                style: TextStyle(
                                                                  fontSize: 14,
                                                                  color: AppColors
                                                                      .textPrimary,
                                                                  fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          Padding(
                                                            padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                              vertical: 4.0,
                                                              horizontal: 8.0,
                                                            ),
                                                            child: Align(
                                                              alignment:
                                                              Alignment
                                                                  .centerRight,
                                                              child: Text(
                                                                '₹${((item.price * item.quantity) + item.taxAmount).toStringAsFixed(2)}',
                                                                style:
                                                                const TextStyle(
                                                                  fontSize: 14,
                                                                  color: AppColors
                                                                      .textPrimary,
                                                                  fontWeight:
                                                                  FontWeight
                                                                      .bold,
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
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
              ),
            ),
          );
        },
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