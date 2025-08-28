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
import 'package:requirment_gathering_app/core_module/utils/custom_loading_dialog.dart';
import 'package:requirment_gathering_app/super_admin_module/data/user_info.dart';
import 'package:requirment_gathering_app/super_admin_module/utils/user_type.dart';
import 'package:shimmer/shimmer.dart';

@RoutePage()
class TransactionsPage extends StatefulWidget {
  const TransactionsPage({Key? key}) : super(key: key);

  @override
  _TransactionsPageState createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  String? _selectedStoreId;
  String? _selectedType;
  String? _selectedFromStoreId;
  String? _selectedToStoreId;
  String? _selectedUserId;
  String? _selectedCustomerId;
  List<UserInfo> _users = [];
  late TransactionCubit _transactionCubit;
  late StockCubit _stockCubit;
  late UserServices _userServices;
  int _currentPage = 1;
  final int _pageSize = 20;

  @override
  void initState() {
    super.initState();
    _transactionCubit = sl<TransactionCubit>();
    _stockCubit = sl<StockCubit>();
    _userServices = sl<UserServices>();
    _stockCubit.fetchStock('');
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    final users = await _userServices.getUsersFromTenantCompany();
    setState(() {
      _users = users;
      print('Loaded ${_users.length} users: ${_users.map((u) => "${u.userId} (${u.userType})").toList()}');
    });
  }

