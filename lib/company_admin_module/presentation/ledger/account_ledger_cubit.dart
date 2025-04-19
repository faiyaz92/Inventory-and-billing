import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:requirment_gathering_app/company_admin_module/data/ledger/account_ledger_model.dart';
import 'package:requirment_gathering_app/company_admin_module/data/ledger/transaction_model.dart';
import 'package:requirment_gathering_app/company_admin_module/presentation/ledger/account_ledger_state.dart';
import 'package:requirment_gathering_app/company_admin_module/service/account_ledger_service.dart';
import 'package:requirment_gathering_app/core_module/repository/account_repository.dart';
import 'package:requirment_gathering_app/user_module/data/partner.dart';
import 'package:requirment_gathering_app/user_module/services/customer_company_service.dart';

class AccountLedgerCubit extends Cubit<AccountLedgerState> {
  final IAccountLedgerService _accountLedgerService;
  final AccountRepository _accountRepository;
  final CustomerCompanyService _companyService;

  AccountLedgerCubit(this._accountLedgerService, this._accountRepository, this._companyService)
      : super(AccountLedgerInitial());

  Future<void> fetchLedger(String? ledgerId) async {
    emit(AccountLedgerLoading());
    try {
      final ledger = await _accountLedgerService.getLedger(ledgerId ?? '');
      final sortedTransactions = List<TransactionModel>.from(ledger.transactions ?? [])
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      final updatedLedger = AccountLedger(
        ledgerId: ledger.ledgerId,
        totalOutstanding: ledger.totalOutstanding,
        promiseAmount: ledger.promiseAmount,
        promiseDate: ledger.promiseDate,
        transactions: sortedTransactions,
      );
      emit(AccountLedgerLoaded(updatedLedger));
    } catch (e) {
      emit(AccountLedgerError(e.toString()));
    }
  }

  Future<void> openTransactionPopup(bool isDebit, String companyType) async {
    if (isDebit && companyType == "Site") {
      try {
        final result = await _companyService.getSettings();
        final purposeTypeMap = result.fold<Map<String, List<String>>>(
              (error) => {'Material': [], 'Labor': []},
              (settings) {
            final map = settings.purposeTypeMap;
            if (map.isEmpty) {
              return {'Material': [], 'Labor': []};
            }
            // Ensure map is Map<String, List<String>>
            final validatedMap = <String, List<String>>{};
            for (var entry in map.entries) {
              final valueList = (entry.value).cast<String>();
              validatedMap[entry.key] = valueList;
            }
            return validatedMap.isNotEmpty ? validatedMap : {'Material': [], 'Labor': []};
          },
        );
        final defaultPurpose = purposeTypeMap.keys.isNotEmpty ? purposeTypeMap.keys.first : null;
        final defaultType = defaultPurpose != null && purposeTypeMap[defaultPurpose]!.isNotEmpty
            ? purposeTypeMap[defaultPurpose]!.first
            : null;
        emit(TransactionPopupOpened(
          isDebit: isDebit,
          companyType: companyType,
          purposeTypeMap: purposeTypeMap,
          selectedPurpose: defaultPurpose,
          selectedType: defaultType,
          isInitialOpen: true, // Mark as initial open
        ));
      } catch (e) {
        emit(TransactionPopupOpened(
          isDebit: isDebit,
          companyType: companyType,
          purposeTypeMap: const {'Material': [], 'Labor': []},
          selectedPurpose: null,
          selectedType: null,
          errorMessage: "Failed to load purposes: $e",
          isInitialOpen: true, // Still initial open despite error
        ));
      }
    } else {
      emit(TransactionPopupOpened(
        isDebit: isDebit,
        companyType: companyType,
        purposeTypeMap: const {},
        selectedPurpose: null,
        selectedType: null,
        isInitialOpen: true, // Mark as initial open
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
  }) async {
    emit(AccountLedgerLoading());
    try {
      if (amount <= 0) {
        emit(TransactionAddFailed("Amount must be greater than 0"));
        return;
      }
      if (remarks != null && remarks.length > 500) {
        emit(TransactionAddFailed("Remarks cannot exceed 500 characters"));
        return;
      }
      final loggedInInfo = await _accountRepository.getUserInfo();
      final transaction = TransactionModel(
        amount: amount,
        type: type,
        billNumber: billNumber?.isEmpty ?? true ? null : billNumber,
        createdAt: DateTime.now(),
        receivedBy: loggedInInfo?.userId,
        purpose: purpose,
        typeOfPurpose: typeOfPurpose,
        remarks: remarks?.isEmpty ?? true ? null : remarks,
      );
      final currentLedger = await _accountLedgerService.getLedger(ledgerId);
      double updatedOutstanding = currentLedger.totalOutstanding;
      if (transaction.type == "Debit") {
        updatedOutstanding += transaction.amount;
      } else {
        updatedOutstanding -= transaction.amount;
      }
      final updatedLedger = AccountLedger(
        ledgerId: currentLedger.ledgerId,
        totalOutstanding: updatedOutstanding,
        promiseAmount: currentLedger.promiseAmount,
        promiseDate: currentLedger.promiseDate,
      );
      await _accountLedgerService.updateLedger(ledgerId, updatedLedger);
      await _accountLedgerService.addTransaction(ledgerId, transaction);
      emit(TransactionAddSuccess("Transaction added successfully"));
      await fetchLedger(ledgerId);
    } catch (e) {
      emit(TransactionAddFailed("Failed to add transaction: $e"));
    }
  }

  Future<void> createLedger(Partner company, double totalOutstanding, double? promiseAmount, DateTime? promiseDate) async {
    emit(AccountLedgerLoading());
    try {
      final newLedger = AccountLedger(
        totalOutstanding: totalOutstanding,
        promiseAmount: promiseAmount,
        promiseDate: promiseDate,
        transactions: [],
      );
      await _accountLedgerService.createLedger(company, newLedger);
      emit(AccountLedgerSuccess("Ledger created successfully!"));
    } catch (e) {
      emit(AccountLedgerError("Ledger creation failed: $e"));
    }
  }

  Future<void> deleteTransaction(String ledgerId, TransactionModel transaction) async {
    emit(AccountLedgerLoading());
    try {
      await _accountLedgerService.deleteTransaction(ledgerId, transaction.transactionId!);
      emit(AccountLedgerSuccess("Transaction deleted successfully!"));
      await fetchLedger(ledgerId);
    } catch (e) {
      emit(AccountLedgerError("Failed to delete transaction: $e"));
    }
  }

  void updatePurposeSelection(String? purpose) {
    final currentState = state;
    if (currentState is TransactionPopupOpened) {
      final purposeTypeMap = currentState.purposeTypeMap;
      final newType = purpose != null && purposeTypeMap[purpose]!.isNotEmpty ? purposeTypeMap[purpose]!.first : null;
      emit(currentState.copyWith(
        selectedPurpose: purpose,
        selectedType: newType,
        isInitialOpen: false, // Not initial open
      ));
    }
  }

  void updateTypeSelection(String? type) {
    final currentState = state;
    if (currentState is TransactionPopupOpened) {
      emit(currentState.copyWith(
        selectedType: type,
        isInitialOpen: false,
        selectedPurpose: currentState.selectedPurpose,
        purposeTypeMap: currentState.purposeTypeMap,
      ));
    }
  }
}