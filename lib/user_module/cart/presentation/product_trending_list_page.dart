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
    start: DateTime.now().subtract(const Duration(days: 30)),
    end: DateTime.now(),
  );

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
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(primary: AppColors.primary),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _dateRange && mounted) {
      setState(() {
        _dateRange = picked;
      });
      context.read<AdminOrderCubit>().fetchOrders(
        startDate: _dateRange.start,
        endDate: _dateRange.end,
      );
    }
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
          totalAmount:
          currentData.totalAmount + (cartItem.price * cartItem.quantity),
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
            body: Column(
              children: [
                // Date range filter
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Card(
                    child: ListTile(
                      title: Text(
                        'Date Range: ${DateFormat('MMM d, yyyy').format(_dateRange.start)} - '
                            '${DateFormat('MMM d, yyyy').format(_dateRange.end)}',
                      ),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () => _pickDateRange(context),
                    ),
                  ),
                ),
                Expanded(
                  child: BlocBuilder<StockCubit, StockState>(
                    buildWhen: (previous, current) =>
                    current is StockLoading ||
                        current is StockLoaded ||
                        current is StockError,
                    builder: (context, stockState) {
                      return BlocBuilder<AdminOrderCubit, AdminOrderState>(
                        buildWhen: (previous, current) =>
                        current is AdminOrderListFetchSuccess ||
                            current is AdminOrderListFetchError ||
                            current is AdminOrderListFetchLoading,
                        builder: (context, orderState) {
                          if (stockState is StockLoading ||
                              orderState is AdminOrderListFetchLoading) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }
                          if (stockState is StockError) {
                            return Center(
                                child:
                                Text('Stock Error: ${stockState.error}'));
                          }
                          if (orderState is AdminOrderListFetchError) {
                            return Center(
                                child:
                                Text('Order Error: ${orderState.message}'));
                          }
                          if (stockState is StockLoaded &&
                              orderState is AdminOrderListFetchSuccess) {
                            final productSalesList = _aggregateProductSales(
                              orderState.orders,
                              stockState.stockItems,
                            );
                            if (productSalesList.isEmpty) {
                              return const Center(
                                  child: Text('No sales data for this period'));
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
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                            'Total Amount: ₹${salesData.totalAmount.toStringAsFixed(2)}'),
                                        Text(
                                            'Quantity Sold: ${salesData.totalQuantity}'),
                                        Text(
                                            'Order Count: ${salesData.orderCount}'),
                                      ],
                                    ),
                                    onTap: () {
                                      sl<Coordinator>()
                                          .navigateToPerformanceDetailsPage(
                                        entityType: 'product',
                                        entityId: salesData.productId,
                                      );
                                    },
                                  ),
                                );
                              },
                            );
                          }
                          return const Center(
                              child: CircularProgressIndicator());
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