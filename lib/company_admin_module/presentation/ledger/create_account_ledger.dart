import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:requirment_gathering_app/company_admin_module/presentation/ledger/account_ledger_cubit.dart';
import 'package:requirment_gathering_app/company_admin_module/presentation/ledger/account_ledger_state.dart';
import 'package:requirment_gathering_app/core_module/service_locator/service_locator.dart';

@RoutePage()
class CreateLedgerPage extends StatelessWidget {
  final String companyId;
  final String customerCompanyId;

  const CreateLedgerPage({
    Key? key,
    required this.companyId,
    required this.customerCompanyId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AccountLedgerCubit>(),
      child: _CreateLedgerView(
        companyId: companyId,
        customerCompanyId: customerCompanyId,
      ),
    );
  }
}

class _CreateLedgerView extends StatefulWidget {
  final String companyId;
  final String customerCompanyId;

  const _CreateLedgerView({
    required this.companyId,
    required this.customerCompanyId,
  });

  @override
  _CreateLedgerViewState createState() => _CreateLedgerViewState();
}

class _CreateLedgerViewState extends State<_CreateLedgerView> {
  final TextEditingController _outstandingController = TextEditingController();
  final TextEditingController _promiseAmountController =
      TextEditingController();
  DateTime? _promiseDate;

  void _createLedger(BuildContext context) {
    final double totalOutstanding =
        double.tryParse(_outstandingController.text) ?? 0.0;
    final double? promiseAmount =
        double.tryParse(_promiseAmountController.text);

    /* context.read<AccountLedgerCubit>().createLedger(
      widget.companyId,
      widget.customerCompanyId,
      totalOutstanding,
      promiseAmount,
      _promiseDate,
    );*/
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Account Ledger")),
      body: BlocConsumer<AccountLedgerCubit, AccountLedgerState>(
        listener: (context, state) {
          if (state is AccountLedgerSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(state.message), backgroundColor: Colors.green),
            );
            Navigator.pop(context); // ✅ Ledger create hone ke baad back jao
          } else if (state is AccountLedgerError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _outstandingController,
                  decoration: const InputDecoration(
                    labelText: "Total Outstanding",
                  ),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: _promiseAmountController,
                  decoration: const InputDecoration(
                    labelText: "Promise Amount (Optional)",
                  ),
                  keyboardType: TextInputType.number,
                ),
                ListTile(
                  title: Text(
                    _promiseDate == null
                        ? "Select Promise Date"
                        : "Promise Date: ${_promiseDate.toString().split(' ')[0]}",
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
                      setState(() {
                        _promiseDate = picked;
                      });
                    }
                  },
                ),
                const SizedBox(height: 20),
                state is AccountLedgerLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: () => _createLedger(context),
                        child: const Text("Create Ledger"),
                      ),
              ],
            ),
          );
        },
      ),
    );
  }
}
