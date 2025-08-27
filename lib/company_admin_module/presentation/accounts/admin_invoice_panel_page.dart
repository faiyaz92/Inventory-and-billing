import 'package:auto_route/auto_route.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:requirment_gathering_app/company_admin_module/presentation/accounts/invoice_cubit.dart';
import 'package:requirment_gathering_app/company_admin_module/presentation/ledger/user_ledger_cubit.dart';
import 'package:requirment_gathering_app/company_admin_module/repositories/stock_repository.dart';
import 'package:requirment_gathering_app/core_module/coordinator/coordinator.dart';
import 'package:requirment_gathering_app/core_module/presentation/widget/custom_appbar.dart';
import 'package:requirment_gathering_app/core_module/repository/account_repository.dart';
import 'package:requirment_gathering_app/core_module/service_locator/service_locator.dart';
import 'package:requirment_gathering_app/core_module/utils/AppColor.dart';
import 'package:requirment_gathering_app/core_module/utils/AppLabels.dart';
import 'package:requirment_gathering_app/core_module/utils/custom_loading_dialog.dart';
import 'package:requirment_gathering_app/core_module/utils/text_styles.dart';
import 'package:requirment_gathering_app/super_admin_module/data/user_info.dart';
import 'package:requirment_gathering_app/super_admin_module/utils/user_type.dart';
import 'package:requirment_gathering_app/user_module/cart/data/order_model.dart';
import 'package:requirment_gathering_app/user_module/cart/services/iorder_service.dart';
import 'package:sticky_headers/sticky_headers.dart';

@RoutePage()
class AdminInvoicePanelPage extends StatefulWidget {
  const AdminInvoicePanelPage({super.key});

  @override
  State<AdminInvoicePanelPage> createState() => _AdminInvoicePanelPageState();
}

class _AdminInvoicePanelPageState extends State<AdminInvoicePanelPage> {
  String _selectedFilter = '3months';
  late final AdminInvoiceCubit _adminInvoiceCubit;
  late DateTime startDate;
  late DateTime endDate;

  @override
  void initState() {
    _adminInvoiceCubit = sl<AdminInvoiceCubit>();
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
        startDate = now.subtract(const Duration(days: 90));
        endDate = now;
        break;
    }

