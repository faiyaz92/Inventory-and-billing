import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:requirment_gathering_app/company_admin_module/presentation/inventory/stock_cubit.dart';
import 'package:requirment_gathering_app/company_admin_module/presentation/inventory/transaction_cubit.dart';
import 'package:requirment_gathering_app/core_module/presentation/widget/custom_drop_down_widget.dart';
import 'package:requirment_gathering_app/core_module/utils/AppColor.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:requirment_gathering_app/core_module/presentation/widget/custom_appbar.dart';
import 'package:requirment_gathering_app/core_module/service_locator/service_locator.dart';

@RoutePage()
class SalesReportPage extends StatefulWidget {
  const SalesReportPage({Key? key}) : super(key: key);

  @override
  _SalesReportPageState createState() => _SalesReportPageState();
}

class _SalesReportPageState extends State<SalesReportPage> {
  String? _selectedStoreId;
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<TransactionCubit>(),
      child: Scaffold(
        appBar: CustomAppBar(title: 'Sales Report'),
        body: BlocConsumer<TransactionCubit, TransactionState>(
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
            final stores = context.read<StockCubit>().state is StockLoaded
                ? (context.read<StockCubit>().state as StockLoaded).stores
                : [];
            final transactions = (state is TransactionLoaded)
                ? state.transactions.where((t) => t.type == 'billing').toList()
                : [];
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: CustomDropdown<String>(
                    labelText: 'Select Store',
                    selectedValue: _selectedStoreId,
                    items: stores.map((store) => store.userId).toList() as List<String>,
                    onChanged: (value) {
                      setState(() => _selectedStoreId = value);
                      if (value != null) {
                        // context.read<TransactionCubit>().fetchTransactions(value);
                      }
                    },
                  ),
                ),
                TableCalendar(
                  firstDay: DateTime.utc(2000, 1, 1),
                  lastDay: DateTime.now(),
                  focusedDay: _selectedDate,
                  selectedDayPredicate: (day) => isSameDay(day, _selectedDate),
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() => _selectedDate = selectedDay);
                  },
                ),
                Expanded(
                  child: _selectedStoreId == null
                      ? const Center(child: Text('Please select a store'))
                      : transactions.isEmpty
                      ? const Center(child: Text('No sales available'))
                      : ListView.builder(
                    itemCount: transactions.length,
                    itemBuilder: (context, index) {
                      final transaction = transactions[index];
                      return ListTile(
                        title: Text('Product ID: ${transaction.productId}'),
                        subtitle: Text('Quantity: ${transaction.quantity}'),
                        trailing: Text('Customer ID: ${transaction.customerId ?? 'N/A'}'),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}