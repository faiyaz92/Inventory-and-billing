import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:requirment_gathering_app/company_admin_module/data/ledger/account_ledger_model.dart';
import 'package:requirment_gathering_app/company_admin_module/presentation/ledger/account_ledger_cubit.dart';
import 'package:requirment_gathering_app/company_admin_module/presentation/ledger/account_ledger_state.dart';
import 'package:requirment_gathering_app/core_module/presentation/widget/custom_appbar.dart';
import 'package:requirment_gathering_app/core_module/service_locator/service_locator.dart';
import 'package:requirment_gathering_app/core_module/utils/text_styles.dart';
import 'package:requirment_gathering_app/user_module/data/partner.dart';

@RoutePage()
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
  final TextEditingController serviceChargeController = TextEditingController();
  bool _isPopupOpen = false;

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
            BlocListener<AccountLedgerCubit, AccountLedgerState>(
              listenWhen: (previous, current) =>
                  (current is TransactionPopupOpened &&
                      current.isInitialOpen &&
                      !_isPopupOpen) ||
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
                if (state is TransactionPopupOpened &&
                    state.isInitialOpen &&
                    !_isPopupOpen) {
                  _isPopupOpen = true;
                  _showTransactionPopup(context, state);
                }
              },
              child: Container(),
            ),
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
                    serviceChargeController.text =
                        (ledger.serviceChargePercentage ?? 25.0).toString();
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
                  return Container();
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
            _buildSiteDetails(),
            const SizedBox(height: 10),
            _buildCostProfitTable(ledger),
            const SizedBox(height: 10),
            _buildPaymentReceivedTable(ledger),
            const SizedBox(height: 10),
            _buildServiceChargeInput(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSiteDetails() {
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
                "Site Details",
                style:
                    defaultTextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "",
                style:
                    defaultTextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        TableRow(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Site Owner Name",
                style:
                    defaultTextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                widget.company.companyName,
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
                "Contact Number",
                style:
                    defaultTextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                widget.company.contactNumber ?? "N/A",
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
                "Address",
                style:
                    defaultTextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                widget.company.address?.isEmpty ?? true
                    ? "N/A"
                    : widget.company.address!,
                style: defaultTextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCostProfitTable(AccountLedger ledger) {
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
                "Description",
                style:
                    defaultTextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Amount (₹)",
                style:
                    defaultTextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                textAlign: TextAlign.right,
              ),
            ),
          ],
        ),
        TableRow(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Base Construction Cost",
                style:
                    defaultTextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                (ledger.baseConstructionCost ?? 0.0).toStringAsFixed(2),
                style: defaultTextStyle(fontSize: 14),
                textAlign: TextAlign.right,
              ),
            ),
          ],
        ),
        TableRow(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Total Construction Cost",
                style:
                    defaultTextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                (ledger.totalConstructionCost ?? 0.0).toStringAsFixed(2),
                style: defaultTextStyle(fontSize: 14),
                textAlign: TextAlign.right,
              ),
            ),
          ],
        ),
        TableRow(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Current Base Due",
                style: defaultTextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.red),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                (ledger.currentBaseDue ?? 0.0).toStringAsFixed(2),
                style: defaultTextStyle(fontSize: 14, color: Colors.red),
                textAlign: TextAlign.right,
              ),
            ),
          ],
        ),
        TableRow(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Current Total Due",
                style: defaultTextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.red),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                (ledger.currentTotalDue ?? 0.0).toStringAsFixed(2),
                style: defaultTextStyle(fontSize: 14, color: Colors.red),
                textAlign: TextAlign.right,
              ),
            ),
          ],
        ),
        TableRow(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Estimated Profit",
                style:
                    defaultTextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                (ledger.estimatedProfit ?? 0.0).toStringAsFixed(2),
                style: defaultTextStyle(fontSize: 14),
                textAlign: TextAlign.right,
              ),
            ),
          ],
        ),
        TableRow(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Current Profit",
                style:
                    defaultTextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                (ledger.currentProfit ?? 0.0).toStringAsFixed(2),
                style: defaultTextStyle(fontSize: 14),
                textAlign: TextAlign.right,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPaymentReceivedTable(AccountLedger ledger) {
    return Table(
      border: TableBorder.all(color: Colors.grey.shade300),
      columnWidths: const {
        0: FlexColumnWidth(3),
        1: FlexColumnWidth(2),
      },
      children: [
        TableRow(
          decoration: BoxDecoration(color: Colors.green.shade50),
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Total Payment Received",
                style: defaultTextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                (ledger.totalPaymentReceived ?? 0.0).toStringAsFixed(2),
                style: defaultTextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green),
                textAlign: TextAlign.right,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildServiceChargeInput(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: serviceChargeController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: "Service Charge (%)",
            hintText: "Enter percentage (e.g., 25)",
          ),
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: () {
            final percentage =
                double.tryParse(serviceChargeController.text) ?? 25.0;
            context.read<AccountLedgerCubit>().updateServiceCharge(percentage);
          },
          child: const Text("Calculate"),
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
          onPressed: () => context
              .read<AccountLedgerCubit>()
              .openTransactionPopup(false, widget.company.companyType ?? ''),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: const Text("Credit (Jama)"),
        ),
        ElevatedButton(
          onPressed: () => context
              .read<AccountLedgerCubit>()
              .openTransactionPopup(true, widget.company.companyType ?? ''),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: const Text("Debit (Udhar)"),
        ),
      ],
    );
  }

  SliverList _buildTransactionList(AccountLedger ledger) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final txn = ledger.transactions?[index];
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
                            txn?.type == "Debit"
                                ? "Udhar: ₹${txn?.amount}"
                                : "Jama: ₹${txn?.amount}",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: txn?.type == "Debit"
                                  ? Colors.red
                                  : Colors.green,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            txn?.billNumber != null
                                ? "Bill: ${txn?.billNumber}"
                                : "No Bill Number",
                            style: defaultTextStyle(
                                fontSize: 14, color: Colors.grey.shade600),
                          ),
                          if (txn?.purpose != null)
                            Text(
                              "Purpose: ${txn?.purpose}",
                              style: defaultTextStyle(
                                  fontSize: 14, color: Colors.grey.shade600),
                            ),
                          if (txn?.typeOfPurpose != null)
                            Text(
                              "Type: ${txn?.typeOfPurpose}",
                              style: defaultTextStyle(
                                  fontSize: 14, color: Colors.grey.shade600),
                            ),
                          if (txn?.remarks != null)
                            Text(
                              "Remarks: ${txn?.remarks}",
                              style: defaultTextStyle(
                                  fontSize: 14, color: Colors.grey.shade600),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        txn?.createdAt.toString().split(' ')[0] ?? '',
                        style: defaultTextStyle(
                            fontSize: 14, fontWeight: FontWeight.w500),
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

  void _showTransactionPopup(
      BuildContext context, TransactionPopupOpened state) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return BlocProvider.value(
          value: _ledgerCubit,
          child: AlertDialog(
            title:
                Text(state.isDebit ? "Add Debit (Udhar)" : "Add Credit (Jama)"),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: "Amount"),
                  ),
                  TextField(
                    controller: billNumberController,
                    decoration: const InputDecoration(
                        labelText: "Bill Number (Optional)"),
                  ),
                  if (state.isDebit && state.companyType == "Site") ...[
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
                            decoration:
                                const InputDecoration(labelText: "Purpose"),
                            items: items,
                            onChanged: items.isNotEmpty
                                ? (value) => context
                                    .read<AccountLedgerCubit>()
                                    .updatePurposeSelection(value)
                                : null,
                            hint: items.isEmpty
                                ? const Text("No purposes available")
                                : null,
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
                              current.selectedPurpose !=
                                  previous.selectedPurpose),
                      builder: (context, popupState) {
                        if (popupState is TransactionPopupOpened) {
                          final items = (popupState.selectedPurpose != null &&
                                  popupState.purposeTypeMap.containsKey(
                                      popupState.selectedPurpose) &&
                                  popupState
                                      .purposeTypeMap[
                                          popupState.selectedPurpose]!
                                      .isNotEmpty
                              ? popupState
                                  .purposeTypeMap[popupState.selectedPurpose]!
                                  .map((type) {
                                  return DropdownMenuItem(
                                    value: type,
                                    child: Text(type),
                                  );
                                }).toList()
                              : <DropdownMenuItem<String>>[]);
                          return DropdownButtonFormField<String>(
                            key: const ValueKey('type_dropdown_field'),
                            value: popupState.selectedType,
                            decoration:
                                const InputDecoration(labelText: "Type"),
                            items: items,
                            onChanged: items.isNotEmpty
                                ? (value) => context
                                    .read<AccountLedgerCubit>()
                                    .updateTypeSelection(value)
                                : null,
                            hint: items.isEmpty
                                ? const Text("No types available")
                                : null,
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
                      labelText: state.isDebit
                          ? "Remarks (Optional)"
                          : "Remarks (Required)",
                    ),
                  ),
                  BlocBuilder<AccountLedgerCubit, AccountLedgerState>(
                    buildWhen: (previous, current) =>
                        current is TransactionPopupOpened &&
                        previous is TransactionPopupOpened &&
                        current.errorMessage != previous.errorMessage,
                    builder: (context, popupState) {
                      if (popupState is TransactionPopupOpened &&
                          popupState.errorMessage != null) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            popupState.errorMessage!,
                            style: const TextStyle(
                                color: Colors.red, fontSize: 12),
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
                        purpose: state.isDebit && state.companyType == "Site"
                            ? selectedPurpose
                            : null,
                        typeOfPurpose:
                            state.isDebit && state.companyType == "Site"
                                ? selectedType
                                : null,
                        remarks: remarksController.text,
                      );
                  amountController.clear();
                  billNumberController.clear();
                  remarksController.clear();
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
