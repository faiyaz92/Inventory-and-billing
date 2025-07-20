import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:requirment_gathering_app/company_admin_module/data/ledger/account_ledger_model.dart';
import 'package:requirment_gathering_app/company_admin_module/data/ledger/account_transaction_model.dart';
import 'package:requirment_gathering_app/company_admin_module/presentation/ledger/account_ledger_state.dart';
import 'package:requirment_gathering_app/company_admin_module/service/account_ledger_service.dart';
import 'package:requirment_gathering_app/company_admin_module/service/stock_service.dart';
import 'package:requirment_gathering_app/company_admin_module/service/user_services.dart';
import 'package:requirment_gathering_app/core_module/repository/account_repository.dart';
import 'package:requirment_gathering_app/super_admin_module/data/user_info.dart';
import 'package:requirment_gathering_app/super_admin_module/utils/roles.dart';
import 'package:requirment_gathering_app/super_admin_module/utils/user_type.dart';
import 'package:requirment_gathering_app/user_module/services/customer_company_service.dart';
import 'package:requirment_gathering_app/company_admin_module/repositories/stock_repository.dart';

class UserLedgerCubit extends Cubit<AccountLedgerState> {
  final IAccountLedgerService _accountLedgerService;
  final AccountRepository _accountRepository;
  final CustomerCompanyService _companyService;
  final UserServices _userService;
  final StockService _stockService;

  UserLedgerCubit(this._accountLedgerService, this._accountRepository,
      this._companyService, this._userService, this._stockService)
      : super(AccountLedgerInitial());

  Future<void> ensureLedger(
      String? ledgerId, UserType? userType, UserInfo user) async {
    if (ledgerId == null || ledgerId.isEmpty) {
      emit(AccountLedgerFetching());
      try {
        if (user.userId == null || user.companyId == null) {
          emit(const AccountLedgerError("User ID or Company ID missing"));
          return;
        }
        final newLedger = AccountLedger(
          totalOutstanding: 0,
          promiseAmount: null,
          promiseDate: null,
          transactions: [],
          entityType: userType ?? UserType.Customer,
        );
        final newLedgerId = await _accountLedgerService.createLedger(newLedger);
        final updatedUserInfo = user.copyWith(accountLedgerId: newLedgerId);
        await _userService.updateUser(updatedUserInfo);
        await fetchLedger(newLedgerId, userType);
      } catch (e) {
        emit(AccountLedgerError("Failed to create or update ledger: $e"));
        return;
      }
    } else {
      await fetchLedger(ledgerId, userType);
    }
  }

  Future<void> ensureLedgerForStore(String? ledgerId, StoreDto store) async {
    if (ledgerId == null || ledgerId.isEmpty) {
      emit(AccountLedgerFetching());
      try {
        if (store.storeId.isEmpty) {
          emit(const AccountLedgerError("Store ID or Company ID missing"));
          return;
        }
        final newLedger = AccountLedger(
          totalOutstanding: 0,
          promiseAmount: null,
          promiseDate: null,
          transactions: [],
          entityType: UserType.Store,
        );
        final newLedgerId = await _accountLedgerService.createLedger(newLedger);
        final updatedStore = store.copyWith(accountLedgerId: newLedgerId);
        await _stockService.updateStore(updatedStore);
        await fetchLedger(newLedgerId, UserType.Store);
      } catch (e) {
        emit(AccountLedgerError("Failed to create or update ledger for store: $e"));
        return;
      }
    } else {
      await fetchLedger(ledgerId, UserType.Store);
    }
  }

  Future<void> fetchLedger(String? ledgerId, UserType? userType) async {
    if (ledgerId == null || ledgerId.isEmpty) {
      emit(const AccountLedgerError("Invalid ledger ID"));
      return;
    }
    emit(AccountLedgerFetching());
    try {
      final ledger = await _accountLedgerService.getLedger(ledgerId);
      final sortedTransactions =
      List<AccountTransactionModel>.from(ledger.transactions ?? [])
        ..sort((a, b) => b.createdAt!.compareTo(a.createdAt));
      emit(AccountLedgerUpdated(
          ledger.copyWith(transactions: sortedTransactions)));
    } catch (e) {
      emit(AccountLedgerError("Failed to fetch ledger: $e"));
    }
  }

