import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:requirment_gathering_app/company_admin_module/presentation/inventory/stock_cubit.dart';
import 'package:requirment_gathering_app/company_admin_module/presentation/inventory/transaction_cubit.dart';
import 'package:requirment_gathering_app/company_admin_module/repositories/stock_repository.dart';
import 'package:requirment_gathering_app/core_module/presentation/widget/custom_appbar.dart';
import 'package:requirment_gathering_app/core_module/presentation/widget/custom_drop_down_widget.dart';
import 'package:requirment_gathering_app/core_module/service_locator/service_locator.dart';
import 'package:requirment_gathering_app/core_module/utils/AppColor.dart';
import 'package:intl/intl.dart';

@RoutePage()
class TransactionsPage extends StatefulWidget {
  const TransactionsPage({Key? key}) : super(key: key);

  @override
  _TransactionsPageState createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  String? _selectedStoreId;
  late TransactionCubit _transactionCubit;
  late StockCubit _stockCubit;

  @override
  void initState() {
    _transactionCubit = sl<TransactionCubit>();
    _stockCubit = sl<StockCubit>()..fetchStock('');
    super.initState();
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
          height: MediaQuery.of(context).size.height,
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
            child: Column(
              children: [
                // Store Dropdown
                BlocBuilder<StockCubit, StockState>(
                  builder: (context, stockState) {
                    if (stockState is StockLoading) {
                      return const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    } else if (stockState is StockError) {
                      return Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Center(
                          child: Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                children: [
                                  Text(
                                    'Error: ${stockState.error}',
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
                                        horizontal: 24.0,
                                        vertical: 12.0,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8.0),
                                      ),
                                      textStyle: const TextStyle(
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    onPressed: () => _stockCubit.fetchStock(''),
                                    child: const Text('Retry'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }

                    final stores = (stockState is StockLoaded) ? stockState.stores : [];

                    return Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: CustomDropdown(
                        labelText: 'Select Store',
                        selectedValue: _selectedStoreId,
                        items: stores.map((store) => store.storeId).toList(),
                        onChanged: (value) {
                          setState(() => _selectedStoreId = value);
                          if (value != null) {
                            _transactionCubit.fetchTransactions(value);
                          }
                        },
                        validator: (value) => value == null ? 'Please select a store' : null,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
                // Transaction List
                Expanded(
                  child: BlocConsumer<TransactionCubit, TransactionState>(
                    listener: (context, state) {
                      if (state is TransactionError) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(state.error), backgroundColor: AppColors.red),
                        );
                      }
                    },
                    builder: (context, state) {
                      if (state is TransactionLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final transactions = (state is TransactionLoaded) ? state.transactions : [];
                      final stores = (context.read<StockCubit>().state is StockLoaded)
                          ? (context.read<StockCubit>().state as StockLoaded).stores
                          : [];

                      return _selectedStoreId == null
                          ? Center(
                        child: Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Padding(
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
                      )
                          : transactions.isEmpty
                          ? Center(
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
                      )
                          : ListView.separated(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        itemCount: transactions.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
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
                                  TableRow(
                                    decoration: BoxDecoration(
                                      color: Colors.blue[50], // Highlight Type
                                    ),
                                    children: [
                                      const Padding(
                                        padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 4.0),
                                        child: Text(
                                          'Type',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 4.0),
                                        child: Text(
                                          transaction.type == 'billing'
                                              ? 'OUT'
                                              : transaction.type.toUpperCase(),
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                          softWrap: true,
                                          overflow: TextOverflow.clip,
                                        ),
                                      ),
                                    ],
                                  ),
                                  TableRow(
                                    decoration: BoxDecoration(
                                      color: Colors.green[50], // Highlight Product ID
                                    ),
                                    children: [
                                      const Padding(
                                        padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 4.0),
                                        child: Text(
                                          'Product ID',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 4.0),
                                        child: Text(
                                          transaction.productId,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                          softWrap: true,
                                          overflow: TextOverflow.clip,
                                        ),
                                      ),
                                    ],
                                  ),
                                  TableRow(
                                    decoration: BoxDecoration(
                                      color: Colors.orange[50], // Highlight Quantity
                                    ),
                                    children: [
                                      const Padding(
                                        padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 4.0),
                                        child: Text(
                                          'Quantity',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 4.0),
                                        child: Text(
                                          transaction.quantity.toString(),
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                          softWrap: true,
                                          overflow: TextOverflow.clip,
                                        ),
                                      ),
                                    ],
                                  ),
                                  TableRow(
                                    decoration: const BoxDecoration(
                                      color: Colors.white, // Normal
                                    ),
                                    children: [
                                      const Padding(
                                        padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 4.0),
                                        child: Text(
                                          'From Store',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 4.0),
                                        child: Text(
                                          transaction.type == 'add' || transaction.type == 'out'
                                              ? '-'
                                              : fromStore?.name ?? 'N/A',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[600],
                                          ),
                                          softWrap: true,
                                          overflow: TextOverflow.clip,
                                        ),
                                      ),
                                    ],
                                  ),
                                  TableRow(
                                    decoration: const BoxDecoration(
                                      color: Colors.white, // Normal
                                    ),
                                    children: [
                                      const Padding(
                                        padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 4.0),
                                        child: Text(
                                          'To Store/Customer',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 4.0),
                                        child: Text(
                                          transaction.type == 'add'
                                              ? '-'
                                              : transaction.type == 'transfer' || transaction.type == 'out'
                                              ? toStore?.name ?? 'N/A'
                                              : transaction.customerId ?? 'N/A',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[600],
                                          ),
                                          softWrap: true,
                                          overflow: TextOverflow.clip,
                                        ),
                                      ),
                                    ],
                                  ),
                                  TableRow(
                                    decoration: const BoxDecoration(
                                      color: Colors.white, // Normal
                                    ),
                                    children: [
                                      const Padding(
                                        padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 4.0),
                                        child: Text(
                                          'User',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 4.0),
                                        child: Text(
                                          '${transaction.userName} (ID: ${transaction.userId})',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[600],
                                          ),
                                          softWrap: true,
                                          overflow: TextOverflow.clip,
                                        ),
                                      ),
                                    ],
                                  ),
                                  TableRow(
                                    decoration: const BoxDecoration(
                                      color: Colors.white, // Normal
                                    ),
                                    children: [
                                      const Padding(
                                        padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 4.0),
                                        child: Text(
                                          'Timestamp',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 4.0),
                                        child: Text(
                                          DateFormat('MMM dd, yyyy HH:mm').format(transaction.timestamp),
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[600],
                                          ),
                                          softWrap: true,
                                          overflow: TextOverflow.clip,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}