import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:requirment_gathering_app/company_admin_module/data/ledger/transaction_model.dart';
import 'package:requirment_gathering_app/company_admin_module/presentation/ledger/account_ledger_cubit.dart';
import 'package:requirment_gathering_app/company_admin_module/presentation/ledger/account_ledger_state.dart';
import 'package:requirment_gathering_app/core_module/presentation/widget/custom_appbar.dart';
import 'package:requirment_gathering_app/core_module/service_locator/service_locator.dart';
import 'package:requirment_gathering_app/core_module/utils/text_styles.dart';
import 'package:requirment_gathering_app/user_module/data/company.dart';

class AccountLedgerPage extends StatefulWidget {
  final Company company;

  const AccountLedgerPage({Key? key, required this.company}) : super(key: key);

  @override
  _AccountLedgerPageState createState() => _AccountLedgerPageState();
}

class _AccountLedgerPageState extends State<AccountLedgerPage> {
  late AccountLedgerCubit _ledgerCubit;
  final TextEditingController amountController = TextEditingController();
  final TextEditingController billNumberController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _ledgerCubit = sl<AccountLedgerCubit>();
    _ledgerCubit.fetchLedger(widget.company.accountLedgerId!);
  }

  void _addTransaction(bool isDebit) {
    final amount = double.tryParse(amountController.text) ?? 0.0;
    if (amount <= 0) return;

    final transaction = TransactionModel(
      amount: amount,
      type: isDebit ? "Debit" : "Credit",
      billNumber: isDebit ? billNumberController.text : null,
      createdAt: DateTime.now(),
    );

    _ledgerCubit.addTransaction(widget.company.accountLedgerId!, transaction);

    amountController.clear();
    billNumberController.clear();
  }

  void _showTransactionPopup(bool isDebit) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isDebit ? "Add Debit (Udhar)" : "Add Credit (Jama)"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Amount"),
              ),
              if (isDebit)
                TextField(
                  controller: billNumberController,
                  decoration: const InputDecoration(labelText: "Bill Number (Optional)"),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                _addTransaction(isDebit);
                Navigator.pop(context);
              },
              child: const Text("Add"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: "Account Ledger"),
      body: BlocBuilder<AccountLedgerCubit, AccountLedgerState>(
        bloc: _ledgerCubit,
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ✅ **Company Name Display**
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    child: Container(
                      width: double.infinity, // Ensures full width
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Company: ${widget.company.companyName}",
                            style: defaultTextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            "Current Due: ₹${ledger.totalOutstanding}",
                            style: defaultTextStyle(fontSize: 16, color: Colors.red, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // ✅ **Promise Date Picker**
                  ListTile(
                    title: Text(
                      ledger.promiseDate == null
                          ? "Select Promise Date"
                          : "Promise Date: ${ledger.promiseDate!.toString().split(' ')[0]}",
                    ),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        // _ledgerCubit.updatePromiseDate(widget.company.accountLedgerId!, picked);
                      }
                    },
                  ),
                  const SizedBox(height: 20),

                  // ✅ **Credit & Debit Buttons**
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () => _showTransactionPopup(false),
                        child: const Text("Credit (Jama)"),
                      ),
                      ElevatedButton(
                        onPressed: () => _showTransactionPopup(true),
                        child: const Text("Debit (Udhar)"),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ✅ **Transactions List**
                  Expanded(
                    child: ListView.builder(
                      itemCount: ledger.transactions?.length,
                      itemBuilder: (context, index) {
                        final txn = ledger.transactions?[index];
                        return Card(
                          elevation: 3,
                          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8), // Proper margin
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween, // Ensures spacing
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      txn?.type == "Debit"
                                          ? "Udhar: ₹${txn?.amount}"
                                          : "Jama: ₹${txn?.amount}",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: txn?.type == "Debit" ? Colors.red : Colors.green,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      txn?.billNumber != null ? "Bill: ${txn?.billNumber}" : "No Bill Number",
                                      style: defaultTextStyle(fontSize: 14, color: Colors.grey),
                                    ),
                                  ],
                                ),
                                Text(
                                  txn?.createdAt.toString().split(' ')[0] ?? '',
                                  style: defaultTextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          ),
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
