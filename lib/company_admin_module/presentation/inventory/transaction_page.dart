import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:requirment_gathering_app/company_admin_module/data/inventory/transaction_model.dart';
import 'package:requirment_gathering_app/company_admin_module/presentation/inventory/stock_cubit.dart';
import 'package:requirment_gathering_app/company_admin_module/presentation/inventory/transaction_cubit.dart';
import 'package:requirment_gathering_app/company_admin_module/repositories/stock_repository.dart';
import 'package:requirment_gathering_app/company_admin_module/service/user_services.dart';
import 'package:requirment_gathering_app/core_module/presentation/widget/custom_appbar.dart';
import 'package:requirment_gathering_app/core_module/service_locator/service_locator.dart';
import 'package:requirment_gathering_app/core_module/utils/AppColor.dart';
import 'package:requirment_gathering_app/core_module/utils/custom_loading_dialog.dart'
    show CustomLoadingDialog;
import 'package:requirment_gathering_app/super_admin_module/data/user_info.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:shimmer/shimmer.dart';
@RoutePage()
class TransactionsPage extends StatefulWidget {
  const TransactionsPage({Key? key}) : super(key: key);

  @override
  _TransactionsPageState createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  String? _selectedStoreId;
  String? _selectedUserId;
  String? _selectedFromStoreId;
  String? _selectedToStoreId;
  String? _selectedType;
  DateTime? _startDate;
  DateTime? _endDate;
  late TransactionCubit _transactionCubit;
  late StockCubit _stockCubit;
  late UserServices _userServices;
  int _currentPage = 1;
  final int _pageSize = 20;
  List<UserInfo> _users = [];

  @override
  void initState() {
    super.initState();
    _transactionCubit = sl<TransactionCubit>();
    _stockCubit = sl<StockCubit>()..fetchStock('');
    _userServices = sl<UserServices>();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _fetchUsersForStore(String storeId) async {
    try {
      final users =
          await _userServices.getUsersFromTenantCompany(storeId: storeId);
      setState(() {
        _users = users;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to fetch users: $e'),
          backgroundColor: AppColors.red,
        ),
      );
    }
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
      _currentPage = 1;
      _fetchFilteredTransactions();
    }
  }

  void _fetchFilteredTransactions({bool loadMore = false}) {
    if (_selectedStoreId != null) {
      _transactionCubit.fetchTransactions(
        storeId: _selectedStoreId!,
        userId: _selectedUserId,
        fromStoreId: _selectedFromStoreId,
        toStoreId: _selectedToStoreId,
        type: _selectedType,
        startDate: _startDate,
        endDate: _endDate,
        page: loadMore ? _currentPage + 1 : 1,
        pageSize: _pageSize,
      );
      if (loadMore) {
        setState(() {
          _currentPage++;
        });
      }
    }
  }

