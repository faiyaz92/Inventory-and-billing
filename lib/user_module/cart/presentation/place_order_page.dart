import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:requirment_gathering_app/core_module/coordinator/coordinator.dart';
import 'package:requirment_gathering_app/core_module/presentation/widget/custom_appbar.dart';
import 'package:requirment_gathering_app/core_module/service_locator/service_locator.dart';
import 'package:requirment_gathering_app/core_module/utils/AppColor.dart';
import 'package:requirment_gathering_app/core_module/utils/AppLabels.dart';
import 'package:requirment_gathering_app/user_module/cart/presentation/cart_cubit.dart';
import 'package:requirment_gathering_app/user_module/cart/presentation/order_cubit.dart' as orderCubit;

@RoutePage()
class PreviewOrderPage extends StatelessWidget {
  const PreviewOrderPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => sl<CartCubit>()),
        BlocProvider(create: (context) => sl<orderCubit.OrderCubit>()),
      ],
      child: Scaffold(
        appBar: const CustomAppBar(
          title: AppLabels.previewOrder,
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
              child: BlocListener<CartCubit, CartState>(
                listener: (context, state) {
                  if (state is OrderCreated) {
                    context.read<orderCubit.OrderCubit>().placeOrder(state.order);
                  } else if (state is CartError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${AppLabels.error}: ${state.message}'),
                        backgroundColor: AppColors.red,
                      ),
                    );
                  }
                },
                child: BlocListener<orderCubit.OrderCubit, orderCubit.OrderState>(
                  listener: (context, state) {
                    if (state is orderCubit.OrderPlaced) {
                      context.read<CartCubit>().clearCart();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Order placed successfully!'),
                          backgroundColor: AppColors.green,
                        ),
                      );
                      sl<Coordinator>().navigateToOrderListPage();
                    } else if (state is orderCubit.OrderError) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${AppLabels.error}: ${state.message}'),
                          backgroundColor: AppColors.red,
                        ),
                      );
                    }
                  },
                  child: BlocBuilder<CartCubit, CartState>(
                    builder: (context, state) {
                      if (state is CartLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (state.items.isEmpty && state is! CartInitial) {
                        return Center(
                          child: Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Text(
                                AppLabels.yourCartIsEmpty,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: AppColors.black87,
                                ),
                              ),
                            ),
                          ),
                        );
                      }

                      final cubit = context.read<CartCubit>();
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          Expanded(
                            child: ListView.separated(
                              itemCount: state.items.length,
                              separatorBuilder: (context, index) => const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                final item = state.items[index];
                                return Card(
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
                                        Text(
                                          'Quantity: ${item.quantity}',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: AppColors.textSecondary,
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
                                                          'IQD ${cubit.calculateProductSubtotal(item).toStringAsFixed(2)}',
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
                                                    color: AppColors.primary.withOpacity(0.1),
                                                    // borderRadius: const BorderRadius.only(
                                                    //   bottomLeft: Radius.circular(12),
                                                    //   bottomRight: Radius.circular(12),
                                                    // ),
                                                  ),
                                                  children: [
                                                    Padding(
                                                      padding: const EdgeInsets.symmetric(
                                                          vertical: 4.0, horizontal: 8.0),
                                                      child: Align(
                                                        alignment: Alignment.centerLeft,
                                                        child: Text(
                                                          'Total',
                                                          style: const TextStyle(
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
                                                          'IQD ${cubit.calculateProductTotal(item).toStringAsFixed(2)}',
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
                                );
                              },
                            ),
                          ),
                          Container(
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(16),
                                topRight: Radius.circular(16),
                              ),
                            ),
                            padding: const EdgeInsets.all(16.0),
                            child: FutureBuilder<double>(
                              future: cubit.totalAmount,
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return const CircularProgressIndicator();
                                }
                                if (snapshot.hasError) {
                                  return const Text(
                                    'Error calculating total',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.red,
                                    ),
                                  );
                                }
                                final subtotal = cubit.calculateOverallSubtotal();
                                final totalTax = cubit.calculateOverallTax();
                                final totalWithTax = snapshot.data ?? 0.0;
                                return Column(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: AppColors.textSecondary.withOpacity(0.5),
                                          width: 1,
                                        ),
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(16),
                                          topRight: Radius.circular(16),
                                        ),
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
                                                    'Subtotal (All Items)',
                                                    style: const TextStyle(
                                                      fontSize: 18,
                                                      fontWeight: FontWeight.bold,
                                                      color: AppColors.textPrimary,
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
                                                    'IQD ${subtotal.toStringAsFixed(2)}',
                                                    style: const TextStyle(
                                                      fontSize: 18,
                                                      fontWeight: FontWeight.bold,
                                                      color: AppColors.textPrimary,
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
                                                    'Total Tax',
                                                    style: const TextStyle(
                                                      fontSize: 16,
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
                                                    'IQD ${totalTax.toStringAsFixed(2)}',
                                                    style: const TextStyle(
                                                      fontSize: 16,
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
                                                bottomLeft: Radius.circular(16),
                                                bottomRight: Radius.circular(16),
                                              ),
                                            ),
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.symmetric(
                                                    vertical: 4.0, horizontal: 8.0),
                                                child: Align(
                                                  alignment: Alignment.centerLeft,
                                                  child: Text(
                                                    'Total with Tax',
                                                    style: const TextStyle(
                                                      fontSize: 20,
                                                      fontWeight: FontWeight.bold,
                                                      color: AppColors.textPrimary,
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
                                                    'IQD ${totalWithTax.toStringAsFixed(2)}',
                                                    style: const TextStyle(
                                                      fontSize: 20,
                                                      fontWeight: FontWeight.bold,
                                                      color: AppColors.textPrimary,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: ElevatedButton(
                                        onPressed: state.items.isNotEmpty
                                            ? () {
                                          context.read<CartCubit>().createOrder();
                                        }
                                            : null,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.primary,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                        ),
                                        child: const Text(
                                          AppLabels.placeOrder,
                                          style: TextStyle(color: AppColors.white),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}