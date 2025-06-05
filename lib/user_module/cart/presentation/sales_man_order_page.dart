import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:requirment_gathering_app/core_module/presentation/widget/custom_appbar.dart';
import 'package:requirment_gathering_app/core_module/service_locator/service_locator.dart';
import 'package:requirment_gathering_app/core_module/utils/AppColor.dart';
import 'package:requirment_gathering_app/core_module/utils/custom_loading_dialog.dart';
import 'package:requirment_gathering_app/super_admin_module/data/user_info.dart';
import 'package:requirment_gathering_app/user_module/cart/presentation/cart_cubit.dart';
import 'package:requirment_gathering_app/user_module/cart/presentation/order_cubit.dart';
import 'package:requirment_gathering_app/user_module/cart/presentation/sales_man_order_cubit.dart';

@RoutePage()
class SalesmanOrderPage extends StatelessWidget {
  const SalesmanOrderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<SalesmanOrderCubit>()),
      ],
      child: BlocConsumer<SalesmanOrderCubit, SalesmanOrderState>(
        listenWhen: (previous, current) =>
            current is SalesmanOrderPlaced || current is SalesmanOrderError,
        listener: (context, state) {
          if (state is SalesmanOrderPlaced) {
            
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Order placed successfully!',
                  style: TextStyle(color: AppColors.white),
                ),
                backgroundColor: AppColors.green,
                behavior: SnackBarBehavior.floating,
                margin: EdgeInsets.all(16),
              ),
            );
            Navigator.of(context).pop();
            context.read<SalesmanOrderCubit>().searchProducts('');
          } else if (state is SalesmanOrderError) {
            // Dismiss any loading dialog
            Navigator.of(context, rootNavigator: true)
                .popUntil((route) => route.isFirst);
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (dialogContext) {
                return AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  title: const Text(
                    'Error',
                    style: TextStyle(
                      color: AppColors.red,
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                    ),
                  ),
                  content: Text(
                    state.message,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(dialogContext).pop();
                      },
                      child: const Text(
                        'Dismiss',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(dialogContext).pop();
                        // context.read<SalesmanOrderCubit>().retry();
                      },
                      child: const Text(
                        'Retry',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          }
        },
        buildWhen: (previous, current) =>
            current is SalesmanOrderLoading ||
            current is SalesmanOrderLoaded ||
            previous is SalesmanOrderLoading ||
            previous is SalesmanOrderLoaded,
        builder: (context, state) {
          // Show loading dialog when state is SalesmanOrderLoading
          if (state is SalesmanOrderLoading) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (dialogContext) {
                  return CustomLoadingDialog(
                      message: state.dialogMessage);
                },
              );
            });
          } else if (state is SalesmanOrderLoaded) {
            if (state.isLoading ?? false) Navigator.of(context).pop();
          }

          return Scaffold(
            appBar: const CustomAppBar(
              title: 'Salesman Order',
              // automaticallyImplyLeading: false,
            ),
            body: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.primary.withOpacity(0.05),
                          AppColors.primary.withOpacity(0.15),
                        ],
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Select Customer',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<UserInfo>(
                          decoration: InputDecoration(
                            labelText: 'Customer',
                            labelStyle:
                                const TextStyle(color: AppColors.textSecondary),
                            filled: true,
                            fillColor: AppColors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                  color:
                                      AppColors.textSecondary.withOpacity(0.3)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                  color:
                                      AppColors.textSecondary.withOpacity(0.3)),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                          ),
                          value: state is SalesmanOrderLoaded
                              ? state.selectedCustomer
                              : null,
                          hint: const Text(
                            'Select a customer',
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                          items: state is SalesmanOrderLoaded
                              ? [
                                  ...state.customers.map(
                                    (customer) => DropdownMenuItem(
                                      value: customer,
                                      child: Text(
                                        customer.userName ?? 'Unknown',
                                        style: const TextStyle(
                                            color: AppColors.textPrimary),
                                      ),
                                    ),
                                  ),
                                  const DropdownMenuItem(
                                    value: null,
                                    child: Text(
                                      'Add New Customer',
                                      style:
                                          TextStyle(color: AppColors.primary),
                                    ),
                                  ),
                                ]
                              : [],
                          onChanged: (value) {
                            if (state is SalesmanOrderLoaded) {
                              context
                                  .read<SalesmanOrderCubit>()
                                  .selectCustomer(value);
                            }
                          },
                        ),
                        if (state is SalesmanOrderLoaded &&
                            state.selectedCustomer == null) ...[
                          const SizedBox(height: 12),
                          TextField(
                            decoration: InputDecoration(
                              labelText: 'New Customer Name',
                              labelStyle: const TextStyle(
                                  color: AppColors.textSecondary),
                              filled: true,
                              fillColor: AppColors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                    color: AppColors.textSecondary
                                        .withOpacity(0.3)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                    color: AppColors.textSecondary
                                        .withOpacity(0.3)),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                            ),
                            onChanged: (value) {
                              context
                                  .read<SalesmanOrderCubit>()
                                  .setCustomCustomerName(value);
                            },
                          ),
                        ],
                        const SizedBox(height: 16),
                        const Text(
                          'Add Products',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ),
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _StickySearchBarDelegate(
                    onSearchChanged: (value) {
                      context.read<SalesmanOrderCubit>().searchProducts(value);
                    },
                  ),
                ),
                if (state is SalesmanOrderLoaded &&
                    state.filteredProducts.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        child: const Padding(
                          padding: EdgeInsets.all(16),
                          child: Text(
                            'No products found',
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                else if (state is SalesmanOrderLoaded)
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final product = state.filteredProducts[index];
                        final quantity =
                            state.productQuantities[product.id] ?? 0;
                        return Card(
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          margin: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            product.name,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.textPrimary,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Price: ₹${product.price.toStringAsFixed(2)}',
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: AppColors.textSecondary,
                                            ),
                                          ),
                                          Text(
                                            'Tax Rate: ${(product.taxRate * 100).toStringAsFixed(0)}%',
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: AppColors.textSecondary,
                                            ),
                                          ),
                                          Text(
                                            'Price with Tax: ₹${product.priceWithTax.toStringAsFixed(2)}',
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: AppColors.textSecondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      decoration: BoxDecoration(
                                        color: AppColors.white,
                                        borderRadius: BorderRadius.circular(24),
                                        border: Border.all(
                                            color: AppColors.textSecondary
                                                .withOpacity(0.3)),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: Icon(
                                              Icons.remove,
                                              color: quantity > 0
                                                  ? AppColors.red
                                                  : AppColors.textSecondary,
                                              size: 20,
                                            ),
                                            onPressed: () {
                                              context
                                                  .read<SalesmanOrderCubit>()
                                                  .updateProductQuantity(
                                                      product.id, false);
                                            },
                                          ),
                                          SizedBox(
                                            width: 24,
                                            child: Text(
                                              '$quantity',
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                color: AppColors.textPrimary,
                                              ),
                                            ),
                                          ),
                                          IconButton(
                                            icon: const Icon(
                                              Icons.add,
                                              color: AppColors.green,
                                              size: 20,
                                            ),
                                            onPressed: () {
                                              context
                                                  .read<SalesmanOrderCubit>()
                                                  .updateProductQuantity(
                                                      product.id, true);
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                if (quantity > 0) ...[
                                  const SizedBox(height: 12),
                                  Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: AppColors.textSecondary
                                              .withOpacity(0.3)),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Table(
                                      border: TableBorder(
                                        verticalInside: BorderSide(
                                            color: AppColors.textSecondary
                                                .withOpacity(0.3)),
                                        horizontalInside: BorderSide(
                                            color: AppColors.textSecondary
                                                .withOpacity(0.3)),
                                      ),
                                      columnWidths: {
                                        0: const FlexColumnWidth(3),
                                        1: const FlexColumnWidth(2),
                                      },
                                      children: [
                                        TableRow(
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 8,
                                                      horizontal: 12),
                                              child: Text(
                                                'Subtotal (₹${product.price.toStringAsFixed(2)} x $quantity)',
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  color:
                                                      AppColors.textSecondary,
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 8,
                                                      horizontal: 12),
                                              child: Text(
                                                '₹${context.read<SalesmanOrderCubit>().calculateProductSubtotal(product.id).toStringAsFixed(2)}',
                                                textAlign: TextAlign.right,
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                  color: AppColors.textPrimary,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        TableRow(
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 8,
                                                      horizontal: 12),
                                              child: Text(
                                                'Tax (${(product.taxRate * 100).toStringAsFixed(0)}%)',
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  color:
                                                      AppColors.textSecondary,
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 8,
                                                      horizontal: 12),
                                              child: Text(
                                                '₹${context.read<SalesmanOrderCubit>().calculateProductTax(product.id).toStringAsFixed(2)}',
                                                textAlign: TextAlign.right,
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  color:
                                                      AppColors.textSecondary,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        TableRow(
                                          decoration: BoxDecoration(
                                            color: AppColors.primary
                                                .withOpacity(0.05),
                                            borderRadius:
                                                const BorderRadius.only(
                                              bottomLeft: Radius.circular(12),
                                              bottomRight: Radius.circular(12),
                                            ),
                                          ),
                                          children: [
                                            const Padding(
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 8, horizontal: 12),
                                              child: Text(
                                                'Total',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w700,
                                                  color: AppColors.textPrimary,
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 8,
                                                      horizontal: 12),
                                              child: Text(
                                                '₹${context.read<SalesmanOrderCubit>().calculateProductTotal(product.id).toStringAsFixed(2)}',
                                                textAlign: TextAlign.right,
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w700,
                                                  color: AppColors.textPrimary,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      },
                      childCount: state.filteredProducts.length,
                    ),
                  )
                else
                  const SliverToBoxAdapter(child: SizedBox.shrink()),
                const SliverToBoxAdapter(child: SizedBox(height: 80)),
              ],
            ),
            bottomNavigationBar: Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: () {
                  final cubit = context.read<SalesmanOrderCubit>();
                  final currentState = cubit.state;
                  if (currentState is SalesmanOrderLoaded) {
                    bool hasItems = currentState.productQuantities.values
                        .any((quantity) => quantity > 0);
                    if (!hasItems) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Please add at least one product to the order',
                            style: TextStyle(color: AppColors.white),
                          ),
                          backgroundColor: AppColors.red,
                          behavior: SnackBarBehavior.floating,
                          margin: EdgeInsets.all(16),
                        ),
                      );
                      return;
                    }
                    showModalBottomSheet(
                      context: context,
                      shape: const RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(20)),
                      ),
                      isScrollControlled: true,
                      backgroundColor: AppColors.white,
                      builder: (context) {
                        return Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Order Summary',
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.close,
                                      color: AppColors.textSecondary,
                                      size: 24,
                                    ),
                                    onPressed: () => Navigator.pop(context),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      color: AppColors.textSecondary
                                          .withOpacity(0.3)),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Table(
                                  border: TableBorder(
                                    verticalInside: BorderSide(
                                        color: AppColors.textSecondary
                                            .withOpacity(0.3)),
                                    horizontalInside: BorderSide(
                                        color: AppColors.textSecondary
                                            .withOpacity(0.3)),
                                  ),
                                  columnWidths: {
                                    0: const FlexColumnWidth(3),
                                    1: const FlexColumnWidth(2),
                                  },
                                  children: [
                                    TableRow(
                                      children: [
                                        const Padding(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 12, horizontal: 16),
                                          child: Text(
                                            'Subtotal (All Items)',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.textPrimary,
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 12, horizontal: 16),
                                          child: Text(
                                            '₹${cubit.calculateOverallSubtotal().toStringAsFixed(2)}',
                                            textAlign: TextAlign.right,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.textPrimary,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    TableRow(
                                      children: [
                                        const Padding(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 12, horizontal: 16),
                                          child: Text(
                                            'Total Tax',
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: AppColors.textSecondary,
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 12, horizontal: 16),
                                          child: Text(
                                            '₹${cubit.calculateOverallTax().toStringAsFixed(2)}',
                                            textAlign: TextAlign.right,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              color: AppColors.textSecondary,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    TableRow(
                                      decoration: BoxDecoration(
                                        color:
                                            AppColors.primary.withOpacity(0.05),
                                        borderRadius: const BorderRadius.only(
                                          bottomLeft: Radius.circular(12),
                                          bottomRight: Radius.circular(12),
                                        ),
                                      ),
                                      children: [
                                        const Padding(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 12, horizontal: 16),
                                          child: Text(
                                            'Total',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.textPrimary,
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 12, horizontal: 16),
                                          child: Text(
                                            '₹${cubit.calculateOverallTotal().toStringAsFixed(2)}',
                                            textAlign: TextAlign.right,
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.textPrimary,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.pop(context); // Hide bottom sheet
                                    cubit.placeOrder();
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16),
                                  ),
                                  child: const Text(
                                    'Place Order',
                                    style: TextStyle(
                                      color: AppColors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Review Order',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
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

class _StickySearchBarDelegate extends SliverPersistentHeaderDelegate {
  final Function(String) onSearchChanged;

  _StickySearchBarDelegate({required this.onSearchChanged});

  @override
  double get minExtent => 60;

  @override
  double get maxExtent => 60;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search Products',
          hintStyle: const TextStyle(color: AppColors.textSecondary),
          prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
          filled: true,
          fillColor: AppColors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                BorderSide(color: AppColors.textSecondary.withOpacity(0.3)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                BorderSide(color: AppColors.textSecondary.withOpacity(0.3)),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        onChanged: onSearchChanged,
      ),
    );
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) =>
      true;
}
