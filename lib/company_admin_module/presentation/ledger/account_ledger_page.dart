import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:requirment_gathering_app/company_admin_module/data/ledger/transaction_model.dart';
import 'package:requirment_gathering_app/company_admin_module/presentation/ledger/account_ledger_cubit.dart';
import 'package:requirment_gathering_app/company_admin_module/presentation/ledger/account_ledger_state.dart';
import 'package:requirment_gathering_app/core_module/presentation/widget/custom_appbar.dart';
import 'package:requirment_gathering_app/core_module/service_locator/service_locator.dart';
import 'package:requirment_gathering_app/core_module/utils/text_styles.dart';
import 'package:requirment_gathering_app/user_module/data/partner.dart';

class AccountLedgerPage extends StatefulWidget {
  final Partner company;

  const AccountLedgerPage({Key? key, required this.company}) : super(key: key);

  @override
  _AccountLedgerPageState createState() => _AccountLedgerPageState();
}

class _AccountLedgerPageState extends State<AccountLedgerPage> {
  late AccountLedgerCubit _ledgerCubit;
  final TextEditingController amountController = TextEditingController();
  final TextEditingController billNumberController = TextEditingController();
  final TextEditingController remarksController = TextEditingController();
  bool _isPopupOpen = false; // Track if popup is open

