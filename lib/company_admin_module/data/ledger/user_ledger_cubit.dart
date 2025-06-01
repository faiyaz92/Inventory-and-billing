// File: company_admin_module/presentation/ledger/user_ledger_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:requirment_gathering_app/company_admin_module/data/ledger/account_ledger_model.dart';
import 'package:requirment_gathering_app/company_admin_module/data/ledger/transaction_model.dart';
import 'package:requirment_gathering_app/company_admin_module/presentation/ledger/account_ledger_state.dart';
import 'package:requirment_gathering_app/company_admin_module/service/account_ledger_service.dart';
import 'package:requirment_gathering_app/core_module/repository/account_repository.dart';
import 'package:requirment_gathering_app/super_admin_module/data/user_info.dart';
import 'package:requirment_gathering_app/super_admin_module/utils/user_type.dart';
import 'package:requirment_gathering_app/user_module/services/customer_company_service.dart';

class UserLedgerCubit extends Cubit<AccountLedgerState> {
  final IAccountLedgerService _accountLedgerService;
  final AccountRepository _accountRepository;
  final CustomerCompanyService _companyService;

  UserLedgerCubit(this._accountLedgerService, this._accountRepository, this._companyService)
      : super(AccountLedgerInitial());

  Future<void> fetchLedger(String? ledgerId, UserType? userType) async {
    if (ledgerId == null || ledgerId.isEmpty) {
      emit(const AccountLedgerError("Invalid ledger ID"));
      return;
    }
    emit(AccountLedgerFetching());
    try {
      final ledger = await _accountLedgerService.getLedger(ledgerId);
      final sortedTransactions = List<TransactionModel>.from(ledger.transactions ?? [])
        ..sort((a, b) => b.createdAt!.compareTo(a.createdAt));
      emit(AccountLedgerUpdated(ledger.copyWith(transactions: sortedTransactions)));
    } catch (e) {
      emit(AccountLedgerError("Failed to fetch ledger: $e"));
    }
  }

  Future<void> openTransactionPopup(bool isDebit, String? userTypeName) async {
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
        companyType: userTypeName,
        purposeTypeMap: purposeTypeMap,
        selectedPurpose: defaultPurpose,
        selectedType: defaultType,
        isInitialOpen: true,
      ));
    } catch (e) {
      emit(TransactionPopupOpened(
        isDebit: isDebit,
        companyType: userTypeName,
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
      final transaction = TransactionModel(
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
      double updatedPayable = currentLedger.currentPayable ?? 0.0;
      double updatedOutstanding = currentLedger.totalOutstanding;

      if (userType == UserType.Customer || userType == null) {
        updatedDue += (type == "Debit" ? amount : -amount);
        if (updatedDue < 0) updatedDue = 0;
        updatedOutstanding += (type == "Debit" ? amount : -amount);
      } else {
        updatedPayable += (type == "Credit" ? amount : -amount);
        if (updatedPayable < 0) updatedPayable = 0;
        updatedOutstanding += (type == "Credit" ? amount : -amount);
      }

      final updatedLedger = currentLedger.copyWith(
        totalOutstanding: updatedOutstanding,
        currentDue: userType == UserType.Customer || userType == null ? updatedDue : null,
        currentPayable: userType != null && userType != UserType.Customer ? updatedPayable : null,
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

  Future<void> createLedger(UserInfo user, {double totalOutstanding = 0.0, double? promiseAmount, DateTime? promiseDate}) async {
    emit(AccountLedgerPosting());
    try {
      final newLedger = AccountLedger(
        entityType: 'User',
        totalOutstanding: totalOutstanding,
        currentDue: user.userType == UserType.Customer || user.userType == null ? totalOutstanding : null,
        currentPayable: user.userType != null && user.userType != UserType.Customer ? totalOutstanding : null,
        promiseAmount: promiseAmount,
        promiseDate: promiseDate,
        transactions: [],
      );
      final ledgerId = await _accountLedgerService.createLedger(newLedger);
      final updatedUser = user.copyWith(accountLedgerId: ledgerId);
      // await _accountRepository.updateUserInfo(updatedUser.toDto());
      emit(const AccountLedgerSuccess("Ledger created successfully"));
    } catch (e) {
      emit(AccountLedgerError("Ledger creation failed: $e"));
    }
  }

  Future<void> deleteTransaction(String ledgerId, TransactionModel transaction, UserType? userType) async {
    emit(AccountLedgerPosting());
    try {
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