  void _fetchTransactions({bool loadMore = false}) {
    if (_selectedStoreId != null) {
      _transactionCubit.fetchTransactions(
        storeId: _selectedStoreId!,
        type: _selectedType,
        fromStoreId: _selectedFromStoreId,
        toStoreId: _selectedToStoreId,
        userId: _selectedUserId,
        customerId: _selectedCustomerId,
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
      _selectedType = null;
      _selectedFromStoreId = null;
      _selectedToStoreId = null;
      _selectedUserId = null;
      _selectedCustomerId = null;
      _currentPage = 1;
    });
    _fetchTransactions();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _transactionCubit),
        BlocProvider.value(value: _stockCubit),
      ],
      child: Scaffold(
        appBar: const CustomAppBar(title: 'Transactions'),
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
            child: BlocBuilder<StockCubit, StockState>(
              builder: (context, state) {
                if (state is StockLoading) {
                  return const Center(child: CustomLoadingDialog(message: 'Loading...'));
                }
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: MediaQuery.of(context).size.height -
                          MediaQuery.of(context).padding.top -
                          kToolbarHeight,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildStoreDropdown(),
                        if (_selectedStoreId != null) _buildFilterCard(),
                        _buildTransactionList(),
                        const SizedBox(height: 16),
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

  Widget _buildStoreDropdown() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: BlocBuilder<StockCubit, StockState>(
        builder: (context, stockState) {
          if (stockState is StockError) {
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
                borderSide: BorderSide(color: AppColors.textSecondary.withOpacity(0.3)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.textSecondary.withOpacity(0.3)),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            value: _selectedStoreId,
            hint: const Text('Select a store', style: TextStyle(color: AppColors.textSecondary)),
            items: stores
                .map((store) => DropdownMenuItem<String>(
              value: store.storeId,
              child: Text(store.name, style: const TextStyle(color: AppColors.textPrimary)),
            ))
                .toList(),
            onChanged: (value) {
              setState(() {
                _selectedStoreId = value;
                _selectedType = null;
                _selectedFromStoreId = null;
                _selectedToStoreId = null;
                _selectedUserId = null;
                _selectedCustomerId = null;
                _currentPage = 1;
              });
              if (value != null) {
                _fetchTransactions();
              }
            },
            validator: (value) => value == null ? 'Please select a store' : null,
          );
        },
      ),
    );
  }

  Widget _buildFilterCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: AppColors.textSecondary.withOpacity(0.3), width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Filters',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 12),
              _buildTypeFilter(),
              const SizedBox(height: 12),
              _buildFromStoreFilter(),
              const SizedBox(height: 12),
              _buildToStoreFilter(),
              const SizedBox(height: 12),
              _buildUserFilter(),
              const SizedBox(height: 12),
              _buildCustomerFilter(),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[300],
                    foregroundColor: AppColors.textPrimary,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _clearFilters,
                  child: const Text('Clear Filters', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeFilter() {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: 'Transaction Type',
        labelStyle: const TextStyle(color: AppColors.textSecondary),
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
      value: _selectedType,
      hint: const Text('All Types', style: TextStyle(color: AppColors.textSecondary)),
      items: [
        const DropdownMenuItem<String>(
          value: null,
          child: Text('All Types', style: TextStyle(color: AppColors.textPrimary)),
        ),
        ...['add', 'subtract', 'out', 'received', 'bill', 'return'].map((type) => DropdownMenuItem<String>(
          value: type,
          child: Text(
            type == 'add' ? 'New Stock' : (type == 'bill' ? 'Bill' : (type == 'return' ? 'Return' : type.capitalize())),
            style: const TextStyle(color: AppColors.textPrimary),
          ),
        )),
      ],
      onChanged: (value) {
        setState(() {
          _selectedType = value;
          _currentPage = 1;
        });
        _fetchTransactions();
      },
    );
  }

  Widget _buildFromStoreFilter() {
    return BlocBuilder<StockCubit, StockState>(
      builder: (context, stockState) {
        final stores = (stockState is StockLoaded) ? stockState.stores : [];
        return DropdownButtonFormField<String>(
          decoration: InputDecoration(
            labelText: 'From Store',
            labelStyle: const TextStyle(color: AppColors.textSecondary),
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
          value: _selectedFromStoreId,
          hint: const Text('All From Stores', style: TextStyle(color: AppColors.textSecondary)),
          items: [
            const DropdownMenuItem<String>(
              value: null,
              child: Text('All From Stores', style: TextStyle(color: AppColors.textPrimary)),
            ),
            ...stores.map((store) => DropdownMenuItem<String>(
              value: store.storeId,
              child: Text(store.name, style: const TextStyle(color: AppColors.textPrimary)),
            )),
          ],
          onChanged: (value) {
            setState(() {
              _selectedFromStoreId = value;
              _currentPage = 1;
            });
            _fetchTransactions();
          },
        );
      },
    );
  }

  Widget _buildToStoreFilter() {
    return BlocBuilder<StockCubit, StockState>(
      builder: (context, stockState) {
        final stores = (stockState is StockLoaded) ? stockState.stores : [];
        return DropdownButtonFormField<String>(
          decoration: InputDecoration(
            labelText: 'To Store',
            labelStyle: const TextStyle(color: AppColors.textSecondary),
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
          value: _selectedToStoreId,
          hint: const Text('All To Stores', style: TextStyle(color: AppColors.textSecondary)),
          items: [
            const DropdownMenuItem<String>(
              value: null,
              child: Text('All To Stores', style: TextStyle(color: AppColors.textPrimary)),
            ),
            ...stores.map((store) => DropdownMenuItem<String>(
              value: store.storeId,
              child: Text(store.name, style: const TextStyle(color: AppColors.textPrimary)),
            )),
          ],
          onChanged: (value) {
            setState(() {
              _selectedToStoreId = value;
              _currentPage = 1;
            });
            _fetchTransactions();
          },
        );
      },
    );
  }
  Widget _buildUserFilter() {
    final employeeUsers = _users.where((u) => u.userType == UserType.Employee).toList();
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: 'User',
        labelStyle: const TextStyle(color: AppColors.textSecondary),
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
      value: _selectedUserId,
      hint: const Text('All Users', style: TextStyle(color: AppColors.textSecondary)),
      items: [
        const DropdownMenuItem<String>(
          value: null,
          child: Text('All Users', style: TextStyle(color: AppColors.textPrimary)),
        ),
        ...employeeUsers.map((user) => DropdownMenuItem<String>(
          value: user.userId,
          child: Text(
            user.name ?? user.userName ?? 'Unknown',
            style: const TextStyle(color: AppColors.textPrimary),
            overflow: TextOverflow.ellipsis,
          ),
        )),
      ],
      onChanged: (value) {
        setState(() {
          _selectedUserId = value;
          _currentPage = 1;
        });
        _fetchTransactions();
      },
    );
  }

  Widget _buildCustomerFilter() {
    final customerUsers = _users.where((u) => u.userType == UserType.Customer).toList();
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: 'Customer',
        labelStyle: const TextStyle(color: AppColors.textSecondary),
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
      value: _selectedCustomerId,
      hint: const Text('All Customers', style: TextStyle(color: AppColors.textSecondary)),
      items: [
        const DropdownMenuItem<String>(
          value: null,
          child: Text('All Customers', style: TextStyle(color: AppColors.textPrimary)),
        ),
        ...customerUsers.map((user) => DropdownMenuItem<String>(
          value: user.userId,
          child: Text(
            user.name ?? user.userName ?? 'Unknown',
            style: const TextStyle(color: AppColors.textPrimary),
            overflow: TextOverflow.ellipsis,
          ),
        )),
      ],
      onChanged: (value) {
        setState(() {
          _selectedCustomerId = value;
          _currentPage = 1;
        });
        _fetchTransactions();
      },
    );
  }

  Widget _buildTransactionList() {
    return BlocConsumer<TransactionCubit, TransactionState>(
      listener: (context, state) {
        if (state is TransactionError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error), backgroundColor: AppColors.red),
          );
        }
      },
      builder: (context, state) {
        if (state is TransactionLoading && _currentPage == 1) {
          return _buildShimmerEffect();
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
              return Center(
                child: state is TransactionLoading
                    ? const CustomLoadingDialog(message: 'Loading more...')
                    : ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => _fetchTransactions(loadMore: true),
                  child: const Text('Load More'),
                ),
              );
            }
            final transaction = transactions[index];
            return _buildTransactionCard(transaction);
          },
        );
      },
    );
  }

  Widget _buildTransactionCard(TransactionModel transaction) {
    final stores = (_stockCubit.state is StockLoaded) ? (_stockCubit.state as StockLoaded).stores : [];
    final fromStoreName = stores
        .firstWhere(
          (store) => store.storeId == transaction.fromStoreId,
      orElse: () => StoreDto(
        storeId: transaction.fromStoreId ?? '',
        name: 'Unknown Store',
        createdAt: DateTime.now(),
        createdBy: '',
      ),
    )
        .name;
    final toStoreName = transaction.toStoreId != null
        ? stores
        .firstWhere(
          (store) => store.storeId == transaction.toStoreId,
      orElse: () => StoreDto(
        storeId: transaction.toStoreId ?? '',
        name: 'Unknown Store',
        createdAt: DateTime.now(),
        createdBy: '',
      ),
    )
        .name
        : null;
    final customerDisplay = transaction.customerId != null
        ? _users
        .firstWhere(
          (user) => user.userId == transaction.customerId,
      orElse: () => UserInfo(userId: transaction.customerId, name: 'Unknown Customer'),
    )
        .name ??
        'Unknown Customer'
        : null;
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Table(
          columnWidths: const {
            0: FixedColumnWidth(120),
            1: FlexColumnWidth(),
          },
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          border: TableBorder(
            verticalInside: BorderSide(color: Colors.grey[400]!, width: 1.0),
            horizontalInside: BorderSide(color: Colors.grey[300]!, width: 0.5),
          ),
          children: [
            _buildTableRow(
              'Type',
              transaction.type == 'add'
                  ? 'New Stock'
                  : (transaction.type == 'bill'
                  ? 'Bill'
                  : (transaction.type == 'return' ? 'Return' : transaction.type.capitalize())),
              Colors.blue[50]!,
            ),
            _buildTableRow('Product', transaction.productName, Colors.green[50]!),
            _buildTableRow('Quantity', transaction.quantity.toString(), Colors.orange[50]!),
            _buildTableRow('From Store', transaction.fromStoreId != null ? fromStoreName : '-', Colors.white),
            _buildTableRow(
              'To Store/Customer',
              transaction.type == 'bill' || transaction.type == 'return'
                  ? (customerDisplay ?? '-')
                  : (toStoreName ?? '-'),
              Colors.white,
            ),
            _buildTableRow('User', '${transaction.userName} (ID: ${transaction.userId})', Colors.white),
            _buildTableRow(
              'Timestamp',
              DateFormat('MMM dd, yyyy HH:mm').format(transaction.timestamp),
              Colors.white,
            ),
            if (transaction.remarks != null) _buildTableRow('Remarks', transaction.remarks!, Colors.white),
          ],
        ),
      ),
    );
  }

  TableRow _buildTableRow(String label, String value, Color backgroundColor) {
    return TableRow(
      decoration: BoxDecoration(color: backgroundColor),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 4.0),
          child: Text(
            label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 4.0),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: label == 'Type' || label == 'Product' || label == 'Quantity' ? FontWeight.bold : FontWeight.normal,
              color: label == 'Type' || label == 'Product' || label == 'Quantity' ? Colors.black87 : Colors.grey[600],
            ),
            softWrap: true,
            overflow: TextOverflow.clip,
          ),
        ),
      ],
    );
  }

  Widget _buildShimmerEffect() {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
            child: Container(
              height: 200,
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6)),
            ),
          ),
        );
      },
    );
  }

  Widget _buildErrorCard(String error) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Error: $error',
              style: const TextStyle(color: Colors.red, fontSize: 16),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
              ),
              onPressed: () => _stockCubit.fetchStock(''),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoStoreCard() {
    return const Center(
      child: Card(
        elevation: 4,
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Please select a store',
            style: TextStyle(fontSize: 16, color: Colors.black87),
          ),
        ),
      ),
    );
  }

  Widget _buildNoTransactionsCard() {
    return const Center(
      child: Card(
        elevation: 4,
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'No transactions available',
            style: TextStyle(fontSize: 16, color: AppColors.textPrimary),
          ),
        ),
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }
}