  Future<void> openTransactionPopup(
      bool isDebit, Role? userRole, bool isExpense, bool isReimbursement) async {
    try {
      final result = await _companyService.getSettings();
      final purposeTypeMap = result.fold<Map<String, List<String>>>(
            (error) => {
          'Salary': ['Cash'],
          'Expenses': ['Cash'],
          'Other': ['Cash'],
          'Reimbursement': ['Cash'],
          'Material': [],
          'Labor': [],
        },
            (settings) {
          final map = Map<String, List<String>>.from(settings.purposeTypeMap);
          map.putIfAbsent('Salary', () => ['Cash']);
          map.putIfAbsent('Expenses', () => ['Cash']);
          map.putIfAbsent('Other', () => ['Cash']);
          map.putIfAbsent('Reimbursement', () => ['Cash']);
          map.putIfAbsent('Material', () => []);
          map.putIfAbsent('Labor', () => []);
          if (map.isEmpty) {
            return {
              'Salary': ['Cash'],
              'Expenses': ['Cash'],
              'Other': ['Cash'],
              'Reimbursement': ['Cash'],
              'Material': [],
              'Labor': [],
            };
          }
          final validatedMap = <String, List<String>>{};
          for (var entry in map.entries) {
            validatedMap[entry.key] = (entry.value).cast<String>();
          }
          return validatedMap;
        },
      );
      String? defaultPurpose = isReimbursement
          ? 'Reimbursement'
          : isExpense
          ? 'Expenses'
          : userRole == Role.SALES_MAN && !isDebit
          ? null
          : (userRole == Role.COMPANY_ACCOUNTANT ||
          userRole == Role.COMPANY_ADMIN) &&
          !isDebit
          ? 'Reimbursement'
          : purposeTypeMap.isNotEmpty
          ? purposeTypeMap.keys.first
          : null;
      String? defaultType = defaultPurpose != null &&
          purposeTypeMap[defaultPurpose]?.isNotEmpty == true
          ? purposeTypeMap[defaultPurpose]!.first
          : null;
      emit(TransactionPopupOpened(
        isDebit: isDebit,
        companyType: null,
        purposeTypeMap: purposeTypeMap,
        selectedPurpose: defaultPurpose,
        selectedType: defaultType,
        isInitialOpen: true,
      ));
    } catch (e) {
      emit(TransactionPopupOpened(
        isDebit: isDebit,
        companyType: null,
        purposeTypeMap: {
          'Salary': ['Cash'],
          'Expenses': ['Cash'],
          'Other': ['Cash'],
          'Reimbursement': ['Cash'],
          'Material': [],
          'Labor': [],
        },
        selectedPurpose: isReimbursement
            ? 'Reimbursement'
            : isExpense
            ? 'Expenses'
            : userRole == Role.SALES_MAN && !isDebit
            ? null
            : (userRole == Role.COMPANY_ACCOUNTANT ||
            userRole == Role.COMPANY_ADMIN) &&
            !isDebit
            ? 'Reimbursement'
            : 'Salary',
        selectedType: isReimbursement || isExpense ? 'Cash' : null,
        errorMessage: "Failed to load purposes: $e",
        isInitialOpen: true,
      ));
    }
  }

  Future<void> addTransaction({
    required String ledgerId,
    required double amount,
    required String type,
    String? billNumber,
    String? purpose,
    String? typeOfPurpose,
    String? remarks,
    required UserType? userType,
  }) async {
    emit(AccountLedgerPosting());
    try {
      if (amount <= 0) {
        emit(const TransactionAddFailed("Amount must be positive"));
        return;
      }
      if (remarks != null && remarks.length > 500) {
        emit(
            const TransactionAddFailed("Remarks cannot exceed 500 characters"));
        return;
      }
      final loggedIn = await _accountRepository.getUserInfo();
      final transaction = AccountTransactionModel(
        amount: amount,
        type: type,
        billNumber: billNumber?.isNotEmpty == true ? billNumber : null,
        createdAt: DateTime.now(),
        receivedBy: loggedIn?.userId ?? '',
        purpose: purpose,
        typeOfPurpose: typeOfPurpose,
        remarks: remarks?.isNotEmpty == true ? remarks : null,
      );
      final currentLedger = await _accountLedgerService.getLedger(ledgerId);
      double updatedDue = currentLedger.currentDue ?? 0.0;
      double updatedOutstanding = currentLedger.totalOutstanding;
      updatedDue += (type == "Debit" ? amount : -amount);
      updatedOutstanding += (type == "Debit" ? amount : -amount);
      final updatedLedger = currentLedger.copyWith(
        totalOutstanding: updatedOutstanding,
        currentDue: updatedDue,
        currentPayable: null,
        transactions: [...?currentLedger.transactions, transaction],
      );
      await _accountLedgerService.updateLedger(ledgerId, updatedLedger);
      await _accountLedgerService.addTransaction(ledgerId, transaction);
      emit(const TransactionSuccess("Transaction added successfully"));
      await fetchLedger(ledgerId, userType);
    } catch (e) {
      emit(TransactionAddFailed("Failed to add transaction: $e"));
    }
  }

