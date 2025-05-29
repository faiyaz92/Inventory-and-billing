import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:requirment_gathering_app/company_admin_module/presentation/inventory/stock_cubit.dart';
import 'package:requirment_gathering_app/company_admin_module/presentation/inventory/transaction_cubit.dart';
import 'package:requirment_gathering_app/company_admin_module/repositories/stock_repository.dart';
import 'package:requirment_gathering_app/company_admin_module/service/user_services.dart';
import 'package:requirment_gathering_app/core_module/presentation/widget/custom_appbar.dart';
import 'package:requirment_gathering_app/core_module/service_locator/service_locator.dart';
import 'package:requirment_gathering_app/core_module/utils/AppColor.dart';
import 'package:requirment_gathering_app/super_admin_module/data/user_info.dart';
import 'package:intl/intl.dart';

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
  String? _selectedType; // New: for type filter
  DateTime? _startDate;
  DateTime? _endDate;
  late TransactionCubit _transactionCubit;
  late StockCubit _stockCubit;
  late UserServices _userServices;
  final ScrollController _scrollController = ScrollController();
  int _currentPage = 1;
  final int _pageSize = 20;
  List<UserInfo> _users = [];

  @override
  void initState() {
    super.initState();
    _transactionCubit = sl<TransactionCubit>();
    _stockCubit = sl<StockCubit>()..fetchStock('');
    _userServices = sl<UserServices>();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 100 && _selectedStoreId != null) {
        _fetchFilteredTransactions(loadMore: true);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchUsersForStore(String storeId) async {
    try {
      final users = await _userServices.getUsersFromTenantCompany(storeId: storeId);
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
        type: _selectedType, // New: pass type filter
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
      _selectedType = null; // New: reset type
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
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Store Selection
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: BlocBuilder<StockCubit, StockState>(
                      builder: (context, stockState) {
                        if (stockState is StockLoading) {
                          return const Center(child: CircularProgressIndicator());
                        } else if (stockState is StockError) {
                          return _buildErrorCard(context, stockState.error);
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
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                              _selectedType = null; // New: reset type
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
                          validator: (value) => value == null ? 'Please select a store' : null,
                        );
                      },
                    ),
                  ),
                  // Filters Card
                  if (_selectedStoreId != null)
                    Padding(
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
                              // Type Filter (New)
                              DropdownButtonFormField<String>(
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
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                                  ...['add', 'out', 'transfer', 'billing'].map((type) => DropdownMenuItem<String>(
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
                              ),
                              const SizedBox(height: 12),
                              // User Filter
                              DropdownButtonFormField<String>(
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
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                              ),
                              const SizedBox(height: 12),
                              // From Store Filter
                              DropdownButtonFormField<String>(
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
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                              ),
                              const SizedBox(height: 12),
                              // To Store Filter
                              DropdownButtonFormField<String>(
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
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                              ),
                              const SizedBox(height: 12),
                              // Date Range Filter
                              SizedBox(
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
                              ),
                              const SizedBox(height: 12),
                              // Clear Filter Button (New)
                              SizedBox(
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
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  // Transaction List
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.6, // 60% of screen height
                    child: BlocConsumer<TransactionCubit, TransactionState>(
                      listener: (context, state) {
                        if (state is TransactionError) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(state.error), backgroundColor: AppColors.red),
                          );
                        }
                      },
                      builder: (context, state) {
                        if (state is TransactionLoading && _currentPage == 1) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        final transactions = (state is TransactionLoaded) ? state.transactions : [];
                        final hasMore = (state is TransactionLoaded) ? state.hasMore : false;
                        final stores = (_stockCubit.state is StockLoaded) ? (_stockCubit.state as StockLoaded).stores : [];

                        if (_selectedStoreId == null) {
                          return _buildNoStoreCard();
                        }

                        if (transactions.isEmpty) {
                          return _buildNoTransactionsCard();
                        }

                        return ListView.separated(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(16),
                          itemCount: transactions.length + (hasMore ? 1 : 0),
                          separatorBuilder: (context, index) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            if (index == transactions.length && hasMore) {
                              return const Center(child: CircularProgressIndicator());
                            }

                            final transaction = transactions[index];
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
                                    _buildTableRow('Type', transaction.type == 'billing' ? 'OUT' : transaction.type.toUpperCase(), Colors.blue[50]!),
                                    _buildTableRow('Product ID', transaction.productId, Colors.green[50]!),
                                    _buildTableRow('Quantity', transaction.quantity.toString(), Colors.orange[50]!),
                                    _buildTableRow('From Store', transaction.type == 'add' || transaction.type != 'out' ? '-' : fromStore?.name ?? 'N/A', Colors.white),
                                    _buildTableRow(
                                        'To Store/Customer',
                                        transaction.type == 'add'
                                            ? '-'
                                            : transaction.type == 'transfer' || transaction.type == 'out'
                                            ? toStore?.name ?? 'N/A'
                                            : transaction.customerId ?? 'N/A',
                                        Colors.white),
                                    _buildTableRow('User', '${transaction.userName} (ID: ${transaction.userId})', Colors.white),
                                    _buildTableRow('Timestamp', DateFormat('MMM dd, yyyy HH:mm').format(transaction.timestamp), Colors.white),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16), // Bottom padding
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorCard(BuildContext context, String error) {
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
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
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

  Widget _buildNoTransactionsCard() {
    return Center(
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Padding(
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
              fontWeight: label == 'Type' || label == 'Product ID' || label == 'Quantity' ? FontWeight.bold : FontWeight.normal,
              color: label == 'Type' || label == 'Product ID' || label == 'Quantity' ? Colors.black87 : Colors.grey[600],
            ),
            softWrap: true,
            overflow: TextOverflow.clip,
          ),
        ),
      ],
    );
  }
}