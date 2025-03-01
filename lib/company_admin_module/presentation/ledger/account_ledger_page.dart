import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:requirment_gathering_app/company_admin_module/data/transaction_model.dart';
import 'package:requirment_gathering_app/company_admin_module/presentation/ledger/account_ledger_cubit.dart';
import 'package:requirment_gathering_app/company_admin_module/presentation/ledger/account_ledger_state.dart';
import 'package:requirment_gathering_app/core_module/service_locator/service_locator.dart';

class AccountLedgerPage extends StatelessWidget {
  final String companyId;
  final String customerCompanyId;

  const AccountLedgerPage({
    Key? key,
    required this.companyId,
    required this.customerCompanyId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          sl<AccountLedgerCubit>()..fetchLedger(companyId, customerCompanyId),
      child: _AccountLedgerView(
          companyId: companyId, customerCompanyId: customerCompanyId),
    );
  }
}

class _AccountLedgerView extends StatelessWidget {
  final String companyId;
  final String customerCompanyId;

  _AccountLedgerView(
      {required this.companyId, required this.customerCompanyId});

  final TextEditingController amountController = TextEditingController();
  final TextEditingController billNumberController = TextEditingController();

  void _addTransaction(BuildContext context, bool isDebit) {
    final amount = double.tryParse(amountController.text) ?? 0.0;
    if (amount <= 0) return;

    final transaction = TransactionModel(
      amount: amount,
      type: isDebit ? "Debit" : "Credit",
      billNumber: isDebit ? billNumberController.text : null,
      createdAt: DateTime.now(),
    );

    context
        .read<AccountLedgerCubit>()
        .addTransaction(companyId, customerCompanyId, transaction);
    amountController.clear();
    billNumberController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Account Ledger")),
      body: BlocBuilder<AccountLedgerCubit, AccountLedgerState>(
        builder: (context, state) {
          if (state is AccountLedgerLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is AccountLedgerError) {
            return Center(child: Text(state.message));
          }
          if (state is AccountLedgerLoaded) {
            final ledger = state.ledger;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text("Outstanding: ₹${ledger.totalOutstanding}",
                      style:
                          const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  TextField(
                      controller: amountController,
                      decoration: const InputDecoration(labelText: "Amount")),
                  TextField(
                      controller: billNumberController,
                      decoration: const InputDecoration(labelText: "Bill Number")),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                          onPressed: () => _addTransaction(context, true),
                          child: const Text("Debit (Udhar)")),
                      ElevatedButton(
                          onPressed: () => _addTransaction(context, false),
                          child: const Text("Credit (Jama)")),
                    ],
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: ledger.transactions.length,
                      itemBuilder: (context, index) {
                        final txn = ledger.transactions[index];
                        return ListTile(
                          title: Text(txn.type == "Debit"
                              ? "Udhar: ₹${txn.amount}"
                              : "Jama: ₹${txn.amount}"),
                          subtitle: txn.billNumber != null
                              ? Text("Bill: ${txn.billNumber}")
                              : null,
                          trailing: Text("txn.date.toString()"),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          }
          return Container();
        },
      ),
    );
  }
}
