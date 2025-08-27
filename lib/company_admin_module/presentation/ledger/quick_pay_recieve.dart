import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:requirment_gathering_app/company_admin_module/presentation/ledger/user_ledger_cubit.dart';
import 'package:requirment_gathering_app/company_admin_module/service/user_services.dart';
import 'package:requirment_gathering_app/core_module/coordinator/coordinator.dart';
import 'package:requirment_gathering_app/core_module/presentation/widget/custom_appbar.dart';
import 'package:requirment_gathering_app/core_module/repository/account_repository.dart';
import 'package:requirment_gathering_app/core_module/service_locator/service_locator.dart';
import 'package:requirment_gathering_app/core_module/utils/AppColor.dart';
import 'package:requirment_gathering_app/super_admin_module/data/user_info.dart';
import 'package:requirment_gathering_app/super_admin_module/utils/roles.dart';
import 'package:requirment_gathering_app/super_admin_module/utils/user_type.dart';

@RoutePage()
class QuickTransactionPage extends StatefulWidget {
  final String transactionType; // 'receive' or 'pay'

  const QuickTransactionPage({super.key, required this.transactionType});

  @override
  State<QuickTransactionPage> createState() => _QuickTransactionPageState();
}

class _QuickTransactionPageState extends State<QuickTransactionPage> {
  final TextEditingController _amountController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? _selectedUserId;
  UserType _selectedUserType = UserType.Customer;
  Role? _selectedRole;
  List<UserInfo> _users = [];

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    final accountRepository = sl<UserServices>();
    final users = await accountRepository.getUsersFromTenantCompany();
    setState(() {
      _users = users;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isReceiveMode = widget.transactionType.toLowerCase() == 'receive';
    final filteredUsers = _users
        .where((user) => user.userType == _selectedUserType)
        .where((user) =>
    _selectedUserType != UserType.Employee ||
        _selectedRole == null ||
        user.role == _selectedRole)
        .toList();

    return Scaffold(
      appBar: CustomAppBar(
        title: isReceiveMode ? 'Quick Receive Payment' : 'Quick Pay',
      ),
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
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DropdownButtonFormField<UserType>(
                    decoration: InputDecoration(
                      labelText: 'User Type',
                      labelStyle: const TextStyle(color: AppColors.textSecondary),
                      filled: true,
                      fillColor: AppColors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                            color: AppColors.textSecondary.withOpacity(0.3)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                            color: AppColors.textSecondary.withOpacity(0.3)),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                    ),
                    value: _selectedUserType,
                    items: [
                      const DropdownMenuItem(
                          value: UserType.Customer, child: Text('Customer')),
                      const DropdownMenuItem(
                          value: UserType.Employee, child: Text('Employee')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedUserType = value;
                          _selectedUserId = null;
                          _selectedRole = null;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  if (_selectedUserType == UserType.Employee)
                    DropdownButtonFormField<Role>(
                      decoration: InputDecoration(
                        labelText: 'Role',
                        labelStyle: const TextStyle(color: AppColors.textSecondary),
                        filled: true,
                        fillColor: AppColors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                              color: AppColors.textSecondary.withOpacity(0.3)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                              color: AppColors.textSecondary.withOpacity(0.3)),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                      ),
                      value: _selectedRole,
                      hint: const Text(
                        'Select Role',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                      items: Role.values
                          .map((role) => DropdownMenuItem(
                        value: role,
                        child: Text(
                            role.name.replaceAll('_', ' ').toTitleCase()),
                      ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedRole = value;
                          _selectedUserId = null;
                        });
                      },
                    ),
                  if (_selectedUserType == UserType.Employee)
                    const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Select ${_selectedUserType.name}',
                      labelStyle: const TextStyle(color: AppColors.textSecondary),
                      filled: true,
                      fillColor: AppColors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                            color: AppColors.textSecondary.withOpacity(0.3)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                            color: AppColors.textSecondary.withOpacity(0.3)),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                    ),
                    value: _selectedUserId,
                    hint: Text(
                      'Select ${_selectedUserType.name}',
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                    items: filteredUsers
                        .map((user) => DropdownMenuItem(
                      value: user.userId,
                      child: Text(user.name ?? user.userName ?? 'Unknown'),
                    ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedUserId = value;
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Please select a ${_selectedUserType.name.toLowerCase()}';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _amountController,
                    keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Amount',
                      border: OutlineInputBorder(),
                      contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Amount is required';
                      }
                      final amount = double.tryParse(value);
                      if (amount == null || amount <= 0) {
                      return 'Enter a valid positive amount';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.center,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          final amount = double.parse(_amountController.text);
                          _processTransaction(context, amount);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                      ),
                      child: Text(
                        isReceiveMode ? 'Receive' : 'Pay',
                        style: const TextStyle(color: AppColors.white, fontSize: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _processTransaction(BuildContext context, double amount) async {
    final ledgerCubit = sl<UserLedgerCubit>();
    final accountRepository = sl<AccountRepository>();
    final userInfo = await accountRepository.getUserInfo();
    final loggedInUserId = userInfo?.userId;
    final loggedInUserLedgerId = userInfo?.accountLedgerId;

    if (loggedInUserId == null || loggedInUserLedgerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Logged-in user information not found')),
      );
      return;
    }

    final selectedUser = _users.firstWhere((user) => user.userId == _selectedUserId);
    final sourceLedgerId = selectedUser.accountLedgerId;

    if (sourceLedgerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selected user ledger ID not found')),
      );
      return;
    }

    final isReceiveMode = widget.transactionType.toLowerCase() == 'receive';
    final transactionId = 'quick_${DateTime.now().millisecondsSinceEpoch}';

    // Ledger entries based on transaction type
    if (isReceiveMode) {
      // Receive: Credit source user (reduces liability), Debit logged-in user (increases cash)
      await ledgerCubit.addTransaction(
        ledgerId: sourceLedgerId,
        amount: amount,
        type: 'Credit',
        billNumber: null,
        purpose: 'Payment',
        typeOfPurpose: 'Cash',
        remarks:
        'Quick payment received from ${_selectedUserType.name} ${selectedUser.name ?? selectedUser.userName ?? 'Unknown'}',
        userType: _selectedUserType,
      );
      await ledgerCubit.addTransaction(
        ledgerId: loggedInUserLedgerId,
        amount: amount,
        type: 'Debit',
        billNumber: null,
        purpose: 'Cash Received',
        typeOfPurpose: 'Cash',
        remarks:
        'Quick cash received from ${_selectedUserType.name} ${selectedUser.name ?? selectedUser.userName ?? 'Unknown'}',
        userType: userInfo?.userType ?? UserType.Employee,
      );
    } else {
      // Pay: Credit logged-in user (reduces cash), Debit source user (increases liability)
      await ledgerCubit.addTransaction(
        ledgerId: loggedInUserLedgerId,
        amount: amount,
        type: 'Credit',
        billNumber: null,
        purpose: 'Payment Made',
        typeOfPurpose: 'Cash',
        remarks:
        'Quick payment made to ${_selectedUserType.name} ${selectedUser.name ?? selectedUser.userName ?? 'Unknown'}',
        userType: userInfo?.userType ?? UserType.Employee,
      );
      await ledgerCubit.addTransaction(
        ledgerId: sourceLedgerId,
        amount: amount,
        type: 'Debit',
        billNumber: null,
        purpose: 'Payment Received',
        typeOfPurpose: 'Cash',
        remarks:
        'Quick payment received from ${userInfo?.name ?? userInfo?.userName ?? 'Unknown'}',
        userType: _selectedUserType,
      );
    }

    // Generate receipt
    final receiptPdf =
    await _generateReceiptPdf(selectedUser, amount, transactionId, isReceiveMode);

    // Navigate to receipt PDF page
    await sl<Coordinator>().navigateToBillPdfPage(
      pdf: receiptPdf,
      billNumber: transactionId,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Transaction ${isReceiveMode ? 'received' : 'paid'} successfully')),
    );

    // Clear form
    setState(() {
      _amountController.clear();
      _selectedUserId = null;
    });
  }

  Future<pw.Document> _generateReceiptPdf(
      UserInfo user, double amount, String transactionId, bool isReceiveMode) async {
    final pdf = pw.Document();
    final accountRepository = sl<AccountRepository>();

    String companyName = 'Abc Pvt. Ltd.';
    String issuerName = 'Unknown Issuer';
    try {
      final userInfo = await accountRepository.getUserInfo();
      companyName = userInfo?.companyId ?? companyName;
      issuerName = userInfo?.name ?? userInfo?.userName ?? issuerName;
    } catch (e) {
      print('Error fetching company or issuer name: $e');
    }

    final primaryColor = PdfColor.fromInt(AppColors.primary.value);
    final textSecondaryColor = PdfColor.fromInt(AppColors.textSecondary.value);
    final greyColor = PdfColors.grey300;

    final regularFont = pw.Font.times();
    final boldFont = pw.Font.timesBold();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        header: (context) => pw.Container(
          padding: const pw.EdgeInsets.only(bottom: 12),
          decoration: pw.BoxDecoration(
            border: pw.Border(bottom: pw.BorderSide(width: 3, color: primaryColor)),
          ),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    companyName,
                    style: pw.TextStyle(font: boldFont, fontSize: 22, color: primaryColor),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    '123 Business Street, City, Country',
                    style: pw.TextStyle(font: regularFont, fontSize: 12, color: textSecondaryColor),
                  ),
                ],
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text(
                    'RECEIPT',
                    style: pw.TextStyle(font: boldFont, fontSize: 28, color: primaryColor),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    'Transaction ID: $transactionId',
                    style: pw.TextStyle(font: regularFont, fontSize: 14),
                  ),
                  pw.Text(
                    'Date: ${DateTime.now().toString().substring(0, 10)}',
                    style: pw.TextStyle(font: regularFont, fontSize: 14),
                  ),
                  pw.Text(
                    'Issuer: $issuerName',
                    style: pw.TextStyle(font: regularFont, fontSize: 14),
                  ),
                ],
              ),
            ],
          ),
        ),
        build: (context) => [
          pw.SizedBox(height: 24),
          pw.Text(
            isReceiveMode ? 'Received From:' : 'Paid To:',
            style: pw.TextStyle(font: boldFont, fontSize: 18, color: PdfColors.black),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            user.name ?? user.userName ?? 'Unknown ${_selectedUserType.name}',
            style: pw.TextStyle(font: boldFont, fontSize: 16, color: primaryColor),
          ),
          pw.SizedBox(height: 24),
          pw.Text(
            'Transaction Details',
            style: pw.TextStyle(font: boldFont, fontSize: 18),
          ),
          pw.SizedBox(height: 12),
          pw.Table(
            border: pw.TableBorder.all(color: greyColor, width: 1),
            columnWidths: {
              0: const pw.FlexColumnWidth(2),
              1: const pw.FlexColumnWidth(2),
            },
            children: [
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.grey100),
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(10),
                    child: pw.Text('Description', style: pw.TextStyle(font: boldFont, fontSize: 13)),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(10),
                    child: pw.Text('Amount', style: pw.TextStyle(font: boldFont, fontSize: 13)),
                  ),
                ],
              ),
              pw.TableRow(
                decoration: pw.BoxDecoration(
                  border: pw.Border(bottom: pw.BorderSide(color: greyColor, width: 0.5)),
                ),
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(10),
                    child: pw.Text(
                      isReceiveMode
                          ? 'Quick Payment from ${_selectedUserType.name}'
                          : 'Quick Payment to ${_selectedUserType.name}',
                      style: pw.TextStyle(font: regularFont, fontSize: 12),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(10),
                    child: pw.Text(
                      amount.toStringAsFixed(2),
                      style: pw.TextStyle(font: regularFont, fontSize: 12),
                      textAlign: pw.TextAlign.right,
                    ),
                  ),
                ],
              ),
            ],
          ),
          pw.SizedBox(height: 24),
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: PdfColors.grey50,
              border: pw.Border.all(color: greyColor, width: 1),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.end,
              children: [
                pw.Text(
                  'Total Amount: ${amount.toStringAsFixed(2)}',
                  style: pw.TextStyle(font: boldFont, fontSize: 16, color: primaryColor),
                ),
              ],
            ),
          ),
        ],
        footer: (context) => pw.Container(
          alignment: pw.Alignment.center,
          padding: const pw.EdgeInsets.only(top: 12),
          child: pw.Text(
            'Generated by $companyName | Page ${context.pageNumber} of ${context.pagesCount}',
            style: pw.TextStyle(font: regularFont, fontSize: 10, color: textSecondaryColor),
          ),
        ),
      ),
    );

    return pdf;
  }
}

extension StringExtension on String {
  String toTitleCase() {
    return split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');
  }
}