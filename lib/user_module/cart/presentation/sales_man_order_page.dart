import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:requirment_gathering_app/core_module/presentation/widget/custom_appbar.dart';
import 'package:requirment_gathering_app/core_module/service_locator/service_locator.dart';
import 'package:requirment_gathering_app/core_module/utils/AppColor.dart';
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
        BlocProvider(create: (_) => sl<CartCubit>()),
        BlocProvider(create: (_) => sl<OrderCubit>()),
        BlocProvider(create: (_) => sl<SalesmanOrderCubit>()),
      ],
      child: BlocConsumer<SalesmanOrderCubit, SalesmanOrderState>(
        // Control when the listener is triggered to avoid repeated dialogs
        listenWhen: (previous, current) =>
        current is SalesmanOrderPlaced || current is SalesmanOrderError,
        listener: (context, state) {
          if (state is SalesmanOrderPlaced) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Order placed successfully!')),
            );
            Navigator.of(context).pop();
          } else if (state is SalesmanOrderError) {
            // Show an AlertDialog instead of a SnackBar for errors
            showDialog(
              context: context,
              barrierDismissible: false, // Prevent dismissing by tapping outside
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
                    style: const TextStyle(color: AppColors.textPrimary),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(dialogContext).pop(); // Close the dialog
                        // Call a retry method to reload the data
                        // context.read<SalesmanOrderCubit>().retry();
                      },
                      child: const Text(
                        'Retry',
                        style: TextStyle(color: AppColors.primary),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(dialogContext).pop(); // Close the dialog
                      },
                      child: const Text(
                        'Dismiss',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ),
                  ],
                );
              },
            );
          }
        },
        // Control when the builder is triggered to avoid unnecessary rebuilds
        buildWhen: (previous, current) =>
        current is SalesmanOrderLoading ||
            current is SalesmanOrderLoaded ||
            previous is SalesmanOrderLoading ||
            previous is SalesmanOrderLoaded,
        builder: (context, state) {
          // Determine if we should show a loading overlay
          final isLoading = state is SalesmanOrderLoading;

          return Stack(
            children: [
              Scaffold(
                appBar: const CustomAppBar(
                  title: 'Salesman Order',
                  automaticallyImplyLeading: false,
                ),
                body: Stack(
                  children: [
                    // Main scrollable content
                    CustomScrollView(
                      slivers: [
                        // Collapsing section (Customer Selection)
                        SliverAppBar(
                          pinned: false,
                          floating: false,
                          automaticallyImplyLeading: false,
                          expandedHeight: 220,
                          flexibleSpace: FlexibleSpaceBar(
                            background: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Theme.of(context)
                                        .primaryColor
                                        .withOpacity(0.1),
                                    Theme.of(context)
                                        .primaryColor
                                        .withOpacity(0.3),
                                  ],
                                ),
                              ),
                              child: SafeArea(
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Customer Selection Section
                                      const Text(
                                        'Select Customer',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      DropdownButtonFormField<UserInfo>(
                                        decoration: const InputDecoration(
                                          labelText: 'Customer',
                                          border: OutlineInputBorder(),
                                          contentPadding: EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 8,
                                          ),
                                        ),
                                        value: state is SalesmanOrderLoaded
                                            ? state.selectedCustomer
                                            : null,
                                        hint: const Text('Select a customer'),
                                        items: state is SalesmanOrderLoaded
                                            ? [
                                          ...state.customers.map(
                                                (customer) => DropdownMenuItem(
                                              value: customer,
                                              child: Text(
                                                  customer.userName ??
                                                      'Unknown'),
                                            ),
                                          ),
                                          const DropdownMenuItem(
                                            value: null,
                                            child: Text('Add New Customer'),
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
                                        const SizedBox(height: 8),
                                        TextField(
                                          decoration: const InputDecoration(
                                            labelText: 'New Customer Name',
                                            border: OutlineInputBorder(),
                                            contentPadding: EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 8,
                                            ),
                                          ),
                                          onChanged: (value) {
                                            context
                                                .read<SalesmanOrderCubit>()
                                                .setCustomCustomerName(value);
                                          },
                                        ),
                                      ],
                                      const SizedBox(height: 16),
                                      // Add Products Header (will collapse)
                                      const Text(
                                        'Add Products',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        // Sticky Search Bar
                        SliverPersistentHeader(
                          pinned: true,
                          delegate: _StickySearchBarDelegate(
                            onSearchChanged: (value) {
                              context
                                  .read<SalesmanOrderCubit>()
                                  .searchProducts(value);
                            },
                          ),
                        ),
                        // Product List
                        if (state is SalesmanOrderLoaded &&
                            state.filteredProducts.isEmpty)
                          const SliverFillRemaining(
                            hasScrollBody: false,
                            child: Center(
                              child: Text(
                                'No products found',
                                style: TextStyle(color: AppColors.textSecondary),
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
                                  elevation: 4,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Row(
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
                                                      fontWeight:
                                                      FontWeight.bold,
                                                      color:
                                                      AppColors.textPrimary,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    'Price: ₹${product.price.toStringAsFixed(2)}',
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                      color: AppColors
                                                          .textSecondary,
                                                    ),
                                                  ),
                                                  Text(
                                                    'Tax Rate: ${(product.taxRate * 100).toStringAsFixed(0)}%',
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                      color: AppColors
                                                          .textSecondary,
                                                    ),
                                                  ),
                                                  Text(
                                                    'Price with Tax: ₹${product.priceWithTax.toStringAsFixed(2)}',
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                      color: AppColors
                                                          .textSecondary,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Row(
                                              children: [
                                                IconButton(
                                                  icon: const Icon(
                                                    Icons.remove,
                                                    color: AppColors.red,
                                                  ),
                                                  onPressed: () {
                                                    context
                                                        .read<
                                                        SalesmanOrderCubit>()
                                                        .updateProductQuantity(
                                                      product.id,
                                                      false,
                                                    );
                                                  },
                                                ),
                                                Text(
                                                  quantity.toString(),
                                                  style: const TextStyle(
                                                      fontSize: 16),
                                                ),
                                                IconButton(
                                                  icon: const Icon(
                                                    Icons.add,
                                                    color: AppColors.green,
                                                  ),
                                                  onPressed: () {
                                                    context
                                                        .read<
                                                        SalesmanOrderCubit>()
                                                        .updateProductQuantity(
                                                      product.id,
                                                      true,
                                                    );
                                                  },
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        if (quantity > 0) ...[
                                          const SizedBox(height: 8),
                                          Align(
                                            alignment: Alignment.centerRight,
                                            child: Container(
                                              decoration: BoxDecoration(
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
                                                        padding: const EdgeInsets
                                                            .symmetric(
                                                          vertical: 4.0,
                                                          horizontal: 8.0,
                                                        ),
                                                        child: Align(
                                                          alignment: Alignment
                                                              .centerLeft,
                                                          child: Text(
                                                            'Subtotal (₹${product.price.toStringAsFixed(2)} x $quantity)',
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
                                                        padding: const EdgeInsets
                                                            .symmetric(
                                                          vertical: 4.0,
                                                          horizontal: 8.0,
                                                        ),
                                                        child: Align(
                                                          alignment: Alignment
                                                              .centerRight,
                                                          child: Text(
                                                            '₹${context.read<SalesmanOrderCubit>().calculateProductSubtotal(product.id).toStringAsFixed(2)}',
                                                            style:
                                                            const TextStyle(
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
                                                          horizontal: 8.0,
                                                        ),
                                                        child: Align(
                                                          alignment: Alignment
                                                              .centerLeft,
                                                          child: Text(
                                                            'Tax (${(product.taxRate * 100).toStringAsFixed(0)}%)',
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
                                                        padding: const EdgeInsets
                                                            .symmetric(
                                                          vertical: 4.0,
                                                          horizontal: 8.0,
                                                        ),
                                                        child: Align(
                                                          alignment: Alignment
                                                              .centerRight,
                                                          child: Text(
                                                            '₹${context.read<SalesmanOrderCubit>().calculateProductTax(product.id).toStringAsFixed(2)}',
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
                                                          .withOpacity(0.1),
                                                      borderRadius:
                                                      const BorderRadius
                                                          .only(
                                                        bottomLeft:
                                                        Radius.circular(12),
                                                        bottomRight:
                                                        Radius.circular(12),
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
                                                              FontWeight.bold,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding: const EdgeInsets
                                                            .symmetric(
                                                          vertical: 4.0,
                                                          horizontal: 8.0,
                                                        ),
                                                        child: Align(
                                                          alignment: Alignment
                                                              .centerRight,
                                                          child: Text(
                                                            '₹${context.read<SalesmanOrderCubit>().calculateProductTotal(product.id).toStringAsFixed(2)}',
                                                            style:
                                                            const TextStyle(
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
                        // Extra padding to avoid overlap with the fixed button
                        const SliverToBoxAdapter(child: SizedBox(height: 80)),
                      ],
                    ),
                    // Fixed Review Order Button at the bottom
                    Positioned(
                      left: 16,
                      right: 16,
                      bottom: 16,
                      child: Builder(
                        builder: (buttonContext) {
                          return ElevatedButton(
                            onPressed: () {
                              final cubit = context.read<SalesmanOrderCubit>();
                              final currentState = cubit.state;
                              if (currentState is SalesmanOrderLoaded) {
                                // Check if any product is selected
                                bool hasItems = currentState.productQuantities
                                    .values
                                    .any((quantity) => quantity > 0);
                                if (!hasItems) {
                                  ScaffoldMessenger.of(buttonContext)
                                      .showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            'Please add at least one product to the order')),
                                  );
                                  return;
                                }
                                // Show bottom sheet with price breakup and place order option
                                showModalBottomSheet(
                                  context: buttonContext,
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(16)),
                                  ),
                                  isScrollControlled: true,
                                  builder: (context) {
                                    return SingleChildScrollView(
                                      child: Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'Order Summary',
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
                                                            'Subtotal (All Items)',
                                                            style: TextStyle(
                                                              fontSize: 18,
                                                              fontWeight:
                                                              FontWeight.bold,
                                                              color: AppColors
                                                                  .textPrimary,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding: const EdgeInsets
                                                            .symmetric(
                                                          vertical: 4.0,
                                                          horizontal: 8.0,
                                                        ),
                                                        child: Align(
                                                          alignment: Alignment
                                                              .centerRight,
                                                          child: Text(
                                                            '₹${cubit.calculateOverallSubtotal().toStringAsFixed(2)}',
                                                            style:
                                                            const TextStyle(
                                                              fontSize: 18,
                                                              fontWeight:
                                                              FontWeight.bold,
                                                              color: AppColors
                                                                  .textPrimary,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  TableRow(
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
                                                            'Total Tax',
                                                            style: TextStyle(
                                                              fontSize: 16,
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
                                                          horizontal: 8.0,
                                                        ),
                                                        child: Align(
                                                          alignment: Alignment
                                                              .centerRight,
                                                          child: Text(
                                                            '₹${cubit.calculateOverallTax().toStringAsFixed(2)}',
                                                            style:
                                                            const TextStyle(
                                                              fontSize: 16,
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
                                                      const BorderRadius
                                                          .only(
                                                        bottomLeft:
                                                        Radius.circular(12),
                                                        bottomRight:
                                                        Radius.circular(12),
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
                                                              fontSize: 20,
                                                              fontWeight:
                                                              FontWeight.bold,
                                                              color: AppColors
                                                                  .textPrimary,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding: const EdgeInsets
                                                            .symmetric(
                                                          vertical: 4.0,
                                                          horizontal: 8.0,
                                                        ),
                                                        child: Align(
                                                          alignment: Alignment
                                                              .centerRight,
                                                          child: Text(
                                                            '₹${cubit.calculateOverallTotal().toStringAsFixed(2)}',
                                                            style:
                                                            const TextStyle(
                                                              fontSize: 20,
                                                              fontWeight:
                                                              FontWeight.bold,
                                                              color: AppColors
                                                                  .textPrimary,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(height: 16),
                                            ElevatedButton(
                                              onPressed: () {
                                                cubit.placeOrder();
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                AppColors.primary,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                  BorderRadius.circular(12),
                                                ),
                                                padding: const EdgeInsets
                                                    .symmetric(vertical: 16.0),
                                              ),
                                              child: const Center(
                                                child: Text(
                                                  'Place Order',
                                                  style: TextStyle(
                                                    color: AppColors.white,
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
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
                              padding:
                              const EdgeInsets.symmetric(vertical: 16.0),
                            ),
                            child: const Center(
                              child: Text(
                                'Review Order',
                                style: TextStyle(
                                  color: AppColors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              // Loading overlay
              if (isLoading)
                Container(
                  color: Colors.black.withOpacity(0.5),
                  child: const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

// Delegate for the sticky search bar
class _StickySearchBarDelegate extends SliverPersistentHeaderDelegate {
  final Function(String) onSearchChanged;

  _StickySearchBarDelegate({required this.onSearchChanged});

  @override
  double get minExtent => 60;

  @override
  double get maxExtent => 60;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search Products',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
        ),
        onChanged: onSearchChanged,
      ),
    );
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}