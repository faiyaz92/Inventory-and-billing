import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:requirment_gathering_app/core_module/coordinator/coordinator.dart';
import 'package:requirment_gathering_app/core_module/presentation/widget/custom_appbar.dart';
import 'package:requirment_gathering_app/core_module/service_locator/service_locator.dart';
import 'package:requirment_gathering_app/core_module/utils/AppColor.dart';
import 'package:requirment_gathering_app/core_module/utils/custom_loading_dialog.dart';
import 'package:requirment_gathering_app/super_admin_module/data/user_info.dart';
import 'package:requirment_gathering_app/super_admin_module/utils/user_type.dart';
import 'package:requirment_gathering_app/user_module/cart/data/order_model.dart';
import 'package:requirment_gathering_app/user_module/cart/presentation/admin_order_cubit.dart';
import 'package:shimmer/shimmer.dart';

@RoutePage()
class SalesmanOrderListPage extends StatefulWidget {
  const SalesmanOrderListPage({super.key});

  @override
  State<SalesmanOrderListPage> createState() => _SalesmanOrderListPageState();
}

class _SalesmanOrderListPageState extends State<SalesmanOrderListPage> {
  DateTimeRange _dateRange = DateTimeRange(
    start: DateTime.now().subtract(const Duration(days: 7)),
    end: DateTime.now(),
  );
  String? _selectedFilter = 'week';
  late final AdminOrderCubit _adminOrderCubit;

  @override
  void initState() {
    super.initState();
    _adminOrderCubit = sl<AdminOrderCubit>()
      ..fetchOrders(
        startDate: _dateRange.start,
        endDate: _dateRange.end,
      );
  }

  Widget _buildQuickFilterChips() {
    final filters = [
      {'label': 'Last 1 Year', 'value': 'year'},
      {'label': 'Week', 'value': 'week'},
      {'label': 'Month', 'value': 'month'},
      {'label': 'Last 3 Months', 'value': '3months'},
      {'label': 'Last 6 Months', 'value': '6months'},
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.textSecondary.withOpacity(0.5)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Quick Filter',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                alignment: WrapAlignment.start,
                children: filters.map((filter) {
                  final isSelected = _selectedFilter == filter['value'];
                  return ChoiceChip(
                    label: Text(
                      filter['label'] as String,
                      style: TextStyle(
                        color:
                            isSelected ? Colors.white : AppColors.textPrimary,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
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
            ],
          ),
        ),
      ),
    );
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
        case '3months':
          _dateRange = DateTimeRange(
            start: now.subtract(const Duration(days: 90)),
            end: now,
          );
          break;
        case '6months':
          _dateRange = DateTimeRange(
            start: now.subtract(const Duration(days: 180)),
            end: now,
          );
          break;
      }
    });
    _adminOrderCubit.fetchOrders(
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
        _selectedFilter = null;
      });
      _adminOrderCubit.fetchOrders(
        startDate: picked.start,
        endDate: picked.end,
      );
    }
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
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          leading: const Icon(Icons.calendar_today,
              color: AppColors.primary, size: 36),
          title: Text(
            'Date Range: ${formatter.format(_dateRange.start)} - ${formatter.format(_dateRange.end)}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              'Total $totalDays days',
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          onTap: () => _pickDateRange(context),
        ),
      ),
    );
  }

  Map<UserInfo, List<Order>> _groupOrdersBySalesman(
      List<Order> orders, List<UserInfo> users) {
    final Map<UserInfo, List<Order>> grouped = {};
    for (var order in orders) {
      if (order.orderTakenBy != null) {
        final salesman = users.firstWhere(
          (user) => user.userId == order.orderTakenBy,
          orElse: () => UserInfo(
              userId: order.orderTakenBy,
              userName: 'Unknown',
              userType: UserType.Customer),
        );
        grouped.putIfAbsent(salesman, () => []).add(order);
      }
    }
    return grouped;
  }

  Widget _buildSalesmanCard(UserInfo salesman, List<Order> orders) {
    final totalAmount =
        orders.fold(0.0, (sum, order) => sum + order.totalAmount);
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      child: InkWell(
        onTap: () {
          sl<Coordinator>().navigateToPerformanceDetailsPage(
            entityType: 'salesman',
            entityId: salesman.userId!,
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.person, color: AppColors.primary, size: 36),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          salesman.name ?? 'Unknown',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          'Salesman ID: ${salesman.userId}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
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
                      _buildTableRow('Orders', '${orders.length}'),
                      _buildTableRow(
                        'Total',
                        '₹${totalAmount.toStringAsFixed(2)}',
                        isBold: true,
                        valueColor: AppColors.textPrimary,
                        backgroundColor: AppColors.primary.withOpacity(0.1),
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(12),
                          bottomRight: Radius.circular(12),
                        ),
                      ),
                    ],
                  ),
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
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: valueColor,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  Widget _buildShimmerEffect() {
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 16.0),
      itemCount: 3, // Show 3 shimmer cards as placeholders
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Card(
            elevation: 4,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 150,
                              height: 18,
                              color: Colors.white,
                            ),
                            const SizedBox(height: 4),
                            Container(
                              width: 100,
                              height: 14,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
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
                                child: Container(
                                  width: 80,
                                  height: 14,
                                  color: Colors.white,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 4.0, horizontal: 8.0),
                                child: Container(
                                  width: 50,
                                  height: 14,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          TableRow(
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(12),
                                bottomRight: Radius.circular(12),
                              ),
                            ),
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 4.0, horizontal: 8.0),
                                child: Container(
                                  width: 80,
                                  height: 14,
                                  color: Colors.white,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 4.0, horizontal: 8.0),
                                child: Container(
                                  width: 50,
                                  height: 14,
                                  color: Colors.white,
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
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => _adminOrderCubit,
      child: Scaffold(
        appBar: const CustomAppBar(title: 'Top salesmen'),
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
          child: Column(
            children: [
              _buildDateRangeCard(),
              _buildQuickFilterChips(),
              Expanded(
                child: BlocBuilder<AdminOrderCubit, AdminOrderState>(
                  builder: (context, state) {
                    if (state is AdminOrderListFetchLoading) {
                      return const CustomLoadingDialog();
                    } else if (state is AdminOrderListFetchSuccess) {
                      final salesmanOrders =
                          _groupOrdersBySalesman(state.orders, state.users);
                      if (salesmanOrders.isEmpty) {
                        return const Center(
                            child: Text('No salesmen found for this period'));
                      }
                      return ListView.builder(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        itemCount: salesmanOrders.length,
                        itemBuilder: (context, index) {
                          final salesman = salesmanOrders.keys.elementAt(index);
                          final orders = salesmanOrders[salesman]!;
                          return _buildSalesmanCard(salesman, orders);
                        },
                      );
                    }
                    return const Center(child: Text('Error loading data'));
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
