import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:requirment_gathering_app/core_module/coordinator/coordinator.dart';
import 'package:requirment_gathering_app/core_module/service_locator/service_locator.dart';
import 'package:requirment_gathering_app/core_module/utils/AppColor.dart';
import 'package:requirment_gathering_app/core_module/utils/AppLabels.dart';
import 'package:requirment_gathering_app/user_module/cart/presentation/cart_cubit.dart';

@RoutePage()
class CartPage extends StatelessWidget {
  const CartPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<CartCubit>(),
      child: Scaffold(
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
                    children: [
                      Expanded(
                        child: ListView.separated(
                          itemCount: state.items.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final item = state.items[index];
                            return Card(
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 8.0, horizontal: 12.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.shopping_cart,
                                          color: AppColors.primary,
                                          size: 24,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            item.productName,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.textPrimary,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 4),
                                          decoration: BoxDecoration(
                                            color: Colors.blue[700],
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Row(
                                            children: [
                                              IconButton(
                                                icon: const Icon(Icons.remove,
                                                    color: Colors.white,
                                                    size: 16),
                                                onPressed: () =>
                                                    cubit.updateQuantity(
                                                  item.productId,
                                                  item.quantity - 1,
                                                ),
                                                padding: EdgeInsets.zero,
                                                constraints:
                                                    const BoxConstraints(),
                                              ),
                                              Text(
                                                item.quantity.toString(),
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              IconButton(
                                                icon: const Icon(Icons.add,
                                                    color: Colors.white,
                                                    size: 16),
                                                onPressed: () =>
                                                    cubit.updateQuantity(
                                                  item.productId,
                                                  item.quantity + 1,
                                                ),
                                                padding: EdgeInsets.zero,
                                                constraints:
                                                    const BoxConstraints(),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        IconButton(
                                          icon: const Icon(Icons.delete,
                                              color: AppColors.red, size: 20),
                                          onPressed: () => cubit
                                              .removeFromCart(item.productId),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: AppColors.textSecondary
                                                .withOpacity(0.5),
                                            width: 1,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(12),
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
                                                Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      vertical: 4.0,
                                                      horizontal: 8.0),
                                                  child: Align(
                                                    alignment:
                                                        Alignment.centerLeft,
                                                    child: Text(
                                                      'Subtotal (₹${item.price} x ${item.quantity})',
                                                      style: const TextStyle(
                                                        fontSize: 14,
                                                        color: AppColors
                                                            .textSecondary,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      vertical: 4.0,
                                                      horizontal: 8.0),
                                                  child: Align(
                                                    alignment:
                                                        Alignment.centerRight,
                                                    child: Text(
                                                      '₹${cubit.calculateProductSubtotal(item).toStringAsFixed(2)}',
                                                      style: const TextStyle(
                                                        fontSize: 14,
                                                        color: AppColors
                                                            .textPrimary,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            TableRow(
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      vertical: 4.0,
                                                      horizontal: 8.0),
                                                  child: Align(
                                                    alignment:
                                                        Alignment.centerLeft,
                                                    child: Text(
                                                      'Tax (${(item.taxRate * 100).toStringAsFixed(0)}%)',
                                                      style: const TextStyle(
                                                        fontSize: 14,
                                                        color: AppColors
                                                            .textSecondary,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      vertical: 4.0,
                                                      horizontal: 8.0),
                                                  child: Align(
                                                    alignment:
                                                        Alignment.centerRight,
                                                    child: Text(
                                                      '₹${item.taxAmount.toStringAsFixed(2)}',
                                                      style: const TextStyle(
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
                                                    .withOpacity(0.1),
                                                borderRadius:
                                                    const BorderRadius.only(
                                                  bottomLeft:
                                                      Radius.circular(12),
                                                  bottomRight:
                                                      Radius.circular(12),
                                                ),
                                              ),
                                              children: [
                                                const Padding(
                                                  padding: EdgeInsets.symmetric(
                                                      vertical: 4.0,
                                                      horizontal: 8.0),
                                                  child: Align(
                                                    alignment:
                                                        Alignment.centerLeft,
                                                    child: Text(
                                                      'Total',
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        color: AppColors
                                                            .textPrimary,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      vertical: 4.0,
                                                      horizontal: 8.0),
                                                  child: Align(
                                                    alignment:
                                                        Alignment.centerRight,
                                                    child: Text(
                                                      '₹${cubit.calculateProductTotal(item).toStringAsFixed(2)}',
                                                      style: const TextStyle(
                                                        fontSize: 14,
                                                        color: AppColors
                                                            .textPrimary,
                                                        fontWeight:
                                                            FontWeight.bold,
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
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
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
                                      color: AppColors.textSecondary
                                          .withOpacity(0.5),
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
                                                vertical: 4.0, horizontal: 8.0),
                                            child: Align(
                                              alignment: Alignment.centerLeft,
                                              child: Text(
                                                'Subtotal (All Items)',
                                                style: TextStyle(
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
                                                '₹${subtotal.toStringAsFixed(2)}',
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
                                          const Padding(
                                            padding: EdgeInsets.symmetric(
                                                vertical: 4.0, horizontal: 8.0),
                                            child: Align(
                                              alignment: Alignment.centerLeft,
                                              child: Text(
                                                'Total Tax',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  color:
                                                      AppColors.textSecondary,
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
                                                '₹${totalTax.toStringAsFixed(2)}',
                                                style: const TextStyle(
                                                  fontSize: 16,
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
                                          color: AppColors.primary
                                              .withOpacity(0.1),
                                          // borderRadius: const BorderRadius.only(
                                          //   bottomLeft: Radius.circular(16),
                                          //   bottomRight: Radius.circular(16),
                                          // ),
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
                                                '₹${totalWithTax.toStringAsFixed(2)}',
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
                                        ? () => sl<Coordinator>()
                                            .navigateToPreviewOrderPage()
                                        : null,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: const Text(
                                      AppLabels.checkout,
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
    );
  }
}
