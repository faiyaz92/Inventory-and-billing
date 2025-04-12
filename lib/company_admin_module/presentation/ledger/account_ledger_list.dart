import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:requirment_gathering_app/company_admin_module/presentation/ledger/account_ledger_cubit.dart';
import 'package:requirment_gathering_app/company_admin_module/presentation/ledger/account_ledger_state.dart';
import 'package:requirment_gathering_app/core_module/service_locator/service_locator.dart';

class LedgerListPage extends StatelessWidget {
  final String companyId; // 🔹 Tenant Company ID
  final String customerCompanyId; // 🔹 Customer ID

  const LedgerListPage({
    Key? key,
    required this.companyId,
    required this.customerCompanyId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
      sl<AccountLedgerCubit>()..fetchLedger(companyId,),
      child: _LedgerListView(
        companyId: companyId,
        customerCompanyId: customerCompanyId,
      ),
    );
  }
}

class _LedgerListView extends StatelessWidget {
  final String companyId;
  final String customerCompanyId;

  const _LedgerListView({
    required this.companyId,
    required this.customerCompanyId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Ledger List")),
      body: BlocBuilder<AccountLedgerCubit, AccountLedgerState>(
        builder: (context, state) {
          if (state is AccountLedgerLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is AccountLedgerError) {
            return Center(child: Text("Error: ${state.message}"));
          }
          if (state is AccountLedgerLoaded) {
            final ledger = state.ledger;
            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: ledger.transactions?.length,
              itemBuilder: (context, index) {
                final txn = ledger.transactions?[index];
                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    title: Text(
                      txn?.type == "Debit"
                          ? "Debited ₹${txn?.amount}"
                          : "Credited ₹${txn?.amount}",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: txn?.type == "Debit" ? Colors.red : Colors.green,
                      ),
                    ),
                    subtitle: Text(
                      txn?.billNumber != null
                          ? "Bill No: ${txn?.billNumber}"
                          : "No Bill Number",
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          txn?.createdAt.toString()??''.split(' ')[0], // Date Only
                          style:
                          TextStyle(fontSize: 14, color: Colors.grey[700]),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            _showDeleteConfirmation(
                                context, companyId, customerCompanyId, txn);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
          return const Center(child: Text("No Ledgers Found"));
        },
      ),
    );
  }

  /// 🔥 **Delete Confirmation Dialog**
  void _showDeleteConfirmation(BuildContext context, String companyId,
      String customerCompanyId, transaction) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Delete Transaction"),
          content:
          const Text("Are you sure you want to delete this transaction?"),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel")),
            TextButton(
              onPressed: () {
                // Call delete function in the cubit
                context
                    .read<AccountLedgerCubit>()
                    .deleteTransaction(companyId,transaction);

                Navigator.pop(context);
              },
              child: const Text("Delete", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}