  void _clearFilters() {
    setState(() {
      _selectedUserId = null;
      _selectedFromStoreId = null;
      _selectedToStoreId = null;
      _selectedType = null;
      _startDate = null;
      _endDate = null;
      _currentPage = 1;
    });
    _fetchFilteredTransactions();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => _transactionCubit),
        BlocProvider(create: (_) => _stockCubit),
      ],
      child: Scaffold(
        appBar: const CustomAppBar(title: 'Transactions'),
        body: Container(
          height: MediaQuery.of(context).size.height, // Ensure full screen height
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
            child: BlocBuilder<StockCubit, StockState>(
              builder: (context, state) {
                if (state is StockLoading) {
                  return const Center(
                    heightFactor: 1.0, // Ensure full height centering
                    child: CustomLoadingDialog(message: 'Loading...'),
                  );
                }
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: MediaQuery.of(context).size.height -
                          MediaQuery.of(context).padding.top -
                          kToolbarHeight, // Account for appBar and safe area
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Store Selection
                        _buildStoreDropdown(),
                        // Filters Card
                        if (_selectedStoreId != null) _buildFiltersCard(),
                        // Transaction List
                        _buildTransactionList(),
                        const SizedBox(height: 16), // Bottom padding
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
  // Store Dropdown Widget
  Widget _buildStoreDropdown() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: BlocBuilder<StockCubit, StockState>(
        builder: (context, stockState) {
          if (stockState is StockLoading) {
            return const Center(
                child: CustomLoadingDialog(message: 'Loading...'));
          } else if (stockState is StockError) {
            return _buildErrorCard(stockState.error);
          }

          final stores = (stockState is StockLoaded) ? stockState.stores : [];

          return DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: 'Store',
              labelStyle: const TextStyle(color: AppColors.textSecondary),
              filled: true,
              fillColor: AppColors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: AppColors.textSecondary.withOpacity(0.3),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: AppColors.textSecondary.withOpacity(0.3),
                ),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            value: _selectedStoreId,
            hint: const Text(
              'Select a store',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            items: stores
                .map((store) => DropdownMenuItem<String>(
                      value: store.storeId,
                      child: Text(
                        store.storeId,
                        style: const TextStyle(color: AppColors.textPrimary),
                      ),
                    ))
                .toList(),
            onChanged: (value) {
              setState(() {
                _selectedStoreId = value;
                _selectedUserId = null;
                _selectedFromStoreId = null;
                _selectedToStoreId = null;
                _selectedType = null;
                _startDate = null;
                _endDate = null;
                _currentPage = 1;
                _users = [];
              });
              if (value != null) {
                _fetchUsersForStore(value);
                _fetchFilteredTransactions();
              }
            },
            validator: (value) =>
                value == null ? 'Please select a store' : null,
          );
        },
      ),
    );
  }

  // Filters Card Widget
  Widget _buildFiltersCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: AppColors.textSecondary.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Filters',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              _buildTypeFilter(),
              const SizedBox(height: 12),
              _buildUserFilter(),
              const SizedBox(height: 12),
              _buildFromStoreFilter(),
              const SizedBox(height: 12),
              _buildToStoreFilter(),
              const SizedBox(height: 12),
              _buildDateRangeButton(),
              const SizedBox(height: 12),
              _buildClearFiltersButton(),
            ],
          ),
        ),
      ),
    );
  }

  // Type Filter Dropdown
  Widget _buildTypeFilter() {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: 'Filter by Type',
        labelStyle: const TextStyle(color: AppColors.textSecondary),
        filled: true,
        fillColor: AppColors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppColors.textSecondary.withOpacity(0.3),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppColors.textSecondary.withOpacity(0.3),
          ),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      value: _selectedType,
      hint: const Text(
        'All Types',
        style: TextStyle(color: AppColors.textSecondary),
      ),
      items: [
        const DropdownMenuItem<String>(
          value: null,
          child: Text(
            'All Types',
            style: TextStyle(color: AppColors.textPrimary),
          ),
        ),
        ...['add', 'out', 'transfer', 'billing']
            .map((type) => DropdownMenuItem<String>(
                  value: type,
                  child: Text(
                    type == 'billing' ? 'OUT' : type.toUpperCase(),
                    style: const TextStyle(color: AppColors.textPrimary),
                  ),
                )),
      ],
      onChanged: (value) {
        setState(() {
          _selectedType = value;
          _currentPage = 1;
        });
        _fetchFilteredTransactions();
      },
    );
  }

  // User Filter Dropdown
  Widget _buildUserFilter() {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: 'Filter by User',
        labelStyle: const TextStyle(color: AppColors.textSecondary),
        filled: true,
        fillColor: AppColors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppColors.textSecondary.withOpacity(0.3),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppColors.textSecondary.withOpacity(0.3),
          ),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      value: _selectedUserId,
      hint: const Text(
        'All Users',
        style: TextStyle(color: AppColors.textSecondary),
      ),
      items: [
        const DropdownMenuItem<String>(
          value: null,
          child: Text(
            'All Users',
            style: TextStyle(color: AppColors.textPrimary),
          ),
        ),
        ..._users.map((user) => DropdownMenuItem<String>(
              value: user.userId,
              child: Text(
                user.userName ?? 'Unknown',
                style: const TextStyle(color: AppColors.textPrimary),
              ),
            )),
      ],
      onChanged: (value) {
        setState(() {
          _selectedUserId = value;
          _currentPage = 1;
        });
        _fetchFilteredTransactions();
      },
    );
  }

  // From Store Filter Dropdown
  Widget _buildFromStoreFilter() {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: 'Filter by From Store',
        labelStyle: const TextStyle(color: AppColors.textSecondary),
        filled: true,
        fillColor: AppColors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppColors.textSecondary.withOpacity(0.3),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppColors.textSecondary.withOpacity(0.3),
          ),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      value: _selectedFromStoreId,
      hint: const Text(
        'All From Stores',
        style: TextStyle(color: AppColors.textSecondary),
      ),
      items: [
        const DropdownMenuItem<String>(
          value: null,
          child: Text(
            'All From Stores',
            style: TextStyle(color: AppColors.textPrimary),
          ),
        ),
        ...(_stockCubit.state is StockLoaded
                ? (_stockCubit.state as StockLoaded).stores
                : [])
            .map((store) => DropdownMenuItem<String>(
                  value: store.storeId,
                  child: Text(
                    store.storeId,
                    style: const TextStyle(color: AppColors.textPrimary),
                  ),
                )),
      ],
      onChanged: (value) {
        setState(() {
          _selectedFromStoreId = value;
          _currentPage = 1;
        });
        _fetchFilteredTransactions();
      },
    );
  }

  // To Store Filter Dropdown
  Widget _buildToStoreFilter() {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: 'Filter by To Store',
        labelStyle: const TextStyle(color: AppColors.textSecondary),
        filled: true,
        fillColor: AppColors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppColors.textSecondary.withOpacity(0.3),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppColors.textSecondary.withOpacity(0.3),
          ),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      value: _selectedToStoreId,
      hint: const Text(
        'All To Stores',
        style: TextStyle(color: AppColors.textSecondary),
      ),
      items: [
        const DropdownMenuItem<String>(
          value: null,
          child: Text(
            'All To Stores',
            style: TextStyle(color: AppColors.textPrimary),
          ),
        ),
        ...(_stockCubit.state is StockLoaded
                ? (_stockCubit.state as StockLoaded).stores
                : [])
            .map((store) => DropdownMenuItem<String>(
                  value: store.storeId,
                  child: Text(
                    store.storeId,
                    style: const TextStyle(color: AppColors.textPrimary),
                  ),
                )),
      ],
      onChanged: (value) {
        setState(() {
          _selectedToStoreId = value;
          _currentPage = 1;
        });
        _fetchFilteredTransactions();
      },
    );
  }

  // Date Range Button
  Widget _buildDateRangeButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: () => _selectDateRange(context),
        child: Text(
          _startDate == null
              ? 'Select Date Range'
              : '${DateFormat('MMM dd, yyyy').format(_startDate!)} - ${DateFormat('MMM dd, yyyy').format(_endDate!)}',
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  // Clear Filters Button
  Widget _buildClearFiltersButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey[300],
          foregroundColor: AppColors.textPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: _clearFilters,
        child: const Text(
          'Clear Filters',
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  // Transaction List Widget

// ... (other imports remain the same)

  Widget _buildTransactionList() {
    return BlocConsumer<TransactionCubit, TransactionState>(
      listener: (context, state) {
        if (state is TransactionError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error),
              backgroundColor: AppColors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is TransactionLoading && _currentPage == 1) {
          return _buildShimmerEffect(); // Show shimmer effect for initial loading
        }

        final transactions = (state is TransactionLoaded) ? state.transactions : [];
        final hasMore = (state is TransactionLoaded) ? state.hasMore : false;

        if (_selectedStoreId == null) {
          return _buildNoStoreCard();
        }

        if (transactions.isEmpty) {
          return _buildNoTransactionsCard();
        }

        return ListView.separated(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          padding: const EdgeInsets.all(16),
          itemCount: transactions.length + (hasMore ? 1 : 0),
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            if (index == transactions.length && hasMore) {
              return BlocBuilder<TransactionCubit, TransactionState>(
                builder: (context, loadMoreState) {
                  return Center(
                    child: loadMoreState is TransactionLoading
                        ?           _buildLoadMoreShimmer()// Show shimmer effect for initial loading
                  // Show shimmer for load more
                        : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => _fetchFilteredTransactions(loadMore: true),
                      child: const Text('Load More'),
                    ),
                  );
                },
              );
            }

            final transaction = transactions[index];
            return _buildTransactionCard(transaction);
          },
        );
      },
    );
  }