  @override
  void initState() {
    super.initState();
    _ledgerCubit = sl<AccountLedgerCubit>();
    _ledgerCubit.fetchLedger(widget.company.accountLedgerId!);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => _ledgerCubit,
      child: Scaffold(
        appBar: const CustomAppBar(title: "Account Ledger"),
        body: Column(
          children: [
            // Listener for SnackBar and Popup
            BlocListener<AccountLedgerCubit, AccountLedgerState>(
              listenWhen: (previous, current) =>
              (current is TransactionPopupOpened && current.isInitialOpen && !_isPopupOpen) ||
                  current is TransactionAddSuccess ||
                  current is TransactionAddFailed,
              listener: (context, state) {
                if (state is TransactionAddSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.message ?? '')),
                  );
                }
                if (state is TransactionAddFailed) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.message ?? '')),
                  );
                }
                if (state is TransactionPopupOpened && state.isInitialOpen && !_isPopupOpen) {
                  _isPopupOpen = true; // Mark popup as open
                  _showTransactionPopup(context, state);
                }
              },
              child: Container(), // Empty child as listener-only
            ),
            // Main Ledger UI
            Expanded(
              child: BlocBuilder<AccountLedgerCubit, AccountLedgerState>(
                buildWhen: (previous, current) =>
                current is AccountLedgerLoading ||
                    current is AccountLedgerLoaded ||
                    current is AccountLedgerError,
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
                          Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            child: Container(
                              width: double.infinity,
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
                                // TODO: Implement updatePromiseDate
                              }
                            },
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ElevatedButton(
                                onPressed: () => context.read<AccountLedgerCubit>().openTransactionPopup(false, widget.company.companyType ?? ''),
                                child: const Text("Credit (Jama)"),
                              ),
                              ElevatedButton(
                                onPressed: () => context.read<AccountLedgerCubit>().openTransactionPopup(true, widget.company.companyType ?? ''),
                                child: const Text("Debit (Udhar)"),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Expanded(
                            child: ListView.builder(
                              itemCount: ledger.transactions?.length ?? 0,
                              itemBuilder: (context, index) {
                                final txn = ledger.transactions?[index];
                                return Card(
                                  elevation: 3,
                                  margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                            if (txn?.purpose != null)
                                              Text(
                                                "Purpose: ${txn?.purpose}",
                                                style: defaultTextStyle(fontSize: 14, color: Colors.grey),
                                              ),
                                            if (txn?.typeOfPurpose != null)
                                              Text(
                                                "Type: ${txn?.typeOfPurpose}",
                                                style: defaultTextStyle(fontSize: 14, color: Colors.grey),
                                              ),
                                            if (txn?.remarks != null)
                                              Text(
                                                "Remarks: ${txn?.remarks}",
                                                style: defaultTextStyle(fontSize: 14, color: Colors.grey),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
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
            ),
          ],
        ),
      ),
    );
  }

  void _showTransactionPopup(BuildContext context, TransactionPopupOpened state) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return BlocProvider.value(
          value: _ledgerCubit,
          child: AlertDialog(
            title: Text(state.isDebit ? "Add Debit (Udhar)" : "Add Credit (Jama)"),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: "Amount"),
                  ),
                  if (state.isDebit) ...[
                    TextField(
                      controller: billNumberController,
                      decoration: const InputDecoration(labelText: "Bill Number (Optional)"),
                    ),
                    if (state.companyType == "Site") ...[
                      // Purpose Dropdown
                      // Purpose Dropdown
                      // Purpose Dropdown
                      BlocBuilder<AccountLedgerCubit, AccountLedgerState>(
                        key: const ValueKey('purpose_dropdown'),
                        buildWhen: (previous, current) =>
                        current is TransactionPopupOpened &&
                            previous is TransactionPopupOpened &&
                            current.selectedPurpose != previous.selectedPurpose,
                        builder: (context, popupState) {
                          if (popupState is TransactionPopupOpened) {
                            final items = (popupState.purposeTypeMap.isNotEmpty
                                ? popupState.purposeTypeMap.keys.map((purpose) {
                              return DropdownMenuItem(
                                value: purpose,
                                child: Text(purpose),
                              );
                            }).toList()
                                : <DropdownMenuItem<String>>[]);
                            return DropdownButtonFormField<String>(
                              key: const ValueKey('purpose_dropdown_field'),
                              value: popupState.selectedPurpose,
                              decoration: const InputDecoration(labelText: "Purpose"),
                              items: items,
                              onChanged: items.isNotEmpty
                                  ? (value) => context.read<AccountLedgerCubit>().updatePurposeSelection(value)
                                  : null,
                              hint: items.isEmpty ? const Text("No purposes available") : null,
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                      BlocBuilder<AccountLedgerCubit, AccountLedgerState>(
                        key: const ValueKey('type_dropdown'),
                        buildWhen: (previous, current) =>
                        current is TransactionPopupOpened &&
                            previous is TransactionPopupOpened &&
                            (current.selectedType != previous.selectedType ||
                                current.selectedPurpose != previous.selectedPurpose),
                        builder: (context, popupState) {
                          if (popupState is TransactionPopupOpened) {
                            final items = (popupState.selectedPurpose != null &&
                                popupState.purposeTypeMap.containsKey(popupState.selectedPurpose) &&
                                popupState.purposeTypeMap[popupState.selectedPurpose]!.isNotEmpty
                                ? popupState.purposeTypeMap[popupState.selectedPurpose]!.map((type) {
                              return DropdownMenuItem(
                                value: type,
                                child: Text(type),
                              );
                            }).toList()
                                : <DropdownMenuItem<String>>[]);
                            return DropdownButtonFormField<String>(
                              key: const ValueKey('type_dropdown_field'),
                              value: popupState.selectedType,
                              decoration: const InputDecoration(labelText: "Type"),
                              items: items,
                              onChanged: items.isNotEmpty
                                  ? (value) => context.read<AccountLedgerCubit>().updateTypeSelection(value)
                                  : null,
                              hint: items.isEmpty ? const Text("No types available") : null,
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),                      TextField(
                        controller: remarksController,
                        maxLength: 500,
                        decoration: const InputDecoration(labelText: "Remarks (Optional)"),
                      ),
                    ],
                  ],
                  // Error Message
                  BlocBuilder<AccountLedgerCubit, AccountLedgerState>(
                    buildWhen: (previous, current) =>
                    current is TransactionPopupOpened &&
                        previous is TransactionPopupOpened &&
                        current.errorMessage != previous.errorMessage,
                    builder: (context, popupState) {
                      if (popupState is TransactionPopupOpened && popupState.errorMessage != null) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            popupState.errorMessage!,
                            style: const TextStyle(color: Colors.red, fontSize: 12),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  _isPopupOpen = false;
                  Navigator.pop(dialogContext);
                },
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () {
                  final currentState = context.read<AccountLedgerCubit>().state;
                  String? selectedType;
                  String? selectedPurpose;
                  if (currentState is TransactionPopupOpened) {
                    selectedType = currentState.selectedType;
                    selectedPurpose = currentState.selectedPurpose;
                  }
                  context.read<AccountLedgerCubit>().addTransaction(
                    ledgerId: widget.company.accountLedgerId!,
                    amount: double.tryParse(amountController.text) ?? 0.0,
                    type: state.isDebit ? "Debit" : "Credit",
                    billNumber: billNumberController.text,
                    purpose: state.companyType == "Site" ? selectedPurpose : null,
                    typeOfPurpose: state.companyType == "Site" ? selectedType : null,
                    remarks: state.companyType == "Site" ? remarksController.text : null,
                  );
                  amountController.clear();
                  billNumberController.clear();
                  remarksController.clear();
                  _isPopupOpen = false;
                  Navigator.pop(dialogContext);
                },
                child: const Text("Add"),
              ),            ],
          ),
        );
      },
    );
  }
}