  // Future<void> addTransactionWithSource({
  //   required String ledgerId,
  //   required String sourceLedgerId,
  //   UserInfo? destinationUserInfo,
  //   UserInfo? sourceUserInfo,
  //   required double amount,
  //   required String type,
  //   String? billNumber,
  //   String? purpose,
  //   String? typeOfPurpose,
  //   String? remarks,
  //   required UserType? userType,
  //   required Role? userRole,
  //   bool isExpense = false,
  //   bool isReimbursement = false,
  // }) async {
  //   emit(AccountLedgerPosting());
  //   try {
  //     if (amount <= 0) {
  //       emit(const TransactionAddFailed("Amount must be positive"));
  //       return;
  //     }
  //     if (remarks != null && remarks.length > 500) {
  //       emit(
  //           const TransactionAddFailed("Remarks cannot exceed 500 characters"));
  //       return;
  //     }
  //     final loggedIn = await _accountRepository.getUserInfo();
  //     if (loggedIn?.accountLedgerId == null) {
  //       emit(const TransactionAddFailed("Logged-in user ledger ID not found"));
  //       return;
  //     }
  //
  //     if (ledgerId == sourceLedgerId) {
  //       emit(const TransactionAddFailed(
  //           "Source and destination ledgers cannot be the same"));
  //       return;
  //     }
  //
  //     // Fallback for names
  //     final destinationName =
  //         destinationUserInfo?.name ?? destinationUserInfo?.userName ?? 'User';
  //     final sourceName = sourceUserInfo?.name ??
  //         sourceUserInfo?.userName ??
  //         loggedIn?.userName ??
  //         'User';
  //
  //     // Adjust typeOfPurpose
  //     final effectiveTypeOfPurpose =
  //     purpose != null && ['Salary', 'Expenses', 'Other', 'Reimbursement'].contains(purpose)
  //         ? 'Cash'
  //         : typeOfPurpose ?? 'Internal';
  //
  //     if (isReimbursement) {
  //       // Reimbursement: Three entries (Debit User, Debit Finance, Credit Expense)
  //       final expenseAccount = (await _userService.getUsersFromTenantCompany())
  //           .firstWhere(
  //               (user) => user.accountType == AccountType.Expense,
  //           orElse: () => UserInfo());
  //       if (expenseAccount.accountLedgerId == null) {
  //         emit(const TransactionAddFailed("Expense account not found"));
  //         return;
  //       }
  //
  //       // 1. Debit User (destination)
  //       final userTransaction = AccountTransactionModel(
  //         amount: amount,
  //         type: 'Debit',
  //         billNumber: billNumber?.isNotEmpty == true ? billNumber : null,
  //         createdAt: DateTime.now(),
  //         receivedBy: loggedIn?.userId ?? '',
  //         purpose: 'Reimbursement',
  //         typeOfPurpose: effectiveTypeOfPurpose,
  //         remarks: remarks?.isNotEmpty == true
  //             ? remarks
  //             : 'Reimbursement to $destinationName',
  //       );
  //       final userLedger = await _accountLedgerService.getLedger(ledgerId);
  //       double userUpdatedDue = userLedger.currentDue ?? 0.0;
  //       double userUpdatedOutstanding = userLedger.totalOutstanding;
  //       userUpdatedDue += amount;
  //       userUpdatedOutstanding += amount;
  //       final updatedUserLedger = userLedger.copyWith(
  //         totalOutstanding: userUpdatedOutstanding,
  //         currentDue: userUpdatedDue,
  //         currentPayable: null,
  //         transactions: [...?userLedger.transactions, userTransaction],
  //       );
  //       await _accountLedgerService.updateLedger(ledgerId, updatedUserLedger);
  //       await _accountLedgerService.addTransaction(ledgerId, userTransaction);
  //
  //       // 2. Debit Finance (source)
  //       final financeTransaction = AccountTransactionModel(
  //         amount: amount,
  //         type: 'Debit',
  //         billNumber: billNumber?.isNotEmpty == true ? billNumber : null,
  //         createdAt: DateTime.now(),
  //         receivedBy: loggedIn?.userId ?? '',
  //         purpose: 'Reimbursement',
  //         typeOfPurpose: effectiveTypeOfPurpose,
  //         remarks: remarks?.isNotEmpty == true
  //             ? remarks
  //             : 'Reimbursement payment to $destinationName',
  //       );
  //       final financeLedger = await _accountLedgerService.getLedger(sourceLedgerId);
  //       double financeUpdatedDue = financeLedger.currentDue ?? 0.0;
  //       double financeUpdatedOutstanding = financeLedger.totalOutstanding;
  //       financeUpdatedDue += amount;
  //       financeUpdatedOutstanding += amount;
  //       final updatedFinanceLedger = financeLedger.copyWith(
  //         totalOutstanding: financeUpdatedOutstanding,
  //         currentDue: financeUpdatedDue,
  //         currentPayable: null,
  //         transactions: [...?financeLedger.transactions, financeTransaction],
  //       );
  //       await _accountLedgerService.updateLedger(sourceLedgerId, updatedFinanceLedger);
  //       await _accountLedgerService.addTransaction(sourceLedgerId, financeTransaction);
  //
  //       // 3. Credit Expense
  //       final expenseTransaction = AccountTransactionModel(
  //         amount: amount,
  //         type: 'Credit',
  //         billNumber: billNumber?.isNotEmpty == true ? billNumber : null,
  //         createdAt: DateTime.now(),
  //         receivedBy: loggedIn?.userId ?? '',
  //         purpose: 'Reimbursement',
  //         typeOfPurpose: effectiveTypeOfPurpose,
  //         remarks: remarks?.isNotEmpty == true
  //             ? remarks
  //             : 'Cleared expense for $destinationName',
  //       );
  //       final expenseLedger =
  //       await _accountLedgerService.getLedger(expenseAccount.accountLedgerId!);
  //       double expenseUpdatedDue = expenseLedger.currentDue ?? 0.0;
  //       double expenseUpdatedOutstanding = expenseLedger.totalOutstanding;
  //       expenseUpdatedDue -= amount;
  //       expenseUpdatedOutstanding -= amount;
  //       final updatedExpenseLedger = expenseLedger.copyWith(
  //         totalOutstanding: expenseUpdatedOutstanding,
  //         currentDue: expenseUpdatedDue,
  //         currentPayable: null,
  //         transactions: [...?expenseLedger.transactions, expenseTransaction],
  //       );
  //       await _accountLedgerService.updateLedger(
  //           expenseAccount.accountLedgerId!, updatedExpenseLedger);
  //       await _accountLedgerService.addTransaction(
  //           expenseAccount.accountLedgerId!, expenseTransaction);
  //
  //       emit(const TransactionSuccess("Reimbursement added successfully"));
  //       await fetchLedger(ledgerId, userType);
  //     } else {
  //       // Expense or Regular Transaction
  //       final transaction = AccountTransactionModel(
  //         amount: amount,
  //         type: type,
  //         billNumber: billNumber?.isNotEmpty == true ? billNumber : null,
  //         createdAt: DateTime.now(),
  //         receivedBy: loggedIn?.userId ?? '',
  //         purpose: purpose,
  //         typeOfPurpose: effectiveTypeOfPurpose,
  //         remarks: remarks?.isNotEmpty == true
  //             ? remarks
  //             : isExpense
  //             ? 'Expense by $sourceName'
  //             : 'Transaction for $destinationName ($ledgerId)',
  //       );
  //       final currentLedger = await _accountLedgerService.getLedger(ledgerId);
  //       double updatedDue = currentLedger.currentDue ?? 0.0;
  //       double updatedOutstanding = currentLedger.totalOutstanding;
  //       updatedDue += (type == "Debit" ? amount : -amount);
  //       updatedOutstanding += (type == "Debit" ? amount : -amount);
  //       final updatedLedger = currentLedger.copyWith(
  //         totalOutstanding: updatedOutstanding,
  //         currentDue: updatedDue,
  //         currentPayable: null,
  //         transactions: [...?currentLedger.transactions, transaction],
  //       );
  //       await _accountLedgerService.updateLedger(ledgerId, updatedLedger);
  //       await _accountLedgerService.addTransaction(ledgerId, transaction);
  //
  //       if (!isExpense) {
  //         // Source ledger transaction for non-expense
  //         final sourceTransaction = AccountTransactionModel(
  //           amount: amount,
  //           type: type == "Debit" ? "Credit" : "Debit",
  //           billNumber: billNumber?.isNotEmpty == true ? billNumber : null,
  //           createdAt: DateTime.now(),
  //           receivedBy: loggedIn?.userId ?? '',
  //           purpose: purpose ?? 'Transaction',
  //           typeOfPurpose: effectiveTypeOfPurpose,
  //           remarks: remarks?.isNotEmpty == true
  //               ? 'Corresponding ${type.toLowerCase()} for $destinationName ($ledgerId): $remarks'
  //               : 'Corresponding ${type.toLowerCase()} for $destinationName ($ledgerId) from $sourceName',
  //         );
  //         final sourceLedger = await _accountLedgerService.getLedger(sourceLedgerId);
  //         double sourceUpdatedDue = double.parse(
  //             (sourceLedger.currentDue ?? 0.0).toStringAsFixed(2));
  //         double sourceUpdatedOutstanding = sourceLedger.totalOutstanding;
  //         sourceUpdatedDue +=
  //         (sourceTransaction.type == "Debit" ? amount : -amount);
  //         sourceUpdatedOutstanding +=
  //         (sourceTransaction.type == "Debit" ? amount : -amount);
  //         final updatedSourceLedger = sourceLedger.copyWith(
  //           totalOutstanding: sourceUpdatedOutstanding,
  //           currentDue: sourceUpdatedDue,
  //           currentPayable: null,
  //           transactions: [...?sourceLedger.transactions, sourceTransaction],
  //         );
  //         await _accountLedgerService.updateLedger(
  //             sourceLedgerId, updatedSourceLedger);
  //         await _accountLedgerService.addTransaction(
  //             sourceLedgerId, sourceTransaction);
  //       }
  //
  //       emit(const TransactionSuccess("Transaction added successfully"));
  //       await fetchLedger(ledgerId, userType);
  //     }
  //   } catch (e) {
  //     emit(TransactionAddFailed("Failed to add transaction: $e"));
  //   }
  // }
  Future<void> addTransactionWithSource({
    required String ledgerId,
    required String sourceLedgerId,
    UserInfo? destinationUserInfo,
    UserInfo? sourceUserInfo,
    required double amount,
    required String type,
    String? billNumber,
    String? purpose,
    String? typeOfPurpose,
    String? remarks,
    required UserType? userType,
    required Role? userRole,
    bool isExpense = false,
    bool isReimbursement = false,
    bool updateBalance = true,
  }) async {
    emit(AccountLedgerPosting());
    try {
      if (amount <= 0) {
        emit(const TransactionAddFailed("Amount must be positive"));
        return;
      }
      if (remarks != null && remarks.length > 500) {
        emit(const TransactionAddFailed("Remarks cannot exceed 500 characters"));
        return;
      }
      final loggedIn = await _accountRepository.getUserInfo();
      if (loggedIn?.accountLedgerId == null) {
        emit(const TransactionAddFailed("Logged-in user ledger ID not found"));
        return;
      }
      if (ledgerId == sourceLedgerId) {
        emit(const TransactionAddFailed("Source and destination ledgers cannot be the same"));
        return;
      }

      final destinationName = destinationUserInfo?.name ?? destinationUserInfo?.userName ?? 'User';
      final sourceName = sourceUserInfo?.name ?? sourceUserInfo?.userName ?? loggedIn?.userName ?? 'User';
      final effectiveTypeOfPurpose = purpose != null && ['Salary', 'Expenses', 'Other', 'Reimbursement'].contains(purpose)
          ? 'Cash'
          : typeOfPurpose ?? 'Internal';

      if (isReimbursement) {
        final expenseAccount = (await _userService.getUsersFromTenantCompany()).firstWhere(
              (user) => user.accountType == AccountType.Expense,
          orElse: () => UserInfo(),
        );
        if (expenseAccount.accountLedgerId == null) {
          emit(const TransactionAddFailed("Expense account not found"));
          return;
        }

        // 1. Debit User (destination)
        final userTransaction = AccountTransactionModel(
          amount: amount,
          type: 'Debit',
          billNumber: billNumber?.isNotEmpty == true ? billNumber : null,
          createdAt: DateTime.now(),
          receivedBy: loggedIn?.userId ?? '',
          purpose: 'Reimbursement',
          typeOfPurpose: effectiveTypeOfPurpose,
          remarks: remarks?.isNotEmpty == true ? remarks : 'Reimbursement to $destinationName',
        );
        final userLedger = await _accountLedgerService.getLedger(ledgerId);
        double userUpdatedDue = userLedger.currentDue ?? 0.0;
        double userUpdatedOutstanding = userLedger.totalOutstanding;
        if (updateBalance) {
          userUpdatedDue += amount;
          userUpdatedOutstanding += amount;
        }
        final updatedUserLedger = userLedger.copyWith(
          totalOutstanding: userUpdatedOutstanding,
          currentDue: userUpdatedDue,
          currentPayable: null,
          transactions: [...?userLedger.transactions, userTransaction],
        );
        await _accountLedgerService.updateLedger(ledgerId, updatedUserLedger);
        await _accountLedgerService.addTransaction(ledgerId, userTransaction);

        // 2. Debit Finance (source)
        final financeTransaction = AccountTransactionModel(
          amount: amount,
          type: 'Debit',
          billNumber: billNumber?.isNotEmpty == true ? billNumber : null,
          createdAt: DateTime.now(),
          receivedBy: loggedIn?.userId ?? '',
          purpose: 'Reimbursement',
          typeOfPurpose: effectiveTypeOfPurpose,
          remarks: remarks?.isNotEmpty == true ? remarks : 'Reimbursement payment to $destinationName',
        );
        final financeLedger = await _accountLedgerService.getLedger(sourceLedgerId);
        double financeUpdatedDue = financeLedger.currentDue ?? 0.0;
        double financeUpdatedOutstanding = financeLedger.totalOutstanding;
        financeUpdatedDue += amount;
        financeUpdatedOutstanding += amount;
        final updatedFinanceLedger = financeLedger.copyWith(
          totalOutstanding: financeUpdatedOutstanding,
          currentDue: financeUpdatedDue,
          currentPayable: null,
          transactions: [...?financeLedger.transactions, financeTransaction],
        );
        await _accountLedgerService.updateLedger(sourceLedgerId, updatedFinanceLedger);
        await _accountLedgerService.addTransaction(sourceLedgerId, financeTransaction);

        // 3. Credit Expense
        final expenseTransaction = AccountTransactionModel(
          amount: amount,
          type: 'Credit',
          billNumber: billNumber?.isNotEmpty == true ? billNumber : null,
          createdAt: DateTime.now(),
          receivedBy: loggedIn?.userId ?? '',
          purpose: 'Reimbursement',
          typeOfPurpose: effectiveTypeOfPurpose,
          remarks: remarks?.isNotEmpty == true ? remarks : 'Cleared expense for $destinationName',
        );
        final expenseLedger = await _accountLedgerService.getLedger(expenseAccount.accountLedgerId!);
        double expenseUpdatedDue = expenseLedger.currentDue ?? 0.0;
        double expenseUpdatedOutstanding = expenseLedger.totalOutstanding;
        expenseUpdatedDue -= amount;
        expenseUpdatedOutstanding -= amount;
        final updatedExpenseLedger = expenseLedger.copyWith(
          totalOutstanding: expenseUpdatedOutstanding,
          currentDue: expenseUpdatedDue,
          currentPayable: null,
          transactions: [...?expenseLedger.transactions, expenseTransaction],
        );
        await _accountLedgerService.updateLedger(expenseAccount.accountLedgerId!, updatedExpenseLedger);
        await _accountLedgerService.addTransaction(expenseAccount.accountLedgerId!, expenseTransaction);

        emit(const TransactionSuccess("Reimbursement added successfully"));
        await fetchLedger(ledgerId, userType);
      } else if (purpose == 'Salary' && type == 'Debit') {
        // Salary: Credit to destination (receive money), Debit to destination (salary expense), Credit to source
        // 1. Credit Destination (money received)
        final creditTransaction = AccountTransactionModel(
          amount: amount,
          type: 'Credit',
          billNumber: billNumber?.isNotEmpty == true ? billNumber : null,
          createdAt: DateTime.now(),
          receivedBy: loggedIn?.userId ?? '',
          purpose: purpose,
          typeOfPurpose: effectiveTypeOfPurpose,
          remarks: remarks?.isNotEmpty == true ?  ' $remarks (Salary Received)' : 'Salary payment received by $destinationName',
        );
        final destinationLedger = await _accountLedgerService.getLedger(ledgerId);
        double destinationUpdatedDue = destinationLedger.currentDue ?? 0.0;
        double destinationUpdatedOutstanding = destinationLedger.totalOutstanding;
        if (updateBalance) {
          destinationUpdatedDue -= amount; // Credit reduces due
          destinationUpdatedOutstanding -= amount;
        }
        final updatedDestinationLedgerCredit = destinationLedger.copyWith(
          totalOutstanding: destinationUpdatedOutstanding,
          currentDue: destinationUpdatedDue,
          currentPayable: null,
          transactions: [...?destinationLedger.transactions, creditTransaction],
        );
        await _accountLedgerService.updateLedger(ledgerId, updatedDestinationLedgerCredit);
        await _accountLedgerService.addTransaction(ledgerId, creditTransaction);

        // 2. Debit Destination (salary expense)
        final debitTransaction = AccountTransactionModel(
          amount: amount,
          type: 'Debit',
          billNumber: billNumber?.isNotEmpty == true ? billNumber : null,
          createdAt: DateTime.now(),
          receivedBy: loggedIn?.userId ?? '',
          purpose: purpose,
          typeOfPurpose: effectiveTypeOfPurpose,
          remarks: remarks?.isNotEmpty == true ? '  $remarks + (Salary Expense)' : 'Salary expense for $destinationName',
        );
        destinationUpdatedDue = destinationUpdatedDue + amount; // Debit increases due
        destinationUpdatedOutstanding = destinationUpdatedOutstanding + amount;
        final updatedDestinationLedgerDebit = updatedDestinationLedgerCredit.copyWith(
          totalOutstanding: destinationUpdatedOutstanding,
          currentDue: destinationUpdatedDue,
          currentPayable: null,
          transactions: [...?updatedDestinationLedgerCredit.transactions, debitTransaction],
        );
        await _accountLedgerService.updateLedger(ledgerId, updatedDestinationLedgerDebit);
        await _accountLedgerService.addTransaction(ledgerId, debitTransaction);

        // 3. Credit Source (money paid out)
        final sourceTransaction = AccountTransactionModel(
          amount: amount,
          type: 'Credit',
          billNumber: billNumber?.isNotEmpty == true ? billNumber : null,
          createdAt: DateTime.now(),
          receivedBy: loggedIn?.userId ?? '',
          purpose: purpose,
          typeOfPurpose: effectiveTypeOfPurpose,
          remarks: remarks?.isNotEmpty == true ? ' $remarks  (Salary Payment)' : 'Salary payment to $destinationName',
        );
        final sourceLedger = await _accountLedgerService.getLedger(sourceLedgerId);
        double sourceUpdatedDue = sourceLedger.currentDue ?? 0.0;
        double sourceUpdatedOutstanding = sourceLedger.totalOutstanding;
        sourceUpdatedDue -= amount; // Credit reduces due
        sourceUpdatedOutstanding -= amount;
        final updatedSourceLedger = sourceLedger.copyWith(
          totalOutstanding: sourceUpdatedOutstanding,
          currentDue: sourceUpdatedDue,
          currentPayable: null,
          transactions: [...?sourceLedger.transactions, sourceTransaction],
        );
        await _accountLedgerService.updateLedger(sourceLedgerId, updatedSourceLedger);
        await _accountLedgerService.addTransaction(sourceLedgerId, sourceTransaction);

        emit(const TransactionSuccess("Salary transaction added successfully"));
        await fetchLedger(ledgerId, userType);
      } else {
        // Expense or Regular Transaction
        final transaction = AccountTransactionModel(
          amount: amount,
          type: type,
          billNumber: billNumber?.isNotEmpty == true ? billNumber : null,
          createdAt: DateTime.now(),
          receivedBy: loggedIn?.userId ?? '',
          purpose: purpose,
          typeOfPurpose: effectiveTypeOfPurpose,
          remarks: remarks?.isNotEmpty == true
              ? remarks
              : isExpense
              ? 'Expense by $sourceName'
              : 'Transaction for $destinationName ($ledgerId)',
        );
        final currentLedger = await _accountLedgerService.getLedger(ledgerId);
        double updatedDue = currentLedger.currentDue ?? 0.0;
        double updatedOutstanding = currentLedger.totalOutstanding;
        if (updateBalance) {
          updatedDue += (type == "Debit" ? amount : -amount);
          updatedOutstanding += (type == "Debit" ? amount : -amount);
        }
        final updatedLedger = currentLedger.copyWith(
          totalOutstanding: updatedOutstanding,
          currentDue: updatedDue,
          currentPayable: null,
          transactions: [...?currentLedger.transactions, transaction],
        );
        await _accountLedgerService.updateLedger(ledgerId, updatedLedger);
        await _accountLedgerService.addTransaction(ledgerId, transaction);

        if (!isExpense) {
          // Source ledger transaction for non-expense
          final sourceTransaction = AccountTransactionModel(
            amount: amount,
            type: type == "Debit" ? "Credit" : "Debit",
            billNumber: billNumber?.isNotEmpty == true ? billNumber : null,
            createdAt: DateTime.now(),
            receivedBy: loggedIn?.userId ?? '',
            purpose: purpose ?? 'Transaction',
            typeOfPurpose: effectiveTypeOfPurpose,
            remarks: remarks?.isNotEmpty == true
                ? 'Corresponding ${type.toLowerCase()} for $destinationName ($ledgerId): $remarks'
                : 'Corresponding ${type.toLowerCase()} for $destinationName ($ledgerId) from $sourceName',
          );
          final sourceLedger = await _accountLedgerService.getLedger(sourceLedgerId);
          double sourceUpdatedDue = double.parse((sourceLedger.currentDue ?? 0.0).toStringAsFixed(2));
          double sourceUpdatedOutstanding = sourceLedger.totalOutstanding;
          sourceUpdatedDue += (sourceTransaction.type == "Debit" ? amount : -amount);
          sourceUpdatedOutstanding += (sourceTransaction.type == "Debit" ? amount : -amount);
          final updatedSourceLedger = sourceLedger.copyWith(
            totalOutstanding: sourceUpdatedOutstanding,
            currentDue: sourceUpdatedDue,
            currentPayable: null,
            transactions: [...?sourceLedger.transactions, sourceTransaction],
          );
          await _accountLedgerService.updateLedger(sourceLedgerId, updatedSourceLedger);
          await _accountLedgerService.addTransaction(sourceLedgerId, sourceTransaction);
        }

        emit(const TransactionSuccess("Transaction added successfully"));
        await fetchLedger(ledgerId, userType);
      }
    } catch (e) {
      emit(TransactionAddFailed("Failed to add transaction: $e"));
    }
  }
  Future<void> deleteTransaction(String ledgerId,
      AccountTransactionModel transaction, UserType? userType) async {
    emit(AccountLedgerPosting());
    try {
      final currentLedger = await _accountLedgerService.getLedger(ledgerId);
      double updatedDue = currentLedger.currentDue ?? 0.0;
      double updatedOutstanding = currentLedger.totalOutstanding;
      updatedDue -= (transaction.type == "Debit"
          ? transaction.amount
          : -transaction.amount);
      updatedOutstanding -= (transaction.type == "Debit"
          ? transaction.amount
          : -transaction.amount);
      final updatedLedger = currentLedger.copyWith(
        totalOutstanding: updatedOutstanding,
        currentDue: updatedDue,
        currentPayable: null,
        transactions: currentLedger.transactions
            ?.where((txn) => txn.transactionId != transaction.transactionId)
            .toList(),
      );
      await _accountLedgerService.updateLedger(ledgerId, updatedLedger);
      await _accountLedgerService.deleteTransaction(
          ledgerId, transaction.transactionId!);
      emit(const AccountLedgerSuccess("Transaction deleted successfully"));
      await fetchLedger(ledgerId, userType);
    } catch (e) {
      emit(AccountLedgerError("Failed to delete transaction: $e"));
    }
  }

  void updatePurposeSelection(String? purpose) {
    final currentState = state;
    if (currentState is TransactionPopupOpened) {
      final purposeTypeMap = currentState.purposeTypeMap;
      final newType =
      purpose != null && purposeTypeMap[purpose]?.isNotEmpty == true
          ? purposeTypeMap[purpose]!.first
          : null;
      emit(currentState.copyWith(
        selectedPurpose: purpose,
        selectedType: newType,
        isInitialOpen: false,
      ));
    }
  }

  void updateTypeSelection(String? type) {
    final currentState = state;
    if (currentState is TransactionPopupOpened) {
      emit(currentState.copyWith(
        selectedType: type,
        isInitialOpen: false,
      ));
    }
  }
}