// // Shimmer effect for initial loading
  Widget _buildShimmerEffect() {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: const EdgeInsets.all(16),
      itemCount: 5, // Show 5 placeholder cards
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
            child: Container(
              height: 200, // Approximate height of a transaction card
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),
        );
      },
    );
  }
//
// Shimmer effect for "Load More" loading
  Widget _buildLoadMoreShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        height: 48, // Approximate height of the "Load More" button
        width: 120,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  // Dots animation for "Load More" loading
  Widget _buildLoadMoreDots() {

    return Center(
      child: LoadingAnimationWidget.threeRotatingDots(
        color: AppColors.primary,
        size: 40,
      ),
    );
  }
  // Transaction Card Widget
  Widget _buildTransactionCard(TransactionModel transaction) {
    final stores = (_stockCubit.state is StockLoaded)
        ? (_stockCubit.state as StockLoaded).stores
        : [];

    final fromStore = transaction.type != 'add' && transaction.type != 'out'
        ? stores.firstWhere(
            (store) => store.storeId == transaction.fromStoreId,
            orElse: () => StoreDto(
              storeId: transaction.fromStoreId,
              name: 'Unknown Store',
              createdAt: DateTime.now(),
              createdBy: '',
            ),
          )
        : null;

    final toStore = transaction.type == 'transfer' || transaction.type == 'out'
        ? stores.firstWhere(
            (store) => store.storeId == transaction.toStoreId,
            orElse: () => StoreDto(
              storeId: transaction.toStoreId ?? '',
              name: 'Unknown Store',
              createdAt: DateTime.now(),
              createdBy: '',
            ),
          )
        : null;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Table(
          columnWidths: const {
            0: FixedColumnWidth(120),
            1: FlexColumnWidth(),
          },
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          border: TableBorder(
            verticalInside: BorderSide(
              color: Colors.grey[400]!,
              width: 1.0,
            ),
            horizontalInside: BorderSide(
              color: Colors.grey[300]!,
              width: 0.5,
            ),
            top: BorderSide.none,
            bottom: BorderSide.none,
            left: BorderSide.none,
            right: BorderSide.none,
          ),
          children: [
            _buildTableRow(
                'Type',
                transaction.type == 'billing'
                    ? 'OUT'
                    : transaction.type.toUpperCase(),
                Colors.blue[50]!),
            _buildTableRow(
                'Product ID', transaction.productId, Colors.green[50]!),
            _buildTableRow('Quantity', transaction.quantity.toString(),
                Colors.orange[50]!),
            _buildTableRow(
                'From Store',
                transaction.type == 'add' || transaction.type == 'out'
                    ? '-'
                    : fromStore?.name ?? 'N/A',
                Colors.white),
            _buildTableRow(
              'To Store/Customer',
              transaction.type == 'add'
                  ? '-'
                  : transaction.type == 'transfer' || transaction.type == 'out'
                      ? toStore?.name ?? 'N/A'
                      : transaction.customerId ?? 'N/A',
              Colors.white,
            ),
            _buildTableRow(
                'User',
                '${transaction.userName} (ID: ${transaction.userId})',
                Colors.white),
            _buildTableRow(
                'Timestamp',
                DateFormat('MMM dd, yyyy HH:mm').format(transaction.timestamp),
                Colors.white),
          ],
        ),
      ),
    );
  }

  // Error Card Widget
  Widget _buildErrorCard(String error) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(

          children: [
            Text(
              'Error: $error',
              style: const TextStyle(
                color: Colors.red,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                    horizontal: 24.0, vertical: 12.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              onPressed: () => _stockCubit.fetchStock(''),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  // No Store Card Widget
  Widget _buildNoStoreCard() {
    return const Center(
      child: Card(
        elevation: 4,
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Please select a store',
            style: TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
        ),
      ),
    );
  }

  // No Transactions Card Widget
  Widget _buildNoTransactionsCard() {
    return const Center(
      child: Card(
        elevation: 4,
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'No transactions available',
            style: TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
        ),
      ),
    );
  }

  // Table Row Widget
  TableRow _buildTableRow(String label, String value, Color backgroundColor) {
    return TableRow(
      decoration: BoxDecoration(
        color: backgroundColor,
      ),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 4.0),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 4.0),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: label == 'Type' ||
                      label == 'Product ID' ||
                      label == 'Quantity'
                  ? FontWeight.bold
                  : FontWeight.normal,
              color: label == 'Type' ||
                      label == 'Product ID' ||
                      label == 'Quantity'
                  ? Colors.black87
                  : Colors.grey[600],
            ),
            softWrap: true,
            overflow: TextOverflow.clip,
          ),
        ),
      ],
    );
  }
}
