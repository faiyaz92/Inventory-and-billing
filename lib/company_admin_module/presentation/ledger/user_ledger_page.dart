import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:requirment_gathering_app/company_admin_module/data/ledger/account_ledger_model.dart';
import 'package:requirment_gathering_app/company_admin_module/presentation/ledger/user_ledger_cubit.dart';
import 'package:requirment_gathering_app/company_admin_module/presentation/ledger/account_ledger_state.dart';
import 'package:requirment_gathering_app/core_module/presentation/widget/custom_appbar.dart';
import 'package:requirment_gathering_app/core_module/service_locator/service_locator.dart';
import 'package:requirment_gathering_app/core_module/utils/text_styles.dart';
import 'package:requirment_gathering_app/super_admin_module/data/user_info.dart';
import 'package:requirment_gathering_app/super_admin_module/utils/user_type.dart';

@RoutePage()
class UserLedgerPage extends StatefulWidget {
  final UserInfo user;

  const UserLedgerPage({Key? key, required this.user}) : super(key: key);

  @override
  _UserLedgerPageState createState() => _UserLedgerPageState();
}

class _UserLedgerPageState extends State<UserLedgerPage> {
  late UserLedgerCubit _ledgerCubit;
  final TextEditingController amountController = TextEditingController();
  final TextEditingController billNumberController = TextEditingController();
  final TextEditingController remarksController = TextEditingController();
  bool _isPopupOpen = false;

  @override
  void initState() {
    super.initState();
    _ledgerCubit = sl<UserLedgerCubit>();
    _ledgerCubit.fetchLedger(widget.user.accountLedgerId, widget.user.userType);
  }

