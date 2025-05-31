import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:requirment_gathering_app/core_module/coordinator/coordinator.dart';
import 'package:requirment_gathering_app/core_module/presentation/widget/custom_appbar.dart';
import 'package:requirment_gathering_app/core_module/service_locator/service_locator.dart';
import 'package:requirment_gathering_app/core_module/utils/AppColor.dart';
import 'package:requirment_gathering_app/super_admin_module/data/user_info.dart';
import 'package:requirment_gathering_app/user_module/cart/data/order_model.dart';
import 'package:requirment_gathering_app/user_module/cart/presentation/admin_order_cubit.dart';

@RoutePage()
class CustomerOrderListPage extends StatefulWidget {
  const CustomerOrderListPage({super.key});

  @override
  State<CustomerOrderListPage> createState() => _CustomerOrderListPageState();
}

class _CustomerOrderListPageState extends State<CustomerOrderListPage> {
  DateTimeRange _dateRange = DateTimeRange(
    start: DateTime.now().subtract(const Duration(days: 7)),
    end: DateTime.now(),
  );
  String? _selectedFilter = 'week'; // Default: Top Customers of Week
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
      _adminOrderCubit.fetchOrders(
        startDate: picked.start,
        endDate: picked.end,
      );
    }
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
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              const Text('Quick filter'),
              const SizedBox(height: 16),
              Container(
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
              const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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


  List<MapEntry<UserInfo, List<Order>>> _groupOrdersByCustomer(
      List<Order> orders, List<UserInfo> users) {
    final Map<UserInfo, List<Order>> grouped = {};
    for (var order in orders) {
      if (order.userId != null) {
        final customer = users.firstWhere(
          (user) => user.userId == order.userId,
          orElse: () => UserInfo(userId: order.userId, userName: 'Unknown'),
        );
        grouped.putIfAbsent(customer, () => []).add(order);
      }
    }
// Sort by totalAmount (high to low)
    final sortedEntries = grouped.entries.toList()
      ..sort((a, b) {
        final totalA =
            a.value.fold<double>(0.0, (sum, order) => sum + order.totalAmount);
        final totalB =
            b.value.fold<double>(0.0, (sum, order) => sum + order.totalAmount);
        return totalB.compareTo(totalA);
      });
    return sortedEntries;
  }

  String _daysSinceLastOrder(Order order) {
    final diff = DateTime.now().difference(order.orderDate);
    return '${diff.inDays} days ago';
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => _adminOrderCubit,
      child: Scaffold(
        appBar: const CustomAppBar(title: 'Customer Orders'),
        body: Column(
          children: [
            _buildDateRangeCard(),
            _buildQuickFilterChips(),
            Expanded(
              child: BlocBuilder<AdminOrderCubit, AdminOrderState>(
                builder: (context, state) {
                  if (state is AdminOrderListFetchLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is AdminOrderListFetchSuccess) {
                    final customerOrders =
                        _groupOrdersByCustomer(state.orders, state.users);
                    if (customerOrders.isEmpty) {
                      return const Center(
                          child: Text('No customers found for this period'));
                    }
                    return ListView.builder(
                      itemCount: customerOrders.length,
                      itemBuilder: (context, index) {
                        final entry = customerOrders[index];
                        final customer = entry.key;
                        final orders = entry.value;
                        final lastOrder = orders.first; // Latest order
                        final daysSinceLastOrder =
                            _daysSinceLastOrder(lastOrder);
                        final totalAmount = orders.fold<double>(
                            0.0, (sum, order) => sum + order.totalAmount);
                        return ListTile(
                          title: Text(customer.userName ?? 'Unknown'),
                          subtitle: Text(
                            'Orders: ${orders.length} | Total: ₹${totalAmount.toStringAsFixed(2)} | Last Order: $daysSinceLastOrder',
                          ),
                          onTap: () {
                            sl<Coordinator>().navigateToPerformanceDetailsPage(
                              entityType: 'customer',
                              entityId: customer.userId!,
                            );
                          },
                        );
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
    );
  }
}
