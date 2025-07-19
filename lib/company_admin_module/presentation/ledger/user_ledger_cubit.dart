import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:requirment_gathering_app/company_admin_module/data/ledger/account_ledger_model.dart';
import 'package:requirment_gathering_app/company_admin_module/data/ledger/account_transaction_model.dart';
import 'package:requirment_gathering_app/company_admin_module/presentation/ledger/account_ledger_state.dart';
import 'package:requirment_gathering_app/company_admin_module/service/account_ledger_service.dart';
import 'package:requirment_gathering_app/company_admin_module/service/user_services.dart';
import 'package:requirment_gathering_app/core_module/repository/account_repository.dart';
import 'package:requirment_gathering_app/super_admin_module/data/user_info.dart';
import 'package:requirment_gathering_app/super_admin_module/utils/user_type.dart';
import 'package:requirment_gathering_app/user_module/services/customer_company_service.dart';

class UserLedgerCubit extends Cubit<AccountLedgerState> {
  final IAccountLedgerService _accountLedgerService;
  final AccountRepository _accountRepository;
  final CustomerCompanyService _companyService; // Keep for getSettings
  final UserServices _userService; // New for updateUser

  UserLedgerCubit(this._accountLedgerService, this._accountRepository, this._companyService, this._userService)
      : super(AccountLedgerInitial());

  Future<void> ensureLedger(String? ledgerId, UserType? userType, UserInfo user) async {
    if (ledgerId == null || ledgerId.isEmpty) {
      emit(AccountLedgerFetching());
      try {
        // Validate user info
        if (user.userId == null || user.companyId == null) {
          emit(const AccountLedgerError("User ID or Company ID missing"));
          return;
        }

        // Create a new ledger
        final newLedger = AccountLedger(
          totalOutstanding: 0,
          promiseAmount: null,
          promiseDate: null,
          transactions: [],
          entityType: userType ?? UserType.Customer,
        );
        final newLedgerId = await _accountLedgerService.createLedger(newLedger);

        // Update UserInfo with new ledgerId
        final updatedUserInfo = user.copyWith(accountLedgerId: newLedgerId);
        await _userService.updateUser(updatedUserInfo);

        // Fetch the new ledger
        await fetchLedger(newLedgerId, userType);
      } catch (e) {
        emit(AccountLedgerError("Failed to create or update ledger: $e"));
        return;
      }
    } else {
      await fetchLedger(ledgerId, userType);
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
      final sortedTransactions = List<AccountTransactionModel>.from(ledger.transactions ?? [])
        ..sort((a, b) => b.createdAt!.compareTo(a.createdAt));
      emit(AccountLedgerUpdated(ledger.copyWith(transactions: sortedTransactions)));
    } catch (e) {
      emit(AccountLedgerError("Failed to fetch ledger: $e"));
    }
  }

  Future<void> openTransactionPopup(bool isDebit) async {
    try {
      final result = await _companyService.getSettings();
      final purposeTypeMap = result.fold<Map<String, List<String>>>(
            (error) => {'Material': [], 'Labor': []},
            (settings) {
          final map = settings.purposeTypeMap;
          if (map.isEmpty) return {'Material': [], 'Labor': []};
          final validatedMap = <String, List<String>>{};
          for (var entry in map.entries) {
            validatedMap[entry.key] = (entry.value).cast<String>();
          }
          return validatedMap.isNotEmpty ? validatedMap : {'Material': [], 'Labor': []};
        },
      );
      final defaultPurpose = purposeTypeMap.isNotEmpty ? purposeTypeMap.keys.first : null;
      final defaultType = defaultPurpose != null && purposeTypeMap[defaultPurpose]!.isNotEmpty
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
        purposeTypeMap: {'Material': [], 'Labor': []},
        selectedPurpose: null,
        selectedType: null,
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
        emit(const TransactionAddFailed("Remarks cannot exceed 500 characters"));
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

  Future<void> deleteTransaction(String ledgerId, AccountTransactionModel transaction, UserType? userType) async {
    emit(AccountLedgerPosting());
    try {
      final currentLedger = await _accountLedgerService.getLedger(ledgerId);
      double updatedDue = currentLedger.currentDue ?? 0.0;
      double updatedOutstanding = currentLedger.totalOutstanding;

      updatedDue -= (transaction.type == "Debit" ? transaction.amount : -transaction.amount);
      updatedOutstanding -= (transaction.type == "Debit" ? transaction.amount : -transaction.amount);

      final updatedLedger = currentLedger.copyWith(
        totalOutstanding: updatedOutstanding,
        currentDue: updatedDue,
        currentPayable: null,
        transactions: currentLedger.transactions?.where((txn) => txn.transactionId != transaction.transactionId).toList(),
      );
      await _accountLedgerService.updateLedger(ledgerId, updatedLedger);
      await _accountLedgerService.deleteTransaction(ledgerId, transaction.transactionId!);
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
      final newType = purpose != null && purposeTypeMap[purpose]?.isNotEmpty == true ? purposeTypeMap[purpose]!.first : null;
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