  @override
  void dispose() {
    amountController.dispose();
    billNumberController.dispose();
    remarksController.dispose();
    _ledgerCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => _ledgerCubit,
      child: Scaffold(
        appBar: const CustomAppBar(title: "User Ledger"),
        body: Column(
          children: [
            BlocListener<UserLedgerCubit, AccountLedgerState>(
              listenWhen: (previous, current) =>
              (current is TransactionPopupOpened &&
                  current.isInitialOpen &&
                  !_isPopupOpen) ||
                  current is TransactionSuccess ||
                  current is TransactionAddFailed,
              listener: (context, state) {
                if (state is TransactionSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.message)),
                  );
                }
                if (state is TransactionAddFailed) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.message)),
                  );
                }
                if (state is TransactionPopupOpened &&
                    state.isInitialOpen &&
                    !_isPopupOpen) {
                  _isPopupOpen = true;
                  _showTransactionPopup(context, state);
                }
              },
              child: const SizedBox.shrink(),
            ),
            Expanded(
              child: BlocBuilder<UserLedgerCubit, AccountLedgerState>(
                buildWhen: (previous, current) =>
                current is AccountLedgerFetching ||
                    current is AccountLedgerUpdated ||
                    current is AccountLedgerError,
                builder: (context, state) {
                  if (state is AccountLedgerFetching) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state is AccountLedgerError) {
                    return Center(child: Text(state.message));
                  }
                  if (state is AccountLedgerUpdated) {
                    final ledger = state.ledger;
                    return CustomScrollView(
                      slivers: [
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildCard(context, ledger),
                                const SizedBox(height: 10),
                                _buildPromiseDateTile(ledger),
                                const SizedBox(height: 20),
                                _buildTransactionButtons(context),
                                const SizedBox(height: 20),
                              ],
                            ),
                          ),
                        ),
                        _buildTransactionList(ledger),
                      ],
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context, AccountLedger ledger) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildUserDetails(),
            const SizedBox(height: 10),
            _buildBalanceTable(ledger),
          ],
        ),
      ),
    );
  }

  Widget _buildUserDetails() {
    return Table(
      border: TableBorder.all(color: Colors.grey.shade300),
      columnWidths: const {
        0: FlexColumnWidth(2),
        1: FlexColumnWidth(3),
      },
      children: [
        TableRow(
          decoration: BoxDecoration(color: Colors.grey.shade100),
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "User Details",
                style: defaultTextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(""),
            ),
          ],
        ),
        TableRow(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Name",
                style: defaultTextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                widget.user.name ?? "N/A",
                style: defaultTextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
        TableRow(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Email",
                style: defaultTextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                widget.user.email ?? "N/A",
                style: defaultTextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
        TableRow(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "User Type",
                style: defaultTextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                widget.user.userType?.name ?? "customer",
                style: defaultTextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
        TableRow(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Daily Wage",
                style: defaultTextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                widget.user.dailyWage != null ? "₹${widget.user.dailyWage!.toStringAsFixed(2)}" : "N/A",
                style: defaultTextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBalanceTable(AccountLedger ledger) {
    final currentDue = ledger.currentDue ?? 0.0;
    final isDuePositive = currentDue >= 0;
    return Table(
      border: TableBorder.all(color: Colors.grey.shade300),
      columnWidths: const {
        0: FlexColumnWidth(3),
        1: FlexColumnWidth(2),
      },
      children: [
        TableRow(
          decoration: BoxDecoration(color: Colors.grey.shade100),
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                isDuePositive ? "Current Due" : "Current Payable",
                style: defaultTextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                (currentDue.abs()).toStringAsFixed(2),
                style: defaultTextStyle(fontSize: 16, color: Colors.red),
                textAlign: TextAlign.right,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPromiseDateTile(AccountLedger ledger) {
    return ListTile(
      title: Text(
        ledger.promiseDate == null
            ? "Select Promise Date"
            : "Promise Date: ${ledger.promiseDate!.toString().split(' ')[0]}",
        style: defaultTextStyle(fontSize: 16),
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
    );
  }

  Widget _buildTransactionButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton(
          onPressed: () => context.read<UserLedgerCubit>().openTransactionPopup(false),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: const Text("Credit"),
        ),
        ElevatedButton(
          onPressed: () => context.read<UserLedgerCubit>().openTransactionPopup(true),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: const Text("Debit"),
        ),
      ],
    );
  }

  SliverList _buildTransactionList(AccountLedger ledger) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
            (context, index) {
          final txn = ledger.transactions?[index];
          if (txn == null) return const SizedBox.shrink();
          return Card(
            elevation: 2,
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey.shade200),
            ),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            txn.type == "Debit"
                                ? "Debit: ₹${txn.amount.toStringAsFixed(2)}"
                                : "Credit: ₹${txn.amount.toStringAsFixed(2)}",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: txn.type == "Debit" ? Colors.red : Colors.green,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            txn.billNumber != null
                                ? "Bill: ${txn.billNumber}"
                                : "No Bill Number",
                            style: defaultTextStyle(
                                fontSize: 14, color: Colors.grey.shade600),
                          ),
                          if (txn.purpose != null)
                            Text(
                              "Purpose: ${txn.purpose}",
                              style: defaultTextStyle(
                                  fontSize: 14, color: Colors.grey.shade600),
                            ),
                          if (txn.typeOfPurpose != null)
                            Text(
                              "Type: ${txn.typeOfPurpose}",
                              style: defaultTextStyle(
                                  fontSize: 14, color: Colors.grey.shade600),
                            ),
                          if (txn.remarks != null)
                            Text(
                              "Remarks: ${txn.remarks}",
                              style: defaultTextStyle(
                                  fontSize: 14, color: Colors.grey.shade600),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        txn.createdAt.toString().split(' ')[0],
                        style: defaultTextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
        childCount: ledger.transactions?.length ?? 0,
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
            title: Text(state.isDebit ? "Add Debit" : "Add Credit"),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: amountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(labelText: "Amount"),
                  ),
                  TextField(
                    controller: billNumberController,
                    decoration: const InputDecoration(labelText: "Bill Number (Optional)"),
                  ),
                  if (state.isDebit) ...[
                    BlocBuilder<UserLedgerCubit, AccountLedgerState>(
                      buildWhen: (previous, current) =>
                      current is TransactionPopupOpened &&
                          previous is TransactionPopupOpened &&
                          current.selectedPurpose != previous.selectedPurpose,
                      builder: (context, popupState) {
                        if (popupState is TransactionPopupOpened) {
                          final items = popupState.purposeTypeMap.keys
                              .map((purpose) => DropdownMenuItem(
                            value: purpose,
                            child: Text(purpose),
                          ))
                              .toList();
                          return DropdownButtonFormField<String>(
                            value: popupState.selectedPurpose,
                            decoration: const InputDecoration(labelText: "Purpose"),
                            items: items,
                            onChanged: items.isNotEmpty
                                ? (value) => context.read<UserLedgerCubit>().updatePurposeSelection(value)
                                : null,
                            hint: items.isEmpty ? const Text("No purposes available") : null,
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                    BlocBuilder<UserLedgerCubit, AccountLedgerState>(
                      buildWhen: (previous, current) =>
                      current is TransactionPopupOpened &&
                          previous is TransactionPopupOpened &&
                          (current.selectedType != previous.selectedType ||
                              current.selectedPurpose != previous.selectedPurpose),
                      builder: (context, popupState) {
                        if (popupState is TransactionPopupOpened) {
                          final items = popupState.selectedPurpose != null &&
                              popupState.purposeTypeMap.containsKey(popupState.selectedPurpose)
                              ? popupState.purposeTypeMap[popupState.selectedPurpose]!
                              .map((type) => DropdownMenuItem(
                            value: type,
                            child: Text(type),
                          ))
                              .toList()
                              : <DropdownMenuItem<String>>[];
                          return DropdownButtonFormField<String>(
                            value: popupState.selectedType,
                            decoration: const InputDecoration(labelText: "Type"),
                            items: items,
                            onChanged: items.isNotEmpty
                                ? (value) => context.read<UserLedgerCubit>().updateTypeSelection(value)
                                : null,
                            hint: items.isEmpty ? const Text("No types available") : null,
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ],
                  TextField(
                    controller: remarksController,
                    maxLength: 500,
                    decoration: InputDecoration(
                      labelText: state.isDebit ? "Remarks (Optional)" : "Remarks",
                    ),
                  ),
                  BlocBuilder<UserLedgerCubit, AccountLedgerState>(
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
                  amountController.clear();
                  billNumberController.clear();
                  remarksController.clear();
                },
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () {
                  final currentState = context.read<UserLedgerCubit>().state;
                  String? selectedType;
                  String? selectedPurpose;
                  if (currentState is TransactionPopupOpened) {
                    selectedType = currentState.selectedType;
                    selectedPurpose = currentState.selectedPurpose;
                  }
                  context.read<UserLedgerCubit>().addTransaction(
                    ledgerId: widget.user.accountLedgerId!,
                    amount: double.tryParse(amountController.text) ?? 0.0,
                    type: state.isDebit ? "Debit" : "Credit",
                    billNumber: billNumberController.text,
                    purpose: state.isDebit ? selectedPurpose : null,
                    typeOfPurpose: state.isDebit ? selectedType : null,
                    remarks: remarksController.text,
                    userType: widget.user.userType,
                  );
                  _isPopupOpen = false;
                  Navigator.pop(dialogContext);
                },
                child: const Text("Add"),
              ),
            ],
          ),
        );
      },
    );
  }
}