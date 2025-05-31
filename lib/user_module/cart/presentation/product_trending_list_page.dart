import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:requirment_gathering_app/company_admin_module/data/inventory/stock_model.dart';
import 'package:requirment_gathering_app/company_admin_module/presentation/inventory/stock_cubit.dart';
import 'package:requirment_gathering_app/company_admin_module/service/stock_service.dart';
import 'package:requirment_gathering_app/company_admin_module/service/user_services.dart';
import 'package:requirment_gathering_app/company_admin_module/service/transaction_service.dart';
import 'package:requirment_gathering_app/core_module/coordinator/coordinator.dart';
import 'package:requirment_gathering_app/core_module/presentation/widget/custom_appbar.dart';
import 'package:requirment_gathering_app/core_module/repository/account_repository.dart';
import 'package:requirment_gathering_app/core_module/service_locator/service_locator.dart';
import 'package:requirment_gathering_app/core_module/utils/AppColor.dart';
import 'package:requirment_gathering_app/user_module/cart/data/order_model.dart';
import 'package:requirment_gathering_app/user_module/cart/presentation/admin_order_cubit.dart';

// Model for aggregated product sales data
class ProductSalesData {
  final String productId;
  final String productName;
  final double totalAmount;
  final int totalQuantity;
  final int orderCount;

  ProductSalesData({
    required this.productId,
    required this.productName,
    required this.totalAmount,
    required this.totalQuantity,
    required this.orderCount,
  });
}

@RoutePage()
class ProductTrendingListPage extends StatefulWidget {
  const ProductTrendingListPage({super.key});

  @override
  State<ProductTrendingListPage> createState() => _ProductTrendingListPageState();
}

class _ProductTrendingListPageState extends State<ProductTrendingListPage> {
  DateTimeRange _dateRange = DateTimeRange(
    start: DateTime.now().subtract(const Duration(days: 7)),
    end: DateTime.now(),
  );
  String? _selectedFilter = 'week'; // Default: Week filter

  Future<void> _initializeData(BuildContext context) async {
    final userInfo = await sl<AccountRepository>().getUserInfo();
    if (!mounted) return;
    context.read<StockCubit>().fetchStock('');
    context.read<AdminOrderCubit>().fetchOrders(
      startDate: _dateRange.start,
      endDate: _dateRange.end,
    );
  }