    _adminInvoiceCubit.fetchInvoices(
      startDate: startDate,
      endDate: endDate,
    );
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
              'Quick filter',
              style:
                  defaultTextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
      create: (_) => _adminInvoiceCubit,
      child: Scaffold(
        appBar: const CustomAppBar(title: 'Invoice Panel'),
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
            child: BlocBuilder<AdminInvoiceCubit, AdminInvoiceState>(
              builder: (context, state) {
                if (state is AdminInvoiceListFetchLoading) {
                  return const CustomLoadingDialog(message: 'Loading...');
                } else if (state is AdminInvoiceListFetchSuccess) {
                  return CustomScrollView(
                    slivers: [
                      SliverPadding(
                        padding: const EdgeInsets.all(16.0),
                        sliver: SliverList(
                          delegate: SliverChildListDelegate([
                            TextField(
                              decoration: InputDecoration(
                                hintText: 'Search by Invoice ID',
                                prefixIcon: const Icon(Icons.search),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                filled: true,
                                fillColor: AppColors.white,
                              ),
                              onChanged: (value) {
                                _adminInvoiceCubit.filterInvoicesById(value);
                              },
                            ),
                            const SizedBox(height: 16),
                            _buildFilters(context),
                            const SizedBox(height: 16),
                            _buildStatsCard(context),
                            const SizedBox(height: 16),
                            _buildInvoiceGeneratedDateLabel(),
                            const SizedBox(height: 8),
                          ]),
                        ),
                      ),
                      _buildInvoiceList(),
                    ],
                  );
                } else if (state is AdminInvoiceListFetchError) {
                  return Center(child: Text('Error: ${state.message}'));
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilters(BuildContext context) {
    return BlocBuilder<AdminInvoiceCubit, AdminInvoiceState>(
      buildWhen: (previous, current) =>
          current is AdminInvoiceListFetchLoading ||
          current is AdminInvoiceListFetchSuccess ||
          current is AdminInvoiceListFetchError,
      builder: (context, state) {
        if (state is AdminInvoiceListFetchLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is AdminInvoiceListFetchError) {
          return Center(child: Text('Error: ${state.message}'));
        }
        if (state is AdminInvoiceListFetchSuccess) {
          DateTime? invoiceStartDate = state.startDate;
          DateTime? invoiceEndDate = state.endDate;
          String? selectedInvoiceType = state.invoiceType;
          String? selectedPaymentStatus = state.paymentStatus;
          String? selectedInvoiceIssuer = state.invoiceLastUpdatedBy;
          String? selectedStoreId = state.storeId;
          String? selectedUserId = state.userId;
          double? minTotalAmount = state.minTotalAmount;
          double? maxTotalAmount = state.maxTotalAmount;
          List<UserInfo> users = state.users;
          List<StoreDto> stores = state.stores;

          final employeeUsers = users
              .where((user) => user.userType == UserType.Employee)
              .toList();
          final customerUsers = users
              .where((user) => user.userType == UserType.Customer)
              .toList();

          final validInvoiceIssuer = selectedInvoiceIssuer != null &&
                  employeeUsers
                      .any((user) => user.userId == selectedInvoiceIssuer)
              ? selectedInvoiceIssuer
              : null;
          final validUserId = selectedUserId != null &&
                  customerUsers.any((user) => user.userId == selectedUserId)
              ? selectedUserId
              : null;

          final employeeDropdownItems = [
            const DropdownMenuItem<String>(value: null, child: Text('Select')),
            ...employeeUsers
                .where((user) => user.userId != null && user.userId!.isNotEmpty)
                .map((user) => DropdownMenuItem<String>(
                      value: user.userId,
                      child: Text(user.name ?? 'Unknown'),
                    )),
          ];

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
                            start: invoiceStartDate ?? DateTime.now(),
                            end: invoiceEndDate ?? DateTime.now(),
                          ),
                        );
                        if (dateRange != null) {
                          _adminInvoiceCubit.fetchInvoices(
                            startDate: dateRange.start,
                            endDate: dateRange.end,
                            invoiceType: selectedInvoiceType,
                            paymentStatus: selectedPaymentStatus,
                            invoiceLastUpdatedBy: validInvoiceIssuer,
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
                        'Date Range: Invoice',
                        style: TextStyle(color: AppColors.white, fontSize: 14),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildQuickFilterChips(),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Filter by Invoice Type',
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
                      value: selectedInvoiceType,
                      hint: const Text(
                        'All Invoice Types',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                      items: const [
                        DropdownMenuItem(
                            value: null, child: Text('All Invoice Types')),
                        DropdownMenuItem(value: 'Cash', child: Text('Cash')),
                        DropdownMenuItem(
                            value: 'Credit', child: Text('Credit')),
                      ],
                      onChanged: (value) {
                        _adminInvoiceCubit.fetchInvoices(
                          startDate: invoiceStartDate,
                          endDate: invoiceEndDate,
                          invoiceType: value,
                          paymentStatus: selectedPaymentStatus,
                          invoiceLastUpdatedBy: validInvoiceIssuer,
                          storeId: selectedStoreId,
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
                        labelText: 'Filter by Payment Status',
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
                      value: selectedPaymentStatus,
                      hint: const Text(
                        'All Payment Statuses',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                      items: const [
                        DropdownMenuItem(
                            value: null, child: Text('All Payment Statuses')),
                        DropdownMenuItem(value: 'Paid', child: Text('Paid')),
                        DropdownMenuItem(
                            value: 'Partial Paid', child: Text('Partial Paid')),
                        DropdownMenuItem(
                            value: 'Not Paid', child: Text('Not Paid')),
                      ],
                      onChanged: (value) {
                        _adminInvoiceCubit.fetchInvoices(
                          startDate: invoiceStartDate,
                          endDate: invoiceEndDate,
                          invoiceType: selectedInvoiceType,
                          paymentStatus: value,
                          invoiceLastUpdatedBy: validInvoiceIssuer,
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
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Invoice Issuer',
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
                      value: validInvoiceIssuer,
                      hint: const Text(
                        'All Issuers',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                      items: employeeDropdownItems,
                      onChanged: (value) {
                        _adminInvoiceCubit.fetchInvoices(
                          startDate: invoiceStartDate,
                          endDate: invoiceEndDate,
                          invoiceType: selectedInvoiceType,
                          paymentStatus: selectedPaymentStatus,
                          invoiceLastUpdatedBy: value,
                          storeId: selectedStoreId,
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
                            horizontal: 12, vertical: 12),
                      ),
                      value: validUserId,
                      hint: const Text(
                        'All Customers',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                      items: customerDropdownItems,
                      onChanged: (value) {
                        _adminInvoiceCubit.fetchInvoices(
                          startDate: invoiceStartDate,
                          endDate: invoiceEndDate,
                          invoiceType: selectedInvoiceType,
                          paymentStatus: selectedPaymentStatus,
                          invoiceLastUpdatedBy: validInvoiceIssuer,
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
                        _adminInvoiceCubit.fetchInvoices(
                          startDate: invoiceStartDate,
                          endDate: invoiceEndDate,
                          invoiceType: selectedInvoiceType,
                          paymentStatus: selectedPaymentStatus,
                          invoiceLastUpdatedBy: validInvoiceIssuer,
                          storeId: value,
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
                        _adminInvoiceCubit.fetchInvoices(
                          startDate: invoiceStartDate,
                          endDate: invoiceEndDate,
                          invoiceType: selectedInvoiceType,
                          paymentStatus: selectedPaymentStatus,
                          invoiceLastUpdatedBy: validInvoiceIssuer,
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
                        _adminInvoiceCubit.fetchInvoices(
                          startDate: invoiceStartDate,
                          endDate: invoiceEndDate,
                          invoiceType: selectedInvoiceType,
                          paymentStatus: selectedPaymentStatus,
                          invoiceLastUpdatedBy: validInvoiceIssuer,
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
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => _adminInvoiceCubit.fetchInvoices(),
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
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildStatsCard(BuildContext context) {
    return BlocBuilder<AdminInvoiceCubit, AdminInvoiceState>(
      buildWhen: (previous, current) =>
          current is AdminInvoiceListFetchLoading ||
          current is AdminInvoiceListFetchSuccess ||
          current is AdminInvoiceListFetchError,
      builder: (context, state) {
        if (state is AdminInvoiceListFetchLoading) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }
        if (state is AdminInvoiceListFetchError) {
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
        if (state is AdminInvoiceListFetchSuccess) {
          final crossAxisCount = kIsWeb ? 7 : 4;
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
                        'Invoice Statistics',
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
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      childAspectRatio: kIsWeb ? 1.0 : 1.2,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                    ),
                    itemCount: state.statistics.length,
                    itemBuilder: (context, index) {
                      final stat = state.statistics[index];
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
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _getIconForStat(stat['label']),
                              color: stat['color'],
                              size: kIsWeb ? 28 : 24,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              stat['label'],
                              style: TextStyle(
                                fontSize: kIsWeb ? 16 : 14,
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              stat['value'],
                              style: TextStyle(
                                fontSize: kIsWeb ? 16 : 14,
                                color: stat['color'],
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
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

  IconData _getIconForStat(String label) {
    switch (label) {
      case 'Total Invoices':
        return Icons.receipt_long;
      case 'Total Amount':
        return Icons.account_balance_wallet;
      case 'Cash Sales':
        return Icons.money;
      case 'Credit Sales':
        return Icons.credit_card;
      case 'No of Cash Invoices':
        return Icons.attach_money;
      case 'Paid':
        return Icons.check_circle;
      case 'Partial Paid':
        return Icons.hourglass_top;
      case 'Not Paid':
        return Icons.cancel;
      case "Today's Invoices":
        return Icons.today;
      case 'Total Collected Amount':
        return Icons.payments;
      case 'Pending Collection Amount':
        return Icons.warning;
      default:
        return Icons.info;
    }
  }

  void _showStatsDialog(
      BuildContext context, AdminInvoiceListFetchSuccess state) {
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
                'Invoice Statistics',
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

  Widget _buildInvoiceGeneratedDateLabel() {
    return BlocBuilder<AdminInvoiceCubit, AdminInvoiceState>(
      buildWhen: (previous, current) =>
          current is AdminInvoiceListFetchSuccess ||
          current is AdminInvoiceListFetchLoading ||
          current is AdminInvoiceListFetchError,
      builder: (context, state) {
        String label = 'All Invoices';
        if (state is AdminInvoiceListFetchSuccess) {
          label = state.dateRangeLabel;
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

  Widget _buildInvoiceList() {
    return BlocBuilder<AdminInvoiceCubit, AdminInvoiceState>(
      buildWhen: (previous, current) =>
          current is AdminInvoiceListFetchLoading ||
          current is AdminInvoiceListFetchSuccess ||
          current is AdminInvoiceListFetchError,
      builder: (context, state) {
        if (state is AdminInvoiceListFetchSuccess) {
          final dates = state.groupedInvoices.keys.toList()
            ..sort((a, b) => a == 'No Date'
                ? 1
                : b == 'No Date'
                    ? -1
                    : DateFormat('MMM dd, yyyy')
                        .parse(b)
                        .compareTo(DateFormat('MMM dd, yyyy').parse(a)));
          return SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final date = dates[index];
                final invoices = state.groupedInvoices[date]!;
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
                    children: invoices
                        .map((invoice) =>
                            _buildInvoiceCard(context, invoice, state))
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

  Widget _buildInvoiceCard(
      BuildContext context, Order invoice, AdminInvoiceListFetchSuccess state) {
    final statusStyles =
        _adminInvoiceCubit.getStatusColors(invoice.paymentStatus);
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      child: InkWell(
        onTap: () {
// sl<Coordinator>().navigateToAdminInvoiceDetailsPage(invoice.id);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.receipt_long,
                    color: AppColors.primary,
                    size: 36,
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Invoice #${invoice.id}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        'Customer: ${invoice.userName ?? 'Unknown'}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const Expanded(child: SizedBox()),
                  if (invoice.paymentStatus != 'Paid')
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ElevatedButton(
                        onPressed: () =>
                            _showReceiveCashDialog(context, invoice),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          minimumSize: const Size(40, 30),
                        ),
                        child: const Text(
                          'Receive Cash',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                    ),
                  ElevatedButton(
                    onPressed: () => sl<Coordinator>()
                        .navigateToBillingPage(orderId: invoice.id),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      minimumSize: const Size(40, 30),
                    ),
                    child: Text(
                      invoice.billNumber == null || invoice.billNumber!.isEmpty
                          ? 'View Invoice'
                          : 'Update Invoice',
                      style: const TextStyle(
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
                  invoice.invoiceGeneratedDate != null
                      ? context
                          .read<AdminInvoiceCubit>()
                          .formatInvoiceDate(invoice.invoiceGeneratedDate!)
                      : 'No Date',
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
                        context
                            .read<AdminInvoiceCubit>()
                            .getProductNames(invoice.items),
                        maxLines: 2,
                      ),
                      _buildTableRow(
                        'Invoice Type',
                        invoice.invoiceType ?? 'N/A',
                        valueColor: invoice.invoiceType == 'Cash'
                            ? Colors.green
                            : Colors.blue,
                        backgroundColor: invoice.invoiceType != null
                            ? (invoice.invoiceType == 'Cash'
                                    ? Colors.green
                                    : Colors.blue)
                                .withOpacity(0.1)
                            : Colors.transparent,
                      ),
                      _buildTableRow(
                        'Payment Status',
                        invoice.paymentStatus ?? 'Not Paid',
                        valueColor: statusStyles['color'],
                        backgroundColor: statusStyles['backgroundColor'],
                        valueWeight: invoice.paymentStatus == 'Partial Paid' ||
                                invoice.paymentStatus == 'Not Paid'
                            ? FontWeight.bold
                            : null,
                      ),
                      _buildTableRow(
                        'Total',
                        '₹${invoice.totalAmount.toStringAsFixed(2)}',
                        isBold: true,
                        valueColor: AppColors.textPrimary,
                        backgroundColor: AppColors.primary.withOpacity(0.1),
                      ),
                      _buildTableRow(
                        'Outstanding',
                        '₹${(invoice.totalAmount - (invoice.amountReceived ?? 0.0)).toStringAsFixed(2)}',
                        isBold: true,
                        valueColor: AppColors.red,
                        backgroundColor: AppColors.red.withOpacity(0.1),
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

  Future<void> _showReceiveCashDialog(BuildContext context, Order invoice) async {
    final TextEditingController amountController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool isLoading = false; // Track loading state

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Receive Cash'),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Order ID: ${invoice.id}', style: const TextStyle(fontSize: 14)),
                    Text('Invoice Number: ${invoice.billNumber ?? 'N/A'}', style: const TextStyle(fontSize: 14)),
                    Text(
                      'Outstanding: ₹${(invoice.totalAmount - (invoice.amountReceived ?? 0.0)).toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: amountController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Amount',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Amount is required';
                        }
                        final amount = double.tryParse(value);
                        if (amount == null || amount <= 0) {
                          return 'Enter a valid positive amount';
                        }
                        final outstanding = invoice.totalAmount - (invoice.amountReceived ?? 0.0);
                        if (amount > outstanding) {
                          return 'Amount cannot exceed outstanding balance of ₹${outstanding.toStringAsFixed(2)}';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isLoading ? null : () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                    if (formKey.currentState!.validate()) {
                      setState(() => isLoading = true); // Show loading
                      final amount = double.parse(amountController.text);
                      await _processPayment(context, invoice, amount);
                      if (dialogContext.mounted) {
                        Navigator.pop(dialogContext);
                      }
                    }
                  },
                  child: isLoading
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.white,
                    ),
                  )
                      : const Text('Receive'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _processPayment(BuildContext context, Order invoice, double amount) async {
    final orderService = sl<IOrderService>();
    final ledgerCubit = sl<UserLedgerCubit>();
    final userInfo = await sl<AccountRepository>().getUserInfo();
    final userId = userInfo?.userId;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User ID not found')),
      );
      return;
    }

    final currentAmountReceived = invoice.amountReceived ?? 0.0;
    final outstanding = invoice.totalAmount - currentAmountReceived;
    if (amount > outstanding) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Amount cannot exceed outstanding balance of ₹${outstanding.toStringAsFixed(2)}')),
      );
      return;
    }

    final newAmountReceived = currentAmountReceived + amount;
    final paymentStatus = newAmountReceived >= invoice.totalAmount ? 'Paid' : 'Partial Paid';

    final updatedOrder = invoice.copyWith(
      amountReceived: newAmountReceived,
      paymentStatus: paymentStatus,
      paymentDetails: [
        ...(invoice.paymentDetails ?? []),
        {
          'date': DateTime.now(),
          'amount': amount,
          'method': 'Cash',
        },
      ],
      invoiceLastUpdatedBy: userId,
    );

    await orderService.updateInvoice(updatedOrder);

    final customerLedgerId = invoice.customerLedgerId;
    if (customerLedgerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Customer ledger ID not found')),
      );
      return;
    }

    final loggedInUserLedgerId = userInfo?.accountLedgerId;
    if (loggedInUserLedgerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Logged-in user ledger ID not found')),
      );
      return;
    }

    await ledgerCubit.addTransaction(
      ledgerId: customerLedgerId,
      amount: amount,
      type: 'Credit',
      billNumber: invoice.billNumber,
      purpose: 'Payment',
      typeOfPurpose: 'Cash',
      remarks: 'Payment received for invoice ${invoice.id}',
      userType: UserType.Customer,
    );

    await ledgerCubit.addTransaction(
      ledgerId: loggedInUserLedgerId,
      amount: amount,
      type: 'Debit',
      billNumber: invoice.billNumber,
      purpose: 'Cash Received',
      typeOfPurpose: 'Cash',
      remarks: 'Cash received from customer for invoice ${invoice.id}',
      userType: userInfo?.userType ?? UserType.Employee,
    );

    final receiptPdf = await _generateReceiptPdf(updatedOrder, amount);

    await sl<Coordinator>().navigateToBillPdfPage(pdf: receiptPdf, billNumber: invoice.id);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Payment received successfully')),
    );

    _adminInvoiceCubit.fetchInvoices(
      startDate: startDate,
      endDate: endDate,
    );
  }  Future<pw.Document> _generateReceiptPdf(Order order, double amount) async {
    final pdf = pw.Document();
    final accountRepository = sl<AccountRepository>();

    String companyName = 'Abc Pvt. Ltd.';
    String issuerName = 'Unknown Issuer';
    try {
      final userInfo = await accountRepository.getUserInfo();
      companyName = userInfo?.companyId ?? companyName;
      issuerName = userInfo?.name ?? userInfo?.userName ?? issuerName;
    } catch (e) {
      print('Error fetching company or issuer name: $e');
    }

    final primaryColor = PdfColor.fromInt(AppColors.primary.value);
    final textSecondaryColor = PdfColor.fromInt(AppColors.textSecondary.value);
    final greyColor = PdfColors.grey300;

    final regularFont = pw.Font.times();
    final boldFont = pw.Font.timesBold();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        header: (context) => pw.Container(
          padding: const pw.EdgeInsets.only(bottom: 12),
          decoration: pw.BoxDecoration(
            border:
                pw.Border(bottom: pw.BorderSide(width: 3, color: primaryColor)),
          ),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    companyName,
                    style: pw.TextStyle(
                        font: boldFont, fontSize: 22, color: primaryColor),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    '123 Business Street, City, Country',
                    style: pw.TextStyle(
                        font: regularFont,
                        fontSize: 12,
                        color: textSecondaryColor),
                  ),
                ],
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text(
                    'RECEIPT',
                    style: pw.TextStyle(
                        font: boldFont, fontSize: 28, color: primaryColor),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    'Invoice #: ${order.id}',
                    style: pw.TextStyle(font: regularFont, fontSize: 14),
                  ),
                  pw.Text(
                    'Bill #: ${order.billNumber ?? 'N/A'}',
                    style: pw.TextStyle(font: regularFont, fontSize: 14),
                  ),
                  pw.Text(
                    'Date: ${DateTime.now().toString().substring(0, 10)}',
                    style: pw.TextStyle(font: regularFont, fontSize: 14),
                  ),
                  pw.Text(
                    'Issuer: $issuerName',
                    style: pw.TextStyle(font: regularFont, fontSize: 14),
                  ),
                ],
              ),
            ],
          ),
        ),
        build: (context) => [
          pw.SizedBox(height: 24),
          pw.Text(
            'Received From:',
            style: pw.TextStyle(
                font: boldFont, fontSize: 18, color: PdfColors.black),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            order.userName ?? 'Unknown Customer',
            style:
                pw.TextStyle(font: boldFont, fontSize: 16, color: primaryColor),
          ),
          pw.SizedBox(height: 24),
          pw.Text(
            'Payment Details',
            style: pw.TextStyle(font: boldFont, fontSize: 18),
          ),
          pw.SizedBox(height: 12),
          pw.Table(
            border: pw.TableBorder.all(color: greyColor, width: 1),
            columnWidths: {
              0: const pw.FlexColumnWidth(2),
              1: const pw.FlexColumnWidth(2),
            },
            children: [
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.grey100),
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(10),
                    child: pw.Text('Description',
                        style: pw.TextStyle(font: boldFont, fontSize: 13)),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(10),
                    child: pw.Text('Amount',
                        style: pw.TextStyle(font: boldFont, fontSize: 13)),
                  ),
                ],
              ),
              pw.TableRow(
                decoration: pw.BoxDecoration(
                  border: pw.Border(
                      bottom: pw.BorderSide(color: greyColor, width: 0.5)),
                ),
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(10),
                    child: pw.Text(
                      'Payment for Invoice #${order.id}',
                      style: pw.TextStyle(font: regularFont, fontSize: 12),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(10),
                    child: pw.Text(
                      amount.toStringAsFixed(2),
                      style: pw.TextStyle(font: regularFont, fontSize: 12),
                      textAlign: pw.TextAlign.right,
                    ),
                  ),
                ],
              ),
            ],
          ),
          pw.SizedBox(height: 24),
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: PdfColors.grey50,
              border: pw.Border.all(color: greyColor, width: 1),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.end,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text(
                      'Total Amount Received: ${amount.toStringAsFixed(2)}',
                      style: pw.TextStyle(
                          font: boldFont, fontSize: 16, color: primaryColor),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Text(
                      'Outstanding: ${(order.totalAmount - (order.amountReceived ?? 0.0)).toStringAsFixed(2)}',
                      style: pw.TextStyle(font: regularFont, fontSize: 14),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
        footer: (context) => pw.Container(
          alignment: pw.Alignment.center,
          padding: const pw.EdgeInsets.only(top: 12),
          child: pw.Text(
            'Generated by $companyName | Page ${context.pageNumber} of ${context.pagesCount}',
            style: pw.TextStyle(
                font: regularFont, fontSize: 10, color: textSecondaryColor),
          ),
        ),
      ),
    );

    return pdf;
  }
}
