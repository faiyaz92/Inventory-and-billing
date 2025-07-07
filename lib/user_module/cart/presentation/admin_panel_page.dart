import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:requirment_gathering_app/company_admin_module/repositories/stock_repository.dart';
import 'package:requirment_gathering_app/core_module/coordinator/coordinator.dart';
import 'package:requirment_gathering_app/core_module/presentation/widget/custom_appbar.dart';
import 'package:requirment_gathering_app/core_module/service_locator/service_locator.dart';
import 'package:requirment_gathering_app/core_module/utils/AppColor.dart';
import 'package:requirment_gathering_app/core_module/utils/AppLabels.dart';
import 'package:requirment_gathering_app/core_module/utils/custom_loading_dialog.dart';
import 'package:requirment_gathering_app/core_module/utils/text_styles.dart';
import 'package:requirment_gathering_app/super_admin_module/data/user_info.dart';
import 'package:requirment_gathering_app/super_admin_module/utils/user_type.dart';
import 'package:requirment_gathering_app/user_module/cart/data/order_model.dart';
import 'package:requirment_gathering_app/user_module/cart/presentation/admin_order_cubit.dart';
import 'package:sticky_headers/sticky_headers.dart';

@RoutePage()
class AdminPanelPage extends StatefulWidget {
  const AdminPanelPage({super.key});

  @override
  State<AdminPanelPage> createState() => _AdminPanelPageState();
}

class _AdminPanelPageState extends State<AdminPanelPage> {
  String _selectedFilter = '3months';
  late final AdminOrderCubit _adminOrderCubit;
  late DateTime startDate;
  late DateTime endDate;

  @override
  void initState() {
    _adminOrderCubit = sl<AdminOrderCubit>() /*..fetchOrders()*/;
    _applyQuickFilter(_selectedFilter);
    super.initState();
  }

  void _applyQuickFilter(String filter) {
    _selectedFilter = filter;
    final now = DateTime.now();
    switch (filter) {
      case 'today':
        startDate = DateTime(now.year, now.month, now.day);
        endDate = startDate;
        break;
      case 'yesterday':
        startDate = now.subtract(const Duration(days: 1));
        startDate = DateTime(startDate.year, startDate.month, startDate.day);
        endDate = startDate;
        break;
      case 'daybefore':
        startDate = now.subtract(const Duration(days: 2));
        startDate = DateTime(startDate.year, startDate.month, startDate.day);
        endDate = startDate;
        break;

      case 'year':
        startDate = now.subtract(const Duration(days: 365));
        endDate = now;
        break;
      case 'week':
        startDate = now.subtract(const Duration(days: 7));
        endDate = now;
        break;
      case 'month':
        startDate = now.subtract(const Duration(days: 30));
        endDate = now;
        break;
      case '3months':
        startDate = now.subtract(const Duration(days: 90));
        endDate = now;
        break;
      case '6months':
        startDate = now.subtract(const Duration(days: 180));
        endDate = now;
        break;
      default:
        startDate =
            now.subtract(const Duration(days: 90)); // Fallback to 3 months
        endDate = now;
        break;
    }

    _adminOrderCubit.fetchOrders(
      startDate: startDate,
      endDate: endDate,
    );
    final state = _adminOrderCubit.state;
    if (state is AdminOrderListFetchSuccess) {
      _adminOrderCubit.fetchOrders(
        startDate: startDate,
        endDate: endDate,
        status: state.status,
        expectedDeliveryStartDate: state.expectedDeliveryStartDate,
        expectedDeliveryEndDate: state.expectedDeliveryEndDate,
        orderTakenBy: state.orderTakenBy,
        orderDeliveredBy: state.orderDeliveredBy,
        storeId: state.storeId,
        userId: state.userId,
        minTotalAmount: state.minTotalAmount,
        maxTotalAmount: state.maxTotalAmount,
      );
    } else {
      _adminOrderCubit.fetchOrders(
        startDate: startDate,
        endDate: endDate,
      );
    }
  }