  Future<void> _pickDateRange(BuildContext context) async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _dateRange,
      builder: (context, child) => Theme(
        data: ThemeData.light().copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null && mounted) {
      setState(() {
        _dateRange = picked;
        _selectedFilter = null; // Deselect chips for custom range
      });
      context.read<AdminOrderCubit>().fetchOrders(
        startDate: picked.start,
        endDate: picked.end,
      );
    }
  }

  void _applyQuickFilter(String filter) {
    setState(() {
      _selectedFilter = filter;
      final now = DateTime.now();
      switch (filter) {
        case 'year':
          _dateRange = DateTimeRange(
            start: now.subtract(const Duration(days: 365)),
            end: now,
          );
          break;
        case 'week':
          _dateRange = DateTimeRange(
            start: now.subtract(const Duration(days: 7)),
            end: now,
          );
          break;
        case 'month':
          _dateRange = DateTimeRange(
            start: now.subtract(const Duration(days: 30)),
            end: now,
          );
          break;
      }
    });
    context.read<AdminOrderCubit>().fetchOrders(
      startDate: _dateRange.start,
      endDate: _dateRange.end,
    );
  }

  Widget _buildDateRangeCard() {
    final formatter = DateFormat('dd-MM-yyyy');
    final totalDays = _dateRange.end.difference(_dateRange.start).inDays + 1;
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          title: Text(
            'Date Range: ${formatter.format(_dateRange.start)} - ${formatter.format(_dateRange.end)}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(
              'Total $totalDays days',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          trailing: const Icon(Icons.calendar_today, color: AppColors.primary),
          onTap: () => _pickDateRange(context),
        ),
      ),
    );
  }

  Widget _buildQuickFilterChips() {
    final filters = [
      {'label': 'Last 1 Year', 'value': 'year'},
      {'label': 'Week', 'value': 'week'},
      {'label': 'Month', 'value': 'month'},
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.textSecondary.withOpacity(0.5)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            alignment: WrapAlignment.start,
            children: filters.map((filter) {
              final isSelected = _selectedFilter == filter['value'];
              return ChoiceChip(
                label: Text(
                  filter['label'] as String,
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppColors.textPrimary,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                selected: isSelected,
                selectedColor: AppColors.primary,
                backgroundColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.textSecondary.withOpacity(0.5),
                  ),
                ),
                onSelected: (selected) {
                  if (selected) {
                    _applyQuickFilter(filter['value'] as String);
                  }
                },
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  List<ProductSalesData> _aggregateProductSales(
      List<Order> orders, List<StockModel> stockItems) {
    final productMap = <String, ProductSalesData>{};

    for (final order in orders) {
      for (final cartItem in order.items) {
        final productId = cartItem.productId;
        final currentData = productMap[productId] ??
            ProductSalesData(
              productId: productId,
              productName: cartItem.productName ?? 'Unknown Product',
              totalAmount: 0.0,
              totalQuantity: 0,
              orderCount: 0,
            );

        productMap[productId] = ProductSalesData(
          productId: productId,
          productName: currentData.productName,
          totalAmount: currentData.totalAmount + (cartItem.price * cartItem.quantity) + cartItem.taxAmount,
          totalQuantity: currentData.totalQuantity + cartItem.quantity,
          orderCount: currentData.orderCount + 1,
        );
      }
    }
    // Update product names from stock
    for (final product in stockItems) {
      if (productMap.containsKey(product.productId)) {
        productMap[product.productId] = ProductSalesData(
          productId: product.productId,
          productName: product.name ?? productMap[product.productId]!.productName,
          totalAmount: productMap[product.productId]!.totalAmount,
          totalQuantity: productMap[product.productId]!.totalQuantity,
          orderCount: productMap[product.productId]!.orderCount,
        );
      }
    }

    final productSalesList = productMap.values.toList()
      ..sort((a, b) => b.totalAmount.compareTo(a.totalAmount));
    return productSalesList;
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<StockCubit>(
          create: (context) => StockCubit(
            stockService: sl<StockService>(),
            employeeServices: sl<UserServices>(),
            transactionService: sl<TransactionService>(),
            accountRepository: sl<AccountRepository>(),
          ),
        ),
        BlocProvider<AdminOrderCubit>(
          create: (context) => sl<AdminOrderCubit>(),
        ),
      ],
      child: Builder(
        builder: (context) {
          _initializeData(context);
          return Scaffold(
            appBar: const CustomAppBar(title: 'Product Trending'),
            body: Column(
              children: [
                _buildDateRangeCard(),
                _buildQuickFilterChips(),
                Expanded(
                  child: BlocBuilder<StockCubit, StockState>(
                    buildWhen: (previous, current) =>
                    current is StockLoading || current is StockLoaded || current is StockError,
                    builder: (context, stockState) {
                      return BlocBuilder<AdminOrderCubit, AdminOrderState>(
                        buildWhen: (previous, current) =>
                        current is AdminOrderListFetchSuccess ||
                            current is AdminOrderListFetchError ||
                            current is AdminOrderListFetchLoading,
                        builder: (context, orderState) {
                          if (stockState is StockLoading || orderState is AdminOrderListFetchLoading) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          if (stockState is StockError) {
                            return Center(child: Text('Stock Error: ${stockState.error}'));
                          }
                          if (orderState is AdminOrderListFetchError) {
                            return Center(child: Text('Order Error: ${orderState.message}'));
                          }
                          if (stockState is StockLoaded && orderState is AdminOrderListFetchSuccess) {
                            final productSalesList = _aggregateProductSales(
                              orderState.orders,
                              stockState.stockItems,
                            );
                            if (productSalesList.isEmpty) {
                              return const Center(child: Text('No sales data for this period'));
                            }
                            return ListView.builder(
                              padding: const EdgeInsets.all(16.0),
                              itemCount: productSalesList.length,
                              itemBuilder: (context, index) {
                                final salesData = productSalesList[index];
                                return Card(
                                  child: ListTile(
                                    title: Text(salesData.productName),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Total Amount: ₹${salesData.totalAmount.toStringAsFixed(2)}'),
                                        Text('Quantity Sold: ${salesData.totalQuantity}'),
                                        Text('Order Count: ${salesData.orderCount}'),
                                      ],
                                    ),
                                    onTap: () {
                                      sl<Coordinator>().navigateToPerformanceDetailsPage(
                                        entityType: 'product',
                                        entityId: salesData.productId,
                                      );
                                    },
                                  ),
                                );
                              },
                            );
                          }
                          return const Center(child: CircularProgressIndicator());
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}