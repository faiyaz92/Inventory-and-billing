import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:requirment_gathering_app/company_admin_module/presentation/users/add_user_cubit.dart';
import 'package:requirment_gathering_app/core_module/presentation/widget/custom_appbar.dart';
import 'package:requirment_gathering_app/core_module/service_locator/service_locator.dart';
import 'package:requirment_gathering_app/core_module/utils/AppColor.dart';
import 'package:requirment_gathering_app/core_module/utils/custom_loading_dialog.dart';
import 'package:requirment_gathering_app/super_admin_module/data/user_info.dart';
import 'package:requirment_gathering_app/company_admin_module/service/user_services.dart';
import 'package:requirment_gathering_app/core_module/repository/account_repository.dart';
import 'package:requirment_gathering_app/super_admin_module/utils/user_type.dart';
import 'package:requirment_gathering_app/user_module/cart/presentation/sales_man_order_cubit.dart';

@RoutePage()
class SalesmanOrderPage extends StatelessWidget {
  const SalesmanOrderPage({super.key});

  @override
  Widget build(BuildContext context) {
    final userServices = sl<UserServices>();
    final cubit = sl<SalesmanOrderCubit>();

    return BlocProvider(
      create: (_) => cubit,
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
            cubit.searchProducts('');
          } else if (state is SalesmanOrderError) {
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
          if (state is SalesmanOrderLoading) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (dialogContext) {
                  return CustomLoadingDialog(message: state.dialogMessage);
                },
              );
            });
          } else if (state is SalesmanOrderLoaded) {
            if (state.isLoading ?? false) Navigator.of(context).pop();
          }

          return Scaffold(
            appBar: const CustomAppBar(
              title: 'Salesman Order',
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
                        InkWell(
                          onTap: () => _showCustomerSelectionDialog(context, userServices, cubit),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: AppColors.textSecondary.withOpacity(0.3)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  state is SalesmanOrderLoaded &&
                                      state.selectedCustomer != null
                                      ? state.selectedCustomer!.name ?? 'Unknown'
                                      : 'Select a customer',
                                  style: TextStyle(
                                    color: state is SalesmanOrderLoaded &&
                                        state.selectedCustomer != null
                                        ? AppColors.textPrimary
                                        : AppColors.textSecondary,
                                  ),
                                ),
                                const Icon(Icons.arrow_drop_down,
                                    color: AppColors.textSecondary),
                              ],
                            ),
                          ),
                        ),
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
                      cubit.searchProducts(value);
                    },
                  ),
                ),
                if (state is SalesmanOrderLoaded && state.filteredProducts.isEmpty)
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
                        final quantity = state.productQuantities[product.id] ?? 0;
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
                                    Column(
                                      children: [
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
                                                  cubit.updateProductQuantity(
                                                      product.id, false);
                                                },
                                              ),
                                              SizedBox(
                                                width: 48,
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
                                                  if (quantity < 9999999) {
                                                    cubit.updateProductQuantity(
                                                        product.id, true);
                                                  }
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            ElevatedButton(
                                              onPressed: () {
                                                _showQuantityInputDialog(
                                                    context, cubit, product.id);
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: AppColors.primary,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                padding: const EdgeInsets.symmetric(
                                                    horizontal: 8, vertical: 4),
                                              ),
                                              child: const Text(
                                                'Enter Manual Qty',
                                                style: TextStyle(
                                                  color: AppColors.white,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            ElevatedButton(
                                              onPressed: quantity > 0
                                                  ? () {
                                                cubit.setProductQuantity(
                                                    product.id, 0);
                                              }
                                                  : null,
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: AppColors.red,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                padding: const EdgeInsets.symmetric(
                                                    horizontal: 8, vertical: 4),
                                              ),
                                              child: const Text(
                                                'Clear',
                                                style: TextStyle(
                                                  color: AppColors.white,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
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
                        columnWidths: const {
                        0: FlexColumnWidth(3),
                        1: FlexColumnWidth(2),
                        },
                        children: [
                        TableRow(
                        children: [
                        Padding(
                        padding: const EdgeInsets.symmetric(
                        vertical: 8, horizontal: 12),
                        child: Text(
                        'Subtotal (₹${product.price.toStringAsFixed(2)} x $quantity)',
                        style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        ),
                        ),
                        ),
                        Padding(
                        padding: const EdgeInsets.symmetric(
                        vertical: 8, horizontal: 12),
                        child: Text(
                        '₹${cubit.calculateProductSubtotal(product.id).toStringAsFixed(2)}',
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
                        padding: const EdgeInsets.symmetric(
                        vertical: 8, horizontal: 12),
                        child: Text(
                        'Tax (${(product.taxRate * 100).toStringAsFixed(0)}%)',
                        style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        ),
                        ),
                        ),
                        Padding(
                        padding: const EdgeInsets.symmetric(
                        vertical: 8, horizontal: 12),
                        child: Text(
                        '₹${cubit.calculateProductTax(product.id).toStringAsFixed(2)}',
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                        fontSize: 14,
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
                        borderRadius: BorderRadius.only(
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
                        padding: const EdgeInsets.symmetric(
                        vertical: 8, horizontal: 12),
                        child: Text(
                        '₹${cubit.calculateProductTotal(product.id).toStringAsFixed(2)}',
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
                        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                      ),
                      isScrollControlled: true,
                      backgroundColor: AppColors.white,
                      builder: (context) {
                        final TextEditingController discountController =
                        TextEditingController(text: cubit.discount.toStringAsFixed(2));
                        final List<double> itemDiscounts = List.filled(
                            currentState.filteredProducts.length, 0.0); // Temporary item discounts
                        double additionalDiscount = cubit.discount; // Initialize with cubit discount

                        return StatefulBuilder(
                          builder: (context, setState) => Padding(
                            padding: const EdgeInsets.all(20),
                            child: SingleChildScrollView(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                  const Text(
                                    'Order Details',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: AppColors.textSecondary.withOpacity(0.3)),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Table(
                                      border: TableBorder(
                                        verticalInside: BorderSide(
                                            color: AppColors.textSecondary.withOpacity(0.3)),
                                        horizontalInside: BorderSide(
                                            color: AppColors.textSecondary.withOpacity(0.3)),
                                      ),
                                      columnWidths: const {
                                        0: FlexColumnWidth(3),
                                        1: FlexColumnWidth(1),
                                        2: FlexColumnWidth(1),
                                        3: FlexColumnWidth(1),
                                        4: FlexColumnWidth(1),
                                        5: FlexColumnWidth(1),
                                      },
                                      children: [
                                        TableRow(
                                          decoration: BoxDecoration(
                                            color: AppColors.primary.withOpacity(0.05),
                                          ),
                                          children: const [
                                            Padding(
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 8, horizontal: 12),
                                              child: Text(
                                                'Product',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w700,
                                                  color: AppColors.textPrimary,
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 8, horizontal: 12),
                                              child: Text(
                                                'Qty',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w700,
                                                  color: AppColors.textPrimary,
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 8, horizontal: 12),
                                              child: Text(
                                                'Subtotal',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w700,
                                                  color: AppColors.textPrimary,
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 8, horizontal: 12),
                                              child: Text(
                                                'Tax',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w700,
                                                  color: AppColors.textPrimary,
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 8, horizontal: 12),
                                              child: Text(
                                                'Discount',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w700,
                                                  color: AppColors.textPrimary,
                                                ),
                                              ),
                                            ),
                                            Padding(
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
                                          ],
                                        ),
                                        ...currentState.filteredProducts
                                            .asMap()
                                            .entries
                                            .where((entry) =>
                                        currentState.productQuantities[entry.value.id]! > 0)
                                            .map((entry) {
                                          final index = entry.key;
                                          final product = entry.value;
                                          final quantity =
                                          currentState.productQuantities[product.id]!;
                                          return TableRow(
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.symmetric(
                                                    vertical: 8, horizontal: 12),
                                                child: Text(
                                                  product.name,
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    color: AppColors.textPrimary,
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.symmetric(
                                                    vertical: 8, horizontal: 12),
                                                child: Text(
                                                  '$quantity',
                                                  textAlign: TextAlign.right,
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    color: AppColors.textPrimary,
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.symmetric(
                                                    vertical: 8, horizontal: 12),
                                                child: Text(
                                                  '₹${cubit.calculateProductSubtotal(product.id).toStringAsFixed(2)}',
                                                  textAlign: TextAlign.right,
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    color: AppColors.textPrimary,
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.symmetric(
                                                    vertical: 8, horizontal: 12),
                                                child: Text(
                                                  '₹${cubit.calculateProductTax(product.id).toStringAsFixed(2)}',
                                                  textAlign: TextAlign.right,
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    color: AppColors.textSecondary,
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.symmetric(
                                                    vertical: 8, horizontal: 12),
                                                child: TextFormField(
                                                  initialValue:
                                                  itemDiscounts[index].toStringAsFixed(2),
                                                  keyboardType:
                                                  TextInputType.numberWithOptions(decimal: true),
                                                  textAlign: TextAlign.right,
                                                  decoration: const InputDecoration(
                                                    border: InputBorder.none,
                                                    contentPadding: EdgeInsets.zero,
                                                    isDense: true,
                                                  ),
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    color: AppColors.textSecondary,
                                                  ),
                                                  onChanged: (value) {
                                                    final disc = double.tryParse(value) ?? 0.0;
                                                    itemDiscounts[index] = disc;
                                                    setState(() {});
                                                  },
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.symmetric(
                                                    vertical: 8, horizontal: 12),
                                                child: Text(
                                                  '₹${(cubit.calculateProductTotal(product.id) - itemDiscounts[index]).toStringAsFixed(2)}',
                                                  textAlign: TextAlign.right,
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w600,
                                                    color: AppColors.textPrimary,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          );
                                        }).toList(),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  TextField(
                                    controller: discountController,
                                    decoration: InputDecoration(
                                      labelText: 'Additional Discount (₹)',
                                      border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(8)),
                                      filled: true,
                                      fillColor: Colors.grey[100],
                                    ),
                                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                                    onChanged: (value) {
                                      additionalDiscount = double.tryParse(value) ?? 0.0;
                                      setState(() {});
                                    },
                                  ),
                                  const SizedBox(height: 20),
                                  Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: AppColors.textSecondary.withOpacity(0.3)),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Table(
                                      border: TableBorder(
                                        verticalInside: BorderSide(
                                            color: AppColors.textSecondary.withOpacity(0.3)),
                                        horizontalInside: BorderSide(
                                            color: AppColors.textSecondary.withOpacity(0.3)),
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
                                          children: [
                                            const Padding(
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 12, horizontal: 16),
                                              child: Text(
                                                'Item Discounts',
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
                                                '₹${itemDiscounts.fold<double>(0.0, (sum, disc) => sum + disc).toStringAsFixed(2)}',
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
                                          children: [
                                            const Padding(
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 12, horizontal: 16),
                                              child: Text(
                                                'Additional Discount',
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
                                                '₹${additionalDiscount.toStringAsFixed(2)}',
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
                                            color: AppColors.primary.withOpacity(0.05),
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
                                                'Final Total',
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
                                                '₹${(cubit.calculateOverallTotal() - itemDiscounts.fold<double>(0.0, (sum, disc) => sum + disc) - additionalDiscount).toStringAsFixed(2)}',
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
                                        final sumItemDisc =
                                        itemDiscounts.fold<double>(0.0, (sum, disc) => sum + disc);
                                        // Validate item discounts
                                        for (int i = 0; i < currentState.filteredProducts.length; i++) {
                                          final product = currentState.filteredProducts[i];
                                          final quantity =
                                              currentState.productQuantities[product.id] ?? 0;
                                          if (quantity == 0) continue;
                                          final itemTotal = cubit.calculateProductTotal(product.id);
                                          if (itemDiscounts[i] < 0) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'Item discount cannot be negative',
                                                  style: TextStyle(color: AppColors.white),
                                                ),
                                                backgroundColor: AppColors.red,
                                                behavior: SnackBarBehavior.floating,
                                                margin: EdgeInsets.all(16),
                                              ),
                                            );
                                            return;
                                          }
                                          if (itemDiscounts[i] > itemTotal) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  'Discount for ${product.name} cannot exceed item total',
                                                  style: const TextStyle(color: AppColors.white),
                                                ),
                                                backgroundColor: AppColors.red,
                                                behavior: SnackBarBehavior.floating,
                                                margin: const EdgeInsets.all(16),
                                              ),
                                            );
                                            return;
                                          }
                                        }
                                        // Validate additional discount
                                        if (additionalDiscount < 0) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Additional discount cannot be negative',
                                                style: TextStyle(color: AppColors.white),
                                              ),
                                              backgroundColor: AppColors.red,
                                              behavior: SnackBarBehavior.floating,
                                              margin: EdgeInsets.all(16),
                                            ),
                                          );
                                          return;
                                        }
                                        final totalAfterItemDisc =
                                            cubit.calculateOverallTotal() - sumItemDisc;
                                        if (additionalDiscount > totalAfterItemDisc) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Additional discount cannot exceed total after item discounts',
                                                style: TextStyle(color: AppColors.white),
                                              ),
                                              backgroundColor: AppColors.red,
                                              behavior: SnackBarBehavior.floating,
                                              margin: EdgeInsets.all(16),
                                            ),
                                          );
                                          return;
                                        }
                                        // Set total discount in cubit
                                        cubit.setDiscount(sumItemDisc + additionalDiscount);
                                        Navigator.pop(context);
                                        cubit.placeOrder();
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.primary,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        padding: const EdgeInsets.symmetric(vertical: 16),
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

  Future<void> _showQuantityInputDialog(
      BuildContext context, SalesmanOrderCubit cubit, String productId) async {
    int quantity = 0;
    final _formKey = GlobalKey<FormState>();
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: const Text('Set Quantity'),
          content: Form(
            key: _formKey,
            child: TextFormField(
              decoration: InputDecoration(
                labelText: 'Enter Quantity',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              keyboardType: TextInputType.number,
              maxLength: 7,
              onChanged: (value) => quantity = int.tryParse(value) ?? 0,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a quantity';
                }
                final parsedValue = int.tryParse(value);
                if (parsedValue == null || parsedValue < 0) {
                  return 'Please enter a valid quantity';
                }
                if (parsedValue > 9999999) {
                  return 'Quantity cannot exceed 7 digits';
                }
                return null;
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  cubit.setProductQuantity(productId, quantity);
                  Navigator.pop(dialogContext);
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showCustomerSelectionDialog(
      BuildContext context, UserServices userServices, SalesmanOrderCubit cubit) async {
    final TextEditingController customerNameController = TextEditingController();
    final TextEditingController searchController = TextEditingController();
    bool isLoading = false;
    List<UserInfo> filteredCustomers = [];

    try {
      final users = await userServices.getUsersFromTenantCompany();
      final customerUsers = users.where((u) => u.userType == UserType.Customer).toList();
      filteredCustomers = customerUsers;
      if (!context.mounted) return;
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        builder: (dialogContext) => StatefulBuilder(
          builder: (dialogContext, setState) => DraggableScrollableSheet(
            initialChildSize: 0.9,
            minChildSize: 0.5,
            maxChildSize: 0.9,
            expand: false,
            builder: (dialogContext, scrollController) => Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Select or Add Customer',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: AppColors.primary),
                        onPressed: () => Navigator.of(dialogContext).pop(),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: 'Search Customers',
                      hintStyle: const TextStyle(color: AppColors.textSecondary),
                      prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
                      filled: true,
                      fillColor: AppColors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.textSecondary.withOpacity(0.3)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.textSecondary.withOpacity(0.3)),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    onChanged: (value) {
                      setState(() {
                        if (value.isEmpty) {
                          filteredCustomers = customerUsers;
                        } else {
                          filteredCustomers = customerUsers
                              .where((customer) =>
                          customer.name?.toLowerCase().contains(value.toLowerCase()) ?? false)
                              .toList();
                        }
                      });
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: TextField(
                    controller: customerNameController,
                    decoration: InputDecoration(
                      labelText: 'New Customer Name',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                      errorText: customerNameController.text.isEmpty &&
                          filteredCustomers.isEmpty
                          ? 'Name is required'
                          : null,
                    ),
                    onChanged: (value) {
                      setState(() {});
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : () async {
                      if (customerNameController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Customer name is required')),
                        );
                        return;
                      }
                      setState(() => isLoading = true);
                      try {
                        final companyId =
                            (await sl<AccountRepository>().getUserInfo())
                                ?.companyId;
                        final userInfo = UserInfo(
                          name: customerNameController.text.trim(),
                          userType: UserType.Customer,
                          companyId: companyId,
                        );
                        await userServices.addUserToCompany(userInfo, '');
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Customer added successfully')),
                        );
                        cubit.refreshCustomers();
                        if (context.mounted) Navigator.of(context).pop();
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Failed to add customer: $e')),
                          );
                        }
                      } finally {
                        setState(() => isLoading = false);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                    ),
                    child: isLoading
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: AppColors.white,
                        strokeWidth: 2,
                      ),
                    )
                        : const Text(
                      'Add New Customer',
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: filteredCustomers.isEmpty
                      ? const Center(child: Text('No customers found'))
                      : ListView.builder(
                    controller: scrollController,
                    itemCount: filteredCustomers.length,
                    itemBuilder: (dialogContext, index) {
                      final user = filteredCustomers[index];
                      return ListTile(
                        title: Text(
                          user.name ?? 'Unknown',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text('ID: ${user.userId}'),
                        onTap: () {
                          print('Selecting customer: ${user.name} (ID: ${user.userId})');
                          cubit.selectCustomer(user);
                          Navigator.of(dialogContext).pop();
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to fetch customers: $e')),
        );
      }
    }
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
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
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
            borderSide: BorderSide(color: AppColors.textSecondary.withOpacity(0.3)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.textSecondary.withOpacity(0.3)),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        onChanged: onSearchChanged,
      ),
    );
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) => true;
}