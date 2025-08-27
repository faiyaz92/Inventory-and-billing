import 'package:auto_route/annotations.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:requirment_gathering_app/company_admin_module/data/ledger/account_ledger_model.dart';
import 'package:requirment_gathering_app/company_admin_module/presentation/ledger/account_ledger_state.dart';
import 'package:requirment_gathering_app/company_admin_module/presentation/ledger/user_ledger_cubit.dart';
import 'package:requirment_gathering_app/company_admin_module/repositories/stock_repository.dart';
import 'package:requirment_gathering_app/company_admin_module/service/user_services.dart';
import 'package:requirment_gathering_app/core_module/coordinator/coordinator.dart';
import 'package:requirment_gathering_app/core_module/presentation/widget/custom_appbar.dart';
import 'package:requirment_gathering_app/core_module/repository/account_repository.dart';
import 'package:requirment_gathering_app/core_module/service_locator/service_locator.dart';
import 'package:requirment_gathering_app/core_module/utils/AppColor.dart';
import 'package:requirment_gathering_app/core_module/utils/text_styles.dart';
import 'package:requirment_gathering_app/super_admin_module/data/user_info.dart';
import 'package:requirment_gathering_app/super_admin_module/utils/roles.dart';
import 'package:requirment_gathering_app/super_admin_module/utils/user_type.dart';

enum TransactionType { General, Expense, Reimbursement, OtherLedger }

@RoutePage()
class UserLedgerPage extends StatefulWidget {
  final UserInfo? user;
  final StoreDto? store;
  final TransactionType type;

  const UserLedgerPage({
    Key? key,
    this.user,
    this.store,
    this.type = TransactionType.General,
  }) : super(key: key);

  @override
  _UserLedgerPageState createState() => _UserLedgerPageState();
}

class _UserLedgerPageState extends State<UserLedgerPage> {
  late UserLedgerCubit _ledgerCubit;
  final TextEditingController amountController = TextEditingController();
  final TextEditingController billNumberController = TextEditingController();
  final TextEditingController remarksController = TextEditingController();
  bool _isPopupOpen = false;
  String? _ledgerId;
  bool _ledgerCreated = false;
  final _formKey = GlobalKey<FormState>();
  final _selectionFormKey = GlobalKey<FormState>();
  String? _selectedSourceLedgerId;
  UserInfo? _selectedSourceUserInfo;
  String? _selectedDestinationLedgerId;
  UserInfo? _selectedDestinationUserInfo;
  List<Map<String, dynamic>> _accounts = [];
  UserInfo? _cachedUserInfo;
  String? _selectedFilterType;
  UserType? _selectedUserType;
  Role? _selectedRole;

  @override
  void initState() {
    super.initState();
    _ledgerCubit = sl<UserLedgerCubit>();
    if (widget.user != null) {
      _ledgerId = widget.user!.accountLedgerId;
      _ledgerCreated = widget.user!.accountLedgerId == null ||
          widget.user!.accountLedgerId!.isEmpty;
      if (_ledgerCreated) {
        _ledgerCubit.ensureLedger(
            widget.user!.accountLedgerId, widget.user!.userType, widget.user!);
      }
    } else if (widget.store != null) {
      _ledgerId = widget.store!.accountLedgerId;
      _ledgerCreated = widget.store!.accountLedgerId == null ||
          widget.store!.accountLedgerId!.isEmpty;
      if (_ledgerCreated) {
        _ledgerCubit.ensureLedgerForStore(
            widget.store!.accountLedgerId, widget.store!);
      }
    } else {
      _loadLoggedInUserLedger();
    }
    _loadAccounts();
  }

  Future<void> _loadLoggedInUserLedger() async {
    _cachedUserInfo = await sl<AccountRepository>().getUserInfo();
    if (_cachedUserInfo != null) {
      _ledgerId = _cachedUserInfo!.accountLedgerId;
      _ledgerCreated = _cachedUserInfo!.accountLedgerId == null ||
          _cachedUserInfo!.accountLedgerId!.isEmpty;
      if (_ledgerCreated) {
        _ledgerCubit.ensureLedger(_cachedUserInfo!.accountLedgerId,
            _cachedUserInfo!.userType, _cachedUserInfo!);
      }
    }
  }

  Future<void> _loadAccounts() async {
    _cachedUserInfo = await sl<AccountRepository>().getUserInfo();
    final companyId = _cachedUserInfo?.companyId ?? '';
    final users = await sl<UserServices>().getUsersFromTenantCompany();
    final stores = await sl<StockRepository>().getStores(companyId);

    final Map<String, Map<String, dynamic>> accountsMap = {};
    final salesmanLedgerIds = users
        .where((u) =>
            u.role == Role.SALES_MAN &&
            u.accountLedgerId != null &&
            u.accountLedgerId!.isNotEmpty)
        .map((u) => u.accountLedgerId!)
        .toSet();

    for (var u in users) {
      if (u.accountLedgerId != null && u.accountLedgerId!.isNotEmpty) {
        accountsMap[u.accountLedgerId!] = {
          'ledgerId': u.accountLedgerId,
          'name': u.name ?? u.userName ?? 'Unknown User',
          'type': u.userType?.name ?? 'User',
          'userInfo': u,
          'accountType': u.accountType?.name,
          'role': u.role,
        };
      }
    }
    for (var s in stores) {
      if (s.accountLedgerId != null &&
          s.accountLedgerId!.isNotEmpty &&
          !salesmanLedgerIds.contains(s.accountLedgerId)) {
        accountsMap[s.accountLedgerId!] = {
          'ledgerId': s.accountLedgerId,
          'name': s.name,
          'type': 'Store',
          'userInfo': UserInfo(
            userId: s.storeId,
            name: s.name,
            userName: s.name,
            companyId: companyId,
            userType: UserType.Store,
            accountLedgerId: s.accountLedgerId,
          ),
          'accountType': null,
          'role': null,
        };
      }
    }
    final accounts = accountsMap.values.toList();

    setState(() {
      _accounts = accounts;
      if (widget.type == TransactionType.Expense) {
        _selectedSourceLedgerId = _cachedUserInfo?.accountLedgerId;
        _selectedSourceUserInfo = _cachedUserInfo;
        _selectedDestinationLedgerId = accounts.firstWhere(
                (account) => account['accountType'] == 'Expense',
                orElse: () => {'ledgerId': null, 'userInfo': null})['ledgerId']
            as String?;
        _selectedDestinationUserInfo = accounts.firstWhere(
                (account) => account['accountType'] == 'Expense',
                orElse: () => {'ledgerId': null, 'userInfo': null})['userInfo']
            as UserInfo?;
        _ledgerId = _cachedUserInfo?.accountLedgerId;
        if (_ledgerId != null && _ledgerCreated == false) {
          _ledgerCubit.fetchLedger(_ledgerId!, _cachedUserInfo!.userType);
        }
      } else if (widget.type == TransactionType.Reimbursement) {
        _selectedSourceLedgerId = accounts.firstWhere(
                (account) => account['accountType'] == 'Finance',
                orElse: () => {'ledgerId': null, 'userInfo': null})['ledgerId']
            as String?;
        _selectedSourceUserInfo = accounts.firstWhere(
                (account) => account['accountType'] == 'Finance',
                orElse: () => {'ledgerId': null, 'userInfo': null})['userInfo']
            as UserInfo?;
        _selectedDestinationLedgerId = widget.user?.accountLedgerId;
        _selectedDestinationUserInfo = widget.user;
        _ledgerId = _selectedSourceLedgerId;
        if (_ledgerId != null && _ledgerCreated == false) {
          _ledgerCubit.fetchLedger(_ledgerId!,
              _selectedSourceUserInfo?.userType ?? UserType.Accounts);
        }
      }else {
        _selectedSourceLedgerId = accounts.any((account) =>
                account['ledgerId'] == _cachedUserInfo?.accountLedgerId)
            ? _cachedUserInfo?.accountLedgerId
            : accounts.isNotEmpty
                ? accounts.first['ledgerId']
                : null;
        _selectedDestinationLedgerId = accounts.any((account) =>
                account['ledgerId'] ==
                (widget.user?.accountLedgerId ??
                    widget.store?.accountLedgerId ??
                    _cachedUserInfo?.accountLedgerId))
            ? (widget.user?.accountLedgerId ??
                widget.store?.accountLedgerId ??
                _cachedUserInfo?.accountLedgerId)
            : accounts.isNotEmpty
                ? accounts.first['ledgerId']
                : null;
        _selectedSourceUserInfo = accounts.any(
                (account) => account['ledgerId'] == _selectedSourceLedgerId)
            ? accounts.firstWhere(
                (account) => account['ledgerId'] == _selectedSourceLedgerId,
                orElse: () => {
                      'ledgerId': null,
                      'userInfo': null
                    })['userInfo'] as UserInfo?
            : null;
        _selectedDestinationUserInfo = accounts.any((account) =>
                account['ledgerId'] == _selectedDestinationLedgerId)
            ? accounts.firstWhere(
                (account) =>
                    account['ledgerId'] == _selectedDestinationLedgerId,
                orElse: () => {
                      'ledgerId': null,
                      'userInfo': null
                    })['userInfo'] as UserInfo?
            : null;
        _ledgerId = widget.user?.accountLedgerId ??
            widget.store?.accountLedgerId ??
            _cachedUserInfo?.accountLedgerId;
        if (_ledgerId != null && _ledgerCreated == false) {
          _ledgerCubit.fetchLedger(_ledgerId!,
              _selectedDestinationUserInfo?.userType ?? UserType.Store);
        }
      }
    });
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
        appBar: CustomAppBar(
          title: widget.user == null &&
                  widget.store == null &&
                  widget.type == TransactionType.General
              ? "My Account"
              : widget.type == TransactionType.Expense
                  ? "Expense Ledger"
                  : widget.type == TransactionType.Reimbursement
                      ? "Reimbursement Ledger"
                      : widget.type == TransactionType.OtherLedger
                          ? "Other Ledger"
                          : "User Ledger",
          onBackPressed: () {
            sl<Coordinator>().navigateBack(isUpdated: _ledgerCreated);
          },
        ),
        body: Column(
          children: [
            BlocListener<UserLedgerCubit, AccountLedgerState>(
              listenWhen: (previous, current) =>
                  (current is TransactionPopupOpened &&
                      current.isInitialOpen &&
                      !_isPopupOpen) ||
                  current is TransactionSuccess ||
                  current is TransactionAddFailed ||
                  current is AccountLedgerUpdated ||
                  current is AccountLedgerError,
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
                if (state is AccountLedgerUpdated) {
                  setState(() {
                    _ledgerId = state.ledger.ledgerId ?? _ledgerId;
                    _ledgerCreated = _ledgerCreated && _ledgerId != null;
                  });
                }
                if (state is AccountLedgerError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.message)),
                  );
                  if (_ledgerCreated) {
                    _ledgerCreated = false;
                  }
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
                    return Center(
                        child: Text(state.message.isNotEmpty
                            ? state.message
                            : "Failed to load ledger data"));
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
                  // Handle initial state for OtherLedger when no destination is selected
                  if (widget.type == TransactionType.OtherLedger &&
                      _ledgerId == null) {
                    return const Center(
                        child: Text(
                            "Select a destination account to view ledger"));
                  }
                  return const Center(child: Text("No ledger data available"));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context, AccountLedger ledger) {
    final isAdminOrAccountant = _cachedUserInfo?.role == Role.COMPANY_ADMIN ||
        _cachedUserInfo?.role == Role.COMPANY_ACCOUNTANT;

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
            if (_ledgerId != null) _buildBalanceTable(ledger),
            const SizedBox(height: 10),
            Form(
              key: _selectionFormKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Filters for OtherLedger
                  if (widget.type == TransactionType.OtherLedger) ...[
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Filter Type',
                        labelStyle: const TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.black87),
                        filled: true,
                        fillColor: Colors.grey[50],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                              color: AppColors.textSecondary, width: 0.3),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                              color: AppColors.textSecondary, width: 0.3),
                        ),
                        contentPadding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                      ),
                      value: _selectedFilterType,
                      items: ['User', 'Store'].map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Text(type),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedFilterType = value;
                          _selectedUserType = null;
                          _selectedRole = null;
                          _selectedDestinationLedgerId = null;
                          _selectedDestinationUserInfo = null;
                          _ledgerId = null;
                        });
                      },
                    ),
                    if (_selectedFilterType == 'User') const SizedBox(height: 8),
                    if (_selectedFilterType == 'User')
                      DropdownButtonFormField<UserType>(
                        decoration: InputDecoration(
                          labelText: 'User Type',
                          labelStyle: const TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.black87),
                          filled: true,
                          fillColor: Colors.grey[50],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                                color: AppColors.textSecondary, width: 0.3),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                                color: AppColors.textSecondary, width: 0.3),
                          ),
                          contentPadding:
                          const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                        ),
                        value: _selectedUserType,
                        items: UserType.values.map((type) {
                          return DropdownMenuItem(
                            value: type,
                            child: Text(
                              type.name,
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedUserType = value;
                            _selectedRole = null;
                            _selectedDestinationLedgerId = null;
                            _selectedDestinationUserInfo = null;
                            _ledgerId = null;
                          });
                        },
                      ),
                    if (_selectedUserType == UserType.Employee)
                      const SizedBox(height: 8),
                    if (_selectedUserType == UserType.Employee)
                      DropdownButtonFormField<Role>(
                        decoration: InputDecoration(
                          labelText: 'Role',
                          labelStyle: const TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.black87),
                          filled: true,
                          fillColor: Colors.grey[50],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                                color: AppColors.textSecondary, width: 0.3),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                                color: AppColors.textSecondary, width: 0.3),
                          ),
                          contentPadding:
                          const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                        ),
                        value: _selectedRole,
                        items: Role.values
                            .where((role) => role != Role.SUPER_ADMIN)
                            .map((role) {
                          return DropdownMenuItem(
                            value: role,
                            child: Text(
                              role.name,
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedRole = value;
                            _selectedDestinationLedgerId = null;
                            _selectedDestinationUserInfo = null;
                            _ledgerId = null;
                          });
                        },
                      ),
                    const SizedBox(height: 12),
                  ],
                  // Source Account
                  widget.user == null &&
                      widget.store == null &&
                      widget.type != TransactionType.OtherLedger
                      ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "My Account",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _selectedSourceUserInfo != null
                              ? '${_selectedSourceUserInfo!.name ?? _selectedSourceUserInfo!.userName ?? 'Unknown'} (${_selectedSourceUserInfo!.userType?.name ?? 'User'})'
                              : 'No source account selected',
                          style: defaultTextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  )
                      : widget.type == TransactionType.Expense
                      ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "My Account",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black87),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _selectedSourceUserInfo != null
                              ? '${_selectedSourceUserInfo!.name ?? _selectedSourceUserInfo!.userName ?? 'Unknown'} (${_selectedSourceUserInfo!.userType?.name ?? 'User'})'
                              : 'No source account selected',
                          style: defaultTextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  )
                      : DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: "Source Account",
                      labelStyle: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none),
                      filled: true,
                      fillColor: Colors.grey[50],
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 12),
                      errorStyle: const TextStyle(color: Colors.red),
                    ),
                    value: _selectedSourceLedgerId,
                    items: widget.type == TransactionType.Reimbursement
                        ? _accounts
                        .where((account) =>
                    account['userInfo'].userType ==
                        UserType.Accounts)
                        .map((account) => DropdownMenuItem(
                      value: account['ledgerId'] as String,
                      child: Text(
                          '${account['name']} (${account['type']})'),
                    ))
                        .toList()
                        : _accounts.isNotEmpty
                        ? _accounts
                        .map((account) => DropdownMenuItem(
                      value: account['ledgerId'] as String,
                      child: Text(
                          '${account['name']} (${account['type']})'),
                    ))
                        .toList()
                        : [
                      const DropdownMenuItem(
                        value: null,
                        child: Text('No accounts available'),
                      ),
                    ],
                    onChanged: _accounts.isNotEmpty
                        ? (value) {
                      setState(() {
                        _selectedSourceLedgerId = value;
                        _selectedSourceUserInfo = _accounts.any(
                                (account) =>
                            account['ledgerId'] == value)
                            ? _accounts.firstWhere(
                                (account) =>
                            account['ledgerId'] == value,
                            orElse: () =>
                            {'ledgerId': null, 'userInfo': null})[
                        'userInfo'] as UserInfo?
                            : null;
                      });
                    }
                        : null,
                    validator: (value) =>
                    value == null && _accounts.isNotEmpty
                        ? 'Please select a source account'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  // Destination Account
                  widget.type == TransactionType.Expense
                      ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Expense Account",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _selectedDestinationUserInfo != null
                              ? '${_selectedDestinationUserInfo!.name ?? _selectedDestinationUserInfo!.userName ?? 'Unknown'} (${_selectedDestinationUserInfo!.userType?.name ?? 'User'})'
                              : 'No expense account selected',
                          style: defaultTextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  )
                      : DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: widget.type == TransactionType.Reimbursement
                          ? 'Employee Account'
                          : widget.user != null
                          ? "${widget.user!.name}'s Account"
                          : widget.store != null
                          ? "${widget.store!.name}'s Account"
                          : widget.type == TransactionType.OtherLedger
                          ? 'Destination Account'
                          : "My Account",
                      labelStyle: const TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.black87),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none),
                      filled: true,
                      fillColor: Colors.grey[50],
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 12),
                      errorStyle: const TextStyle(color: Colors.red),
                    ),
                    value: _selectedDestinationLedgerId,
                    items: _getFilteredDestinationAccounts().isNotEmpty
                        ? _getFilteredDestinationAccounts()
                        .map((account) => DropdownMenuItem(
                      value: account['ledgerId'] as String,
                      child: Text(
                          '${account['name']} (${account['type']})'),
                    ))
                        .toList()
                        : [
                      const DropdownMenuItem(
                        value: null,
                        child: Text('No accounts available'),
                      ),
                    ],
                    onChanged: _getFilteredDestinationAccounts().isNotEmpty
                        ? (value) {
                      setState(() {
                        _selectedDestinationLedgerId = value;
                        _selectedDestinationUserInfo = _accounts.any(
                                (account) =>
                            account['ledgerId'] == value)
                            ? _accounts.firstWhere(
                                (account) =>
                            account['ledgerId'] == value,
                            orElse: () =>
                            {'ledgerId': null, 'userInfo': null})[
                        'userInfo'] as UserInfo?
                            : null;
                        _ledgerId = _selectedDestinationLedgerId;
                        if (_ledgerId != null &&
                            _selectedDestinationUserInfo != null) {
                          _ledgerCubit.fetchLedger(
                              _ledgerId!,
                              _selectedDestinationUserInfo!.userType);
                        }
                      });
                    }
                        : null,
                    validator: (value) =>
                    value == null && _getFilteredDestinationAccounts().isNotEmpty
                        ? 'Please select a destination account'
                        : null,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  List<Map<String, dynamic>> _getFilteredDestinationAccounts() {
    var filteredAccounts = _accounts;
    if (widget.type != TransactionType.OtherLedger) {
      if (widget.type == TransactionType.Reimbursement) {
        filteredAccounts = filteredAccounts
            .where(
                (account) => account['userInfo'].userType == UserType.Employee)
            .toList();
      }
      return filteredAccounts;
    }
    if (_selectedFilterType != null) {
      filteredAccounts = filteredAccounts
          .where((account) =>
              account['type'] == _selectedFilterType ||
              (_selectedFilterType == 'User' &&
                  account['userInfo'].userType != UserType.Store))
          .toList();
    }
    if (_selectedFilterType == 'User' && _selectedUserType != null) {
      filteredAccounts = filteredAccounts
          .where((account) => account['userInfo'].userType == _selectedUserType)
          .toList();
    }
    if (_selectedUserType == UserType.Employee && _selectedRole != null) {
      filteredAccounts = filteredAccounts
          .where((account) => account['role'] == _selectedRole)
          .toList();
    }
    return filteredAccounts;
  }

  Widget _buildUserDetails() {
    if (widget.user == null &&
        widget.store == null &&
        widget.type != TransactionType.OtherLedger) {
      return Table(
        border: TableBorder.all(color: Colors.grey.shade300),
        columnWidths: const {0: FlexColumnWidth(2), 1: FlexColumnWidth(3)},
        children: [
          TableRow(
            decoration: BoxDecoration(color: Colors.grey.shade100),
            children: [
              Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("User Details",
                      style: defaultTextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold))),
              const Padding(padding: EdgeInsets.all(8.0), child: Text("")),
            ],
          ),
          TableRow(
            children: [
              Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("Name",
                      style: defaultTextStyle(
                          fontSize: 14, fontWeight: FontWeight.w600))),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                    _cachedUserInfo?.name ?? _cachedUserInfo?.userName ?? "N/A",
                    style: defaultTextStyle(fontSize: 14)),
              ),
            ],
          ),
          TableRow(
            children: [
              Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("Email",
                      style: defaultTextStyle(
                          fontSize: 14, fontWeight: FontWeight.w600))),
              Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(_cachedUserInfo?.email ?? "N/A",
                      style: defaultTextStyle(fontSize: 14))),
            ],
          ),
          TableRow(
            children: [
              Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("User Type",
                      style: defaultTextStyle(
                          fontSize: 14, fontWeight: FontWeight.w600))),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(_cachedUserInfo?.userType?.name ?? "customer",
                    style: defaultTextStyle(fontSize: 14)),
              ),
            ],
          ),
          TableRow(
            children: [
              Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("Role",
                      style: defaultTextStyle(
                          fontSize: 14, fontWeight: FontWeight.w600))),
              Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(_cachedUserInfo?.role?.name ?? "user",
                      style: defaultTextStyle(fontSize: 14))),
            ],
          ),
          if (_cachedUserInfo?.userType == UserType.Employee)
            TableRow(
              children: [
                Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text("Daily Wage",
                        style: defaultTextStyle(
                            fontSize: 14, fontWeight: FontWeight.w600))),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    _cachedUserInfo?.dailyWage != null
                        ? "₹${_cachedUserInfo!.dailyWage!.toStringAsFixed(2)}"
                        : "N/A",
                    style: defaultTextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
          if (_cachedUserInfo?.userType == UserType.Accounts)
            TableRow(
              children: [
                Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text("Account Type",
                        style: defaultTextStyle(
                            fontSize: 14, fontWeight: FontWeight.w600))),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(_cachedUserInfo?.accountType?.name ?? "N/A",
                      style: defaultTextStyle(fontSize: 14)),
                ),
              ],
            ),
        ],
      );
    } else if (widget.user != null) {
      return Table(
        border: TableBorder.all(color: Colors.grey.shade300),
        columnWidths: const {0: FlexColumnWidth(2), 1: FlexColumnWidth(3)},
        children: [
          TableRow(
            decoration: BoxDecoration(color: Colors.grey.shade100),
            children: [
              Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("User Details",
                      style: defaultTextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold))),
              const Padding(padding: EdgeInsets.all(8.0), child: Text("")),
            ],
          ),
          TableRow(
            children: [
              Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("Name",
                      style: defaultTextStyle(
                          fontSize: 14, fontWeight: FontWeight.w600))),
              Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(widget.user!.name ?? "N/A",
                      style: defaultTextStyle(fontSize: 14))),
            ],
          ),
          TableRow(
            children: [
              Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("Email",
                      style: defaultTextStyle(
                          fontSize: 14, fontWeight: FontWeight.w600))),
              Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(widget.user!.email ?? "N/A",
                      style: defaultTextStyle(fontSize: 14))),
            ],
          ),
          TableRow(
            children: [
              Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("User Type",
                      style: defaultTextStyle(
                          fontSize: 14, fontWeight: FontWeight.w600))),
              Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(widget.user!.userType?.name ?? "customer",
                      style: defaultTextStyle(fontSize: 14))),
            ],
          ),
          TableRow(
            children: [
              Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("Role",
                      style: defaultTextStyle(
                          fontSize: 14, fontWeight: FontWeight.w600))),
              Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(widget.user!.role?.name ?? "user",
                      style: defaultTextStyle(fontSize: 14))),
            ],
          ),
          if (widget.user!.userType == UserType.Employee)
            TableRow(
              children: [
                Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text("Daily Wage",
                        style: defaultTextStyle(
                            fontSize: 14, fontWeight: FontWeight.w600))),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    widget.user!.dailyWage != null
                        ? "₹${widget.user!.dailyWage!.toStringAsFixed(2)}"
                        : "N/A",
                    style: defaultTextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
          if (widget.user!.userType == UserType.Accounts)
            TableRow(
              children: [
                Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text("Account Type",
                        style: defaultTextStyle(
                            fontSize: 14, fontWeight: FontWeight.w600))),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(widget.user!.accountType?.name ?? "N/A",
                      style: defaultTextStyle(fontSize: 14)),
                ),
              ],
            ),
        ],
      );
    } else if (widget.store != null) {
      return Table(
        border: TableBorder.all(color: Colors.grey.shade300),
        columnWidths: const {0: FlexColumnWidth(2), 1: FlexColumnWidth(3)},
        children: [
          TableRow(
            decoration: BoxDecoration(color: Colors.grey.shade100),
            children: [
              Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("Store Details",
                      style: defaultTextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold))),
              const Padding(padding: EdgeInsets.all(8.0), child: Text("")),
            ],
          ),
          TableRow(
            children: [
              Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("Name",
                      style: defaultTextStyle(
                          fontSize: 14, fontWeight: FontWeight.w600))),
              Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(widget.store!.name,
                      style: defaultTextStyle(fontSize: 14))),
            ],
          ),
          TableRow(
            children: [
              Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("Store Type",
                      style: defaultTextStyle(
                          fontSize: 14, fontWeight: FontWeight.w600))),
              Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(widget.store!.storeType.name,
                      style: defaultTextStyle(fontSize: 14))),
            ],
          ),
          TableRow(
            children: [
              Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("Created By",
                      style: defaultTextStyle(
                          fontSize: 14, fontWeight: FontWeight.w600))),
              Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(widget.store!.createdBy,
                      style: defaultTextStyle(fontSize: 14))),
            ],
          ),
        ],
      );
    } else {
      return Table(
        border: TableBorder.all(color: Colors.grey.shade300),
        columnWidths: const {0: FlexColumnWidth(2), 1: FlexColumnWidth(3)},
        children: [
          TableRow(
            decoration: BoxDecoration(color: Colors.grey.shade100),
            children: [
              Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("Account Details",
                      style: defaultTextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold))),
              const Padding(padding: EdgeInsets.all(8.0), child: Text("")),
            ],
          ),
          TableRow(
            children: [
              Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("Name",
                      style: defaultTextStyle(
                          fontSize: 14, fontWeight: FontWeight.w600))),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  _selectedDestinationUserInfo?.name ??
                      _selectedDestinationUserInfo?.userName ??
                      "Select an account",
                  style: defaultTextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
          TableRow(
            children: [
              Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("Type",
                      style: defaultTextStyle(
                          fontSize: 14, fontWeight: FontWeight.w600))),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  _selectedDestinationUserInfo?.userType?.name ?? "N/A",
                  style: defaultTextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
          if (_selectedDestinationUserInfo?.userType == UserType.Employee)
            TableRow(
              children: [
                Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text("Role",
                        style: defaultTextStyle(
                            fontSize: 14, fontWeight: FontWeight.w600))),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    _selectedDestinationUserInfo?.role?.name ?? "N/A",
                    style: defaultTextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
        ],
      );
    }
  }

  Widget _buildBalanceTable(AccountLedger ledger) {
    final currentDue = ledger.currentDue ?? 0.0;
    final isDuePositive = currentDue >= 0;
    return Table(
      border: TableBorder.all(color: Colors.grey.shade300),
      columnWidths: const {0: FlexColumnWidth(3), 1: FlexColumnWidth(2)},
      children: [
        TableRow(
          decoration: BoxDecoration(color: Colors.grey.shade100),
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                isDuePositive ? "Current Due" : "Current Payable",
                style: defaultTextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.red),
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
    final role = widget.user?.role ?? Role.STORE_ACCOUNTANT;
    final isEmployee = widget.user?.userType == UserType.Employee;
    final isSalesman = role == Role.SALES_MAN;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton(
          onPressed: _accounts.isEmpty ||
                  _selectedSourceLedgerId == null ||
                  _selectedDestinationLedgerId == null
              ? null
              : () {
                  if (_selectionFormKey.currentState!.validate()) {
                    context.read<UserLedgerCubit>().openTransactionPopup(
                          false,
                          role,
                          widget.type == TransactionType.Expense,
                          widget.type == TransactionType.Reimbursement,
                        );
                  }
                },
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: Text(widget.type == TransactionType.Expense
              ? "Add Expense"
              : widget.type == TransactionType.Reimbursement
                  ? "Reimburse"
                  : widget.type == TransactionType.OtherLedger
                      ? "Receive"
                      : isEmployee
                          ? "Receive Cash"
                          : isSalesman
                              ? "Collect Cash"
                              : "Receive"),
        ),
        ElevatedButton(
          onPressed: _accounts.isEmpty ||
                  _selectedSourceLedgerId == null ||
                  _selectedDestinationLedgerId == null
              ? null
              : () {
                  if (_selectionFormKey.currentState!.validate()) {
                    context.read<UserLedgerCubit>().openTransactionPopup(
                          true,
                          role,
                          widget.type == TransactionType.Expense,
                          widget.type == TransactionType.Reimbursement,
                        );
                  }
                },
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: Text(widget.type == TransactionType.Expense
              ? "Reverse Expense"
              : widget.type == TransactionType.Reimbursement
                  ? "Reverse Reimbursement"
                  : widget.type == TransactionType.OtherLedger
                      ? "Pay"
                      : isEmployee
                          ? "Pay Cash"
                          : isSalesman
                              ? "Pay Cash"
                              : "Pay Cash/Amount"),
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
                side: BorderSide(color: Colors.grey.shade200)),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 4,
                      offset: const Offset(0, 2))
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
                              color: txn.type == "Debit"
                                  ? Colors.red
                                  : Colors.green,
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
                            Text("Purpose: ${txn.purpose}",
                                style: defaultTextStyle(
                                    fontSize: 14, color: Colors.grey.shade600)),
                          if (txn.typeOfPurpose != null)
                            Text("Type: ${txn.typeOfPurpose}",
                                style: defaultTextStyle(
                                    fontSize: 14, color: Colors.grey.shade600)),
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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(6)),
                      child: Text(
                        txn.createdAt.toString().split(' ')[0],
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

  Future<void> _showTransactionPopup(
      BuildContext context, TransactionPopupOpened state) async {
    if (_ledgerId == null &&
        (widget.user?.accountLedgerId == null &&
            widget.store?.accountLedgerId == null)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Ledger ID not available. Please wait or try again.")));
      _isPopupOpen = false;
      return;
    }

    if (_selectedSourceLedgerId == null ||
        _selectedDestinationLedgerId == null ||
        _selectedSourceUserInfo == null ||
        _selectedDestinationUserInfo == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Please select source and destination accounts")));
      _isPopupOpen = false;
      return;
    }

    final Map<String, List<String>> purposeTypeMap =
        Map.from(state.purposeTypeMap);
    final sourceRole = _selectedSourceUserInfo?.role;
    final isAccountantOrAdmin = sourceRole == Role.COMPANY_ACCOUNTANT ||
        sourceRole == Role.COMPANY_ADMIN;
    final isSalesman = sourceRole == Role.SALES_MAN;

    final requiredPurposes = widget.type == TransactionType.Reimbursement
        ? ['Reimbursement']
        : widget.type == TransactionType.Expense
            ? ['Expenses']
            : state.isDebit
                ? (isAccountantOrAdmin
                    ? ['Salary', 'Expenses', 'Other']
                    : ['Transfer Cash', 'Other'])
                : ['Cash of Sales', 'Other'];

    for (var purpose in requiredPurposes) {
      if (!purposeTypeMap.containsKey(purpose)) {
        purposeTypeMap[purpose] = ['Cash'];
      }
    }

    String? validSelectedPurpose = state.selectedPurpose;
    if (validSelectedPurpose != null &&
        !requiredPurposes.contains(validSelectedPurpose)) {
      validSelectedPurpose = requiredPurposes.first;
      context
          .read<UserLedgerCubit>()
          .updatePurposeSelection(validSelectedPurpose);
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return BlocProvider.value(
          value: _ledgerCubit,
          child: AlertDialog(
            title: Text(widget.type == TransactionType.Expense
                ? "Add Expense"
                : widget.type == TransactionType.Reimbursement
                    ? "Reimburse"
                    : widget.type == TransactionType.OtherLedger
                        ? state.isDebit
                            ? "Pay"
                            : "Receive"
                        : state.isDebit
                            ? (isSalesman ? "Pay Cash" : "Pay Cash/Amount")
                            : (isSalesman ? "Collect Cash" : "Credit")),
            content: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Source: ${_accounts.firstWhere((account) => account['ledgerId'] == _selectedSourceLedgerId, orElse: () => {
                            'name': 'Unknown',
                            'type': ''
                          })['name']} (${_accounts.firstWhere((account) => account['ledgerId'] == _selectedSourceLedgerId, orElse: () => {'name': '', 'type': 'Unknown'})['type']})',
                      style: defaultTextStyle(fontSize: 14),
                    ),
                    Text(
                      'Destination: ${_accounts.firstWhere((account) => account['ledgerId'] == _selectedDestinationLedgerId, orElse: () => {
                            'name': 'Unknown',
                            'type': ''
                          })['name']} (${_accounts.firstWhere((account) => account['ledgerId'] == _selectedDestinationLedgerId, orElse: () => {'name': '', 'type': 'Unknown'})['type']})',
                      style: defaultTextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: amountController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(labelText: "Amount"),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Amount is required";
                        }
                        final amount = double.tryParse(value);
                        if (amount == null || amount <= 0) {
                          return "Enter a valid positive amount";
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: billNumberController,
                      decoration: const InputDecoration(
                          labelText: "Bill Number (Optional)"),
                    ),
                    BlocBuilder<UserLedgerCubit, AccountLedgerState>(
                      buildWhen: (previous, current) =>
                          current is TransactionPopupOpened &&
                          previous is TransactionPopupOpened &&
                          current.selectedPurpose != previous.selectedPurpose,
                      builder: (context, popupState) {
                        if (popupState is TransactionPopupOpened) {
                          final items = purposeTypeMap.keys
                              .where((purpose) =>
                                  requiredPurposes.contains(purpose))
                              .map((purpose) => DropdownMenuItem(
                                  value: purpose, child: Text(purpose)))
                              .toList();
                          return DropdownButtonFormField<String>(
                            value: popupState.selectedPurpose != null &&
                                    requiredPurposes
                                        .contains(popupState.selectedPurpose)
                                ? popupState.selectedPurpose
                                : null,
                            decoration:
                                const InputDecoration(labelText: "Purpose"),
                            items: items,
                            onChanged: items.isNotEmpty
                                ? (value) => context
                                    .read<UserLedgerCubit>()
                                    .updatePurposeSelection(value)
                                : null,
                            validator: (value) =>
                                value == null ? "Purpose is required" : null,
                            hint: items.isEmpty
                                ? const Text("No purposes available")
                                : null,
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
                              current.selectedPurpose !=
                                  previous.selectedPurpose),
                      builder: (context, popupState) {
                        if (popupState is TransactionPopupOpened) {
                          final items = popupState.selectedPurpose != null &&
                                  purposeTypeMap
                                      .containsKey(popupState.selectedPurpose)
                              ? purposeTypeMap[popupState.selectedPurpose]!
                                  .map((type) => DropdownMenuItem(
                                      value: type, child: Text(type)))
                                  .toList()
                              : <DropdownMenuItem<String>>[];
                          return DropdownButtonFormField<String>(
                            value: popupState.selectedPurpose != null &&
                                    purposeTypeMap
                                        .containsKey(popupState.selectedPurpose)
                                ? popupState.selectedType
                                : null,
                            decoration:
                                const InputDecoration(labelText: "Type"),
                            items: items,
                            onChanged: items.isNotEmpty
                                ? (value) => context
                                    .read<UserLedgerCubit>()
                                    .updateTypeSelection(value)
                                : null,
                            validator: (value) =>
                                items.isNotEmpty && value == null
                                    ? "Type is required"
                                    : null,
                            hint: items.isEmpty
                                ? const Text("No types available")
                                : null,
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                    TextFormField(
                      controller: remarksController,
                      maxLength: 500,
                      decoration: InputDecoration(
                        labelText: state.isDebit
                            ? "Remarks (Optional)"
                            : "Remarks (Required for Credit)",
                        counterText: "",
                      ),
                      validator: (value) => state.isDebit
                          ? null
                          : (value == null || value.isEmpty)
                              ? "Remarks are required for Credit"
                              : null,
                    ),
                    BlocBuilder<UserLedgerCubit, AccountLedgerState>(
                      buildWhen: (previous, current) =>
                          current is TransactionPopupOpened &&
                          previous is TransactionPopupOpened &&
                          current.errorMessage != previous.errorMessage,
                      builder: (context, popupState) {
                        if (popupState is TransactionPopupOpened &&
                            popupState.errorMessage != null) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(popupState.errorMessage!,
                                style: const TextStyle(
                                    color: Colors.red, fontSize: 12)),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ],
                ),
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
                  if (!_formKey.currentState!.validate()) {
                    return;
                  }
                  final currentState = context.read<UserLedgerCubit>().state;
                  String? selectedType;
                  String? selectedPurpose;
                  if (currentState is TransactionPopupOpened) {
                    selectedType = currentState.selectedType;
                    selectedPurpose = currentState.selectedPurpose;
                  }
                  if (widget.type == TransactionType.Expense) {
                    context.read<UserLedgerCubit>().addTransactionWithSource(
                          ledgerId: _selectedDestinationLedgerId!,
                          sourceLedgerId: _selectedSourceLedgerId!,
                          destinationUserInfo: _selectedDestinationUserInfo!,
                          sourceUserInfo: _selectedSourceUserInfo!,
                          amount: double.parse(amountController.text),
                          type: "Credit",
                          billNumber: billNumberController.text.isEmpty
                              ? null
                              : billNumberController.text,
                          purpose: selectedPurpose,
                          typeOfPurpose: selectedType,
                          remarks: remarksController.text.isEmpty
                              ? null
                              : remarksController.text,
                          userType: _selectedDestinationUserInfo!.userType,
                          userRole: widget.user?.role ?? Role.STORE_ACCOUNTANT,
                          isExpense: true,
                          isReimbursement: false,
                          updateBalance: true,
                        );
                    context.read<UserLedgerCubit>().addTransactionWithSource(
                          ledgerId: _selectedSourceLedgerId!,
                          sourceLedgerId: _selectedDestinationLedgerId!,
                          destinationUserInfo: _selectedSourceUserInfo!,
                          sourceUserInfo: _selectedDestinationUserInfo!,
                          amount: double.parse(amountController.text),
                          type: "Credit",
                          billNumber: billNumberController.text.isEmpty
                              ? null
                              : billNumberController.text,
                          purpose: selectedPurpose,
                          typeOfPurpose: selectedType,
                          remarks: remarksController.text.isEmpty
                              ? null
                              : 'Expense payment: ${remarksController.text}',
                          userType: _selectedSourceUserInfo!.userType,
                          userRole: widget.user?.role ?? Role.STORE_ACCOUNTANT,
                          isExpense: true,
                          isReimbursement: false,
                          updateBalance: true,
                        );
                  } else {
                    context.read<UserLedgerCubit>().addTransactionWithSource(
                          ledgerId: _selectedDestinationLedgerId!,
                          sourceLedgerId: _selectedSourceLedgerId!,
                          destinationUserInfo: _selectedDestinationUserInfo!,
                          sourceUserInfo: _selectedSourceUserInfo!,
                          amount: double.parse(amountController.text),
                          type: state.isDebit ? "Debit" : "Credit",
                          billNumber: billNumberController.text.isEmpty
                              ? null
                              : billNumberController.text,
                          purpose: selectedPurpose,
                          typeOfPurpose: selectedType,
                          remarks: remarksController.text.isEmpty
                              ? null
                              : remarksController.text,
                          userType: _selectedDestinationUserInfo!.userType,
                          userRole: widget.user?.role ?? Role.STORE_ACCOUNTANT,
                          isExpense: widget.type == TransactionType.Expense,
                          isReimbursement:
                              widget.type == TransactionType.Reimbursement,
                          updateBalance:
                              selectedPurpose == 'Salary' ? false : true,
                        );
                  }
                  _isPopupOpen = false;
                  Navigator.pop(dialogContext);
                  amountController.clear();
                  billNumberController.clear();
                  remarksController.clear();
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