  Widget _buildQuickFilterChips() {
    final filters = [
      {'label': 'Today', 'value': 'today'},
      {'label': 'Yesterday', 'value': 'yesterday'},
      {'label': 'Day Before', 'value': 'daybefore'},
      {'label': 'Week', 'value': 'week'},
      {'label': 'Month', 'value': 'month'},
      {'label': 'Last 3 Months', 'value': '3months'},
      {'label': 'Last 6 Months', 'value': '6months'},
      {'label': 'Last 1 Year', 'value': 'year'},
    ];
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.textSecondary.withOpacity(0.5)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Qucik filter',
              style:
                  defaultTextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              height: 12,
            ),
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
                      color: isSelected ? Colors.white : AppColors.textPrimary,
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => _adminOrderCubit,
      child: Scaffold(
        appBar: const CustomAppBar(title: AppLabels.adminPanelTitle),
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
            child: BlocBuilder<AdminOrderCubit, AdminOrderState>(
                builder: (context, state) {
              if (state is AdminOrderListFetchLoading) {
                return const CustomLoadingDialog(message: 'Loading...');
              } else if (state is AdminOrderListFetchSuccess) {
                return CustomScrollView(
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.all(16.0),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          _buildFilters(context),
                          const SizedBox(height: 16),
                          _buildStatsCard(context),
                          const SizedBox(height: 16),
                          _buildExpectedDeliveryLabel(),
                          const SizedBox(height: 8),
                        ]),
                      ),
                    ),
                    _buildOrderList(),
                  ],
                );
              } else if (state is AdminOrderListFetchError) {
                return Center(child: Text('Error: ${state.message}'));
              }
              return const SizedBox.shrink();
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildFilters(BuildContext context) {
    return BlocBuilder<AdminOrderCubit, AdminOrderState>(
      buildWhen: (previous, current) =>
      current is AdminOrderListFetchLoading ||
          current is AdminOrderListFetchSuccess ||
          current is AdminOrderListFetchError,
      builder: (context, state) {
        if (state is AdminOrderListFetchLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is AdminOrderListFetchError) {
          return Center(child: Text('Error: ${state.message}'));
        }
        if (state is AdminOrderListFetchSuccess) {
          DateTime? orderStartDate = state.startDate;
          DateTime? orderEndDate = state.endDate;
          DateTime? expectedStartDate = state.expectedDeliveryStartDate;
          DateTime? expectedEndDate = state.expectedDeliveryEndDate;
          String? selectedStatus = state.status;
          String? selectedOrderTakenBy = state.orderTakenBy;
          String? selectedOrderDeliveredBy = state.orderDeliveredBy;
          String? selectedStoreId = state.storeId;
          String? selectedUserId = state.userId;
          double? minTotalAmount = state.minTotalAmount;
          double? maxTotalAmount = state.maxTotalAmount;
          List<UserInfo> users = state.users;
          List<StoreDto> stores = state.stores;

          // Filter employees for Taken By and Delivered By
          final employeeUsers = users
              .where((user) => user.userType == UserType.Employee)
              .toList();
          // Filter customers for Customer filter
          final customerUsers = users
              .where((user) => user.userType == UserType.Customer)
              .toList();

          // Validate selected values
          final validOrderTakenBy = selectedOrderTakenBy != null &&
              employeeUsers.any((user) => user.userId == selectedOrderTakenBy)
              ? selectedOrderTakenBy
              : null;
          final validOrderDeliveredBy = selectedOrderDeliveredBy != null &&
              employeeUsers.any((user) => user.userId == selectedOrderDeliveredBy)
              ? selectedOrderDeliveredBy
              : null;
          final validUserId = selectedUserId != null &&
              customerUsers.any((user) => user.userId == selectedUserId)
              ? selectedUserId
              : null;

          // Dropdown items for employees
          final employeeDropdownItems = [
            const DropdownMenuItem<String>(value: null, child: Text('Select')),
            ...employeeUsers
                .where((user) => user.userId != null && user.userId!.isNotEmpty)
                .map((user) => DropdownMenuItem<String>(
              value: user.userId,
              child: Text(user.name ?? 'Unknown'),
            )),
          ];

          // Dropdown items for customers
          final customerDropdownItems = [
            const DropdownMenuItem<String>(value: null, child: Text('Select')),
            ...customerUsers
                .where((user) => user.userId != null && user.userId!.isNotEmpty)
                .map((user) => DropdownMenuItem<String>(
              value: user.userId,
              child: Text(user.name ?? 'Unknown'),
            )),
          ];

          return Column(
            children: [
              // Date Range Filters
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        final dateRange = await showDateRangePicker(
                          context: context,
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                          initialDateRange: DateTimeRange(
                            start: startDate,
                            end: endDate,
                          ),
                        );
                        if (dateRange != null) {
                          _adminOrderCubit.fetchOrders(
                            startDate: dateRange.start,
                            endDate: dateRange.end,
                            status: selectedStatus,
                            expectedDeliveryStartDate: expectedStartDate,
                            expectedDeliveryEndDate: expectedEndDate,
                            orderTakenBy: validOrderTakenBy,
                            orderDeliveredBy: validOrderDeliveredBy,
                            storeId: selectedStoreId,
                            userId: validUserId,
                            minTotalAmount: minTotalAmount,
                            maxTotalAmount: maxTotalAmount,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text(
                        'Date Range: Order',
                        style: TextStyle(color: AppColors.white, fontSize: 14),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        final dateRange = await showDateRangePicker(
                          context: context,
                          firstDate: DateTime(2020),
                          lastDate:
                          DateTime.now().add(const Duration(days: 365)),
                          initialDateRange: DateTimeRange(
                            start: DateTime.now(),
                            end: DateTime.now().add(const Duration(days: 30)),
                          ),
                        );
                        if (dateRange != null) {
                          _adminOrderCubit.fetchOrders(
                            startDate: orderStartDate,
                            endDate: orderEndDate,
                            status: selectedStatus,
                            expectedDeliveryStartDate: dateRange.start,
                            expectedDeliveryEndDate: dateRange.end,
                            orderTakenBy: validOrderTakenBy,
                            orderDeliveredBy: validOrderDeliveredBy,
                            storeId: selectedStoreId,
                            userId: validUserId,
                            minTotalAmount: minTotalAmount,
                            maxTotalAmount: maxTotalAmount,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text(
                        'Date: Expected Delivery',
                        style: TextStyle(color: AppColors.white, fontSize: 14),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              _buildQuickFilterChips(),
              const SizedBox(height: 12),
              // Status and Clear Filters
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Filter by Status',
                        labelStyle:
                        const TextStyle(color: AppColors.textSecondary),
                        filled: true,
                        fillColor: AppColors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                              color: AppColors.textSecondary.withOpacity(0.3)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                              color: AppColors.textSecondary.withOpacity(0.3)),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                      ),
                      value: selectedStatus,
                      hint: const Text(
                        'All Statuses',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                      items: const [
                        DropdownMenuItem(
                            value: null, child: Text('All Statuses')),
                        DropdownMenuItem(
                            value: 'pending', child: Text('Pending')),
                        DropdownMenuItem(
                            value: 'processing', child: Text('Processing')),
                        DropdownMenuItem(
                            value: 'shipped', child: Text('Shipped')),
                        DropdownMenuItem(
                            value: 'completed', child: Text('Completed')),
                      ],
                      onChanged: (value) {
                        _adminOrderCubit.fetchOrders(
                          startDate: orderStartDate,
                          endDate: orderEndDate,
                          status: value,
                          expectedDeliveryStartDate: expectedStartDate,
                          expectedDeliveryEndDate: expectedEndDate,
                          orderTakenBy: validOrderTakenBy,
                          orderDeliveredBy: validOrderDeliveredBy,
                          storeId: selectedStoreId,
                          userId: validUserId,
                          minTotalAmount: minTotalAmount,
                          maxTotalAmount: maxTotalAmount,
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => _adminOrderCubit.fetchOrders(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      'Clear',
                      style: TextStyle(color: AppColors.white, fontSize: 14),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // User-based Filters
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Taken By',
                        labelStyle:
                        const TextStyle(color: AppColors.textSecondary),
                        filled: true,
                        fillColor: AppColors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                              color: AppColors.textSecondary.withOpacity(0.3)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                              color: AppColors.textSecondary.withOpacity(0.3)),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 12),
                      ),
                      value: validOrderTakenBy,
                      hint: const Text(
                        'All Salesmen',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                      items: employeeDropdownItems,
                      onChanged: (value) {
                        _adminOrderCubit.fetchOrders(
                          startDate: orderStartDate,
                          endDate: orderEndDate,
                          status: selectedStatus,
                          expectedDeliveryStartDate: expectedStartDate,
                          expectedDeliveryEndDate: expectedEndDate,
                          orderTakenBy: value,
                          orderDeliveredBy: validOrderDeliveredBy,
                          storeId: selectedStoreId,
                          userId: validUserId,
                          minTotalAmount: minTotalAmount,
                          maxTotalAmount: maxTotalAmount,
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Delivered By',
                        labelStyle:
                        const TextStyle(color: AppColors.textSecondary),
                        filled: true,
                        fillColor: AppColors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                              color: AppColors.textSecondary.withOpacity(0.3)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                              color: AppColors.textSecondary.withOpacity(0.3)),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 12),
                      ),
                      value: validOrderDeliveredBy,
                      hint: const Text(
                        'All Delivery Persons',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                      items: employeeDropdownItems,
                      onChanged: (value) {
                        _adminOrderCubit.fetchOrders(
                          startDate: orderStartDate,
                          endDate: orderEndDate,
                          status: selectedStatus,
                          expectedDeliveryStartDate: expectedStartDate,
                          expectedDeliveryEndDate: expectedEndDate,
                          orderTakenBy: validOrderTakenBy,
                          orderDeliveredBy: value,
                          storeId: selectedStoreId,
                          userId: validUserId,
                          minTotalAmount: minTotalAmount,
                          maxTotalAmount: maxTotalAmount,
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Store and Customer Filters
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Filter by Store',
                        labelStyle:
                        const TextStyle(color: AppColors.textSecondary),
                        filled: true,
                        fillColor: AppColors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                              color: AppColors.textSecondary.withOpacity(0.3)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                              color: AppColors.textSecondary.withOpacity(0.3)),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                      ),
                      value: selectedStoreId,
                      hint: const Text(
                        'All Stores',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                      items: [
                        const DropdownMenuItem(
                            value: null, child: Text('All Stores')),
                        ...stores.map((store) => DropdownMenuItem(
                          value: store.storeId,
                          child: Text(store.name),
                        )),
                      ],
                      onChanged: (value) {
                        _adminOrderCubit.fetchOrders(
                          startDate: orderStartDate,
                          endDate: orderEndDate,
                          status: selectedStatus,
                          expectedDeliveryStartDate: expectedStartDate,
                          expectedDeliveryEndDate: expectedEndDate,
                          orderTakenBy: validOrderTakenBy,
                          orderDeliveredBy: validOrderDeliveredBy,
                          storeId: value,
                          userId: validUserId,
                          minTotalAmount: minTotalAmount,
                          maxTotalAmount: maxTotalAmount,
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Filter by Customer',
                        labelStyle:
                        const TextStyle(color: AppColors.textSecondary),
                        filled: true,
                        fillColor: AppColors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                              color: AppColors.textSecondary.withOpacity(0.3)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                              color: AppColors.textSecondary.withOpacity(0.3)),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                      ),
                      value: validUserId,
                      hint: const Text(
                        'All Customers',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                      items: customerDropdownItems,
                      onChanged: (value) {
                        _adminOrderCubit.fetchOrders(
                          startDate: orderStartDate,
                          endDate: orderEndDate,
                          status: selectedStatus,
                          expectedDeliveryStartDate: expectedStartDate,
                          expectedDeliveryEndDate: expectedEndDate,
                          orderTakenBy: validOrderTakenBy,
                          orderDeliveredBy: validOrderDeliveredBy,
                          storeId: selectedStoreId,
                          userId: value,
                          minTotalAmount: minTotalAmount,
                          maxTotalAmount: maxTotalAmount,
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Amount Filters
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Min Total Amount',
                        border: OutlineInputBorder(),
                        contentPadding:
                        EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      keyboardType: TextInputType.number,
                      initialValue: minTotalAmount?.toString() ?? '',
                      onFieldSubmitted: (value) {
                        final min = double.tryParse(value);
                        _adminOrderCubit.fetchOrders(
                          startDate: orderStartDate,
                          endDate: orderEndDate,
                          status: selectedStatus,
                          expectedDeliveryStartDate: expectedStartDate,
                          expectedDeliveryEndDate: expectedEndDate,
                          orderTakenBy: validOrderTakenBy,
                          orderDeliveredBy: validOrderDeliveredBy,
                          storeId: selectedStoreId,
                          userId: validUserId,
                          minTotalAmount: min,
                          maxTotalAmount: maxTotalAmount,
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Max Total Amount',
                        border: OutlineInputBorder(),
                        contentPadding:
                        EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      keyboardType: TextInputType.number,
                      initialValue: maxTotalAmount?.toString() ?? '',
                      onFieldSubmitted: (value) {
                        final max = double.tryParse(value);
                        _adminOrderCubit.fetchOrders(
                          startDate: orderStartDate,
                          endDate: orderEndDate,
                          status: selectedStatus,
                          expectedDeliveryStartDate: expectedStartDate,
                          expectedDeliveryEndDate: expectedEndDate,
                          orderTakenBy: validOrderTakenBy,
                          orderDeliveredBy: validOrderDeliveredBy,
                          storeId: selectedStoreId,
                          userId: validUserId,
                          minTotalAmount: minTotalAmount,
                          maxTotalAmount: max,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
  Widget _buildStatsCard(BuildContext context) {
    return BlocBuilder<AdminOrderCubit, AdminOrderState>(
      buildWhen: (previous, current) =>
          current is AdminOrderListFetchLoading ||
          current is AdminOrderListFetchSuccess ||
          current is AdminOrderListFetchError,
      builder: (context, state) {
        if (state is AdminOrderListFetchLoading) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }
        if (state is AdminOrderListFetchError) {
          return Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                '${AppLabels.error}: ${state.message}',
                style: const TextStyle(fontSize: 16, color: AppColors.red),
              ),
            ),
          );
        }
        if (state is AdminOrderListFetchSuccess) {
          return Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Order Statistics',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () => _showStatsDialog(context, state),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          minimumSize: const Size(40, 40),
                        ),
                        child: const Text(
                          'View',
                          style:
                              TextStyle(fontSize: 12, color: AppColors.white),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      childAspectRatio: 3,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                    ),
                    itemCount: state.statistics.length * 2,
                    itemBuilder: (context, index) {
                      final statIndex = index ~/ 2;
                      final isLabel = index % 2 == 0;
                      final stat = state.statistics[statIndex];
                      return Container(
                        decoration: BoxDecoration(
                          color: stat['highlight'] == true
                              ? (stat['color'] as Color).withOpacity(0.1)
                              : Colors.transparent,
                          border: Border.all(
                            color: AppColors.textSecondary.withOpacity(0.5),
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(
                            vertical: 4, horizontal: 8),
                        child: Align(
                          alignment: isLabel
                              ? Alignment.centerLeft
                              : Alignment.centerRight,
                          child: Text(
                            isLabel ? stat['label'] : stat['value'],
                            style: TextStyle(
                              fontSize: 14,
                              color: isLabel
                                  ? AppColors.textSecondary
                                  : stat['color'],
                              fontWeight: stat['highlight'] == true && !isLabel
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  void _showStatsDialog(
      BuildContext context, AdminOrderListFetchSuccess state) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Order Statistics',
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
                    0: FlexColumnWidth(6),
                    1: FlexColumnWidth(2),
                  },
                  children: state.statistics.asMap().entries.map((entry) {
                    final stat = entry.value;
                    final isLast = entry.key == state.statistics.length - 1;
                    final isFirst = entry.key == 0;
                    return _buildTableRow(
                      stat['label'],
                      stat['value'],
                      valueColor: stat['color'],
                      valueWeight:
                          stat['highlight'] == true ? FontWeight.bold : null,
                      backgroundColor: stat['highlight'] == true
                          ? (stat['color'] as Color).withOpacity(0.1)
                          : null,
                      borderRadius: isFirst
                          ? const BorderRadius.only(
                              topLeft: Radius.circular(12),
                              topRight: Radius.circular(12),
                            )
                          : isLast
                              ? const BorderRadius.only(
                                  bottomLeft: Radius.circular(12),
                                  bottomRight: Radius.circular(12),
                                )
                              : null,
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.center,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                  ),
                  child: const Text(
                    'Close',
                    style: TextStyle(color: AppColors.white, fontSize: 14),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildExpectedDeliveryLabel() {
    return BlocBuilder<AdminOrderCubit, AdminOrderState>(
      buildWhen: (previous, current) =>
          current is AdminOrderListFetchSuccess ||
          current is AdminOrderListFetchLoading ||
          current is AdminOrderListFetchError,
      builder: (context, state) {
        String label = 'All Orders';
        if (state is AdminOrderListFetchSuccess) {
          label = state.expectedDeliveryRangeLabel;
        }
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.white,
            ),
          ),
        );
      },
    );
  }

  Widget _buildOrderList() {
    return BlocBuilder<AdminOrderCubit, AdminOrderState>(
      buildWhen: (previous, current) =>
          current is AdminOrderListFetchLoading ||
          current is AdminOrderListFetchSuccess ||
          current is AdminOrderListFetchError,
      builder: (context, state) {
        if (state is AdminOrderListFetchSuccess) {
          final dates = state.groupedOrders.keys.toList()
            ..sort((a, b) => DateFormat('MMM dd, yyyy')
                .parse(b)
                .compareTo(DateFormat('MMM dd, yyyy').parse(a)));
          return SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final date = dates[index];
                final orders = state.groupedOrders[date]!;
                return StickyHeader(
                  header: Container(
                    width: double.infinity,
                    color: Theme.of(context).scaffoldBackgroundColor,
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: Text(
                      date,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  content: Column(
                    children: orders
                        .map((order) => _buildOrderCard(context, order, state))
                        .toList(),
                  ),
                );
              },
              childCount: dates.length,
            ),
          );
        }
        return const SliverToBoxAdapter(child: SizedBox.shrink());
      },
    );
  }

  Widget _buildOrderCard(BuildContext context, Order order, AdminOrderListFetchSuccess state) {
    final statusStyles = _adminOrderCubit.getStatusColors(order.status);
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      child: InkWell(
        onTap: () => sl<Coordinator>().navigateToAdminOrderDetailsPage(order.id),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.receipt,
                    color: AppColors.primary,
                    size: 36,
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order #${order.id}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        'Customer: ${order.userName}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  Expanded(child: SizedBox()),
                  ElevatedButton(
                    onPressed: () => sl<Coordinator>().navigateToBillingPage(orderId: order.id),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      minimumSize: const Size(40, 30),
                    ),
                    child: const Text(
                      'Create Bill',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppColors.textSecondary.withOpacity(0.5),
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  context.read<AdminOrderCubit>().formatOrderDate(order.orderDate),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
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
                      _buildTableRow(
                        'Products',
                        context.read<AdminOrderCubit>().getProductNames(order.items),
                        maxLines: 2,
                      ),
                      _buildTableRow(
                        'Status',
                        order.status,
                        valueColor: statusStyles['color'],
                        backgroundColor: statusStyles['backgroundColor'],
                        valueWeight: order.status.toLowerCase() == 'pending' ||
                            order.status.toLowerCase() == 'processing'
                            ? FontWeight.bold
                            : null,
                      ),
                      _buildTableRow(
                        'Total',
                        '₹${order.totalAmount.toStringAsFixed(2)}',
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
    FontWeight? valueWeight,
    Color? valueColor = AppColors.textSecondary,
    Color? backgroundColor,
    BorderRadius? borderRadius,
    int maxLines = 1,
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
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
          child: Align(
            alignment: Alignment.centerRight,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: valueColor,
                fontWeight: valueWeight ??
                    (isBold ? FontWeight.bold : FontWeight.normal),
              ),
              maxLines: maxLines,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ],
    );
  }
}
