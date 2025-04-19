import 'package:requirment_gathering_app/company_admin_module/data/ledger/account_ledger_model.dart';

abstract class AccountLedgerState {}

class AccountLedgerInitial extends AccountLedgerState {}

class AccountLedgerLoading extends AccountLedgerState {}

class AccountLedgerLoaded extends AccountLedgerState {
  final AccountLedger ledger;
  AccountLedgerLoaded(this.ledger);
}

class AccountLedgerError extends AccountLedgerState {
  final String message;
  AccountLedgerError(this.message);
}

class AccountLedgerSuccess extends AccountLedgerState {
  final String message;
  AccountLedgerSuccess(this.message);
}

class TransactionPopupOpened extends AccountLedgerState {
  final bool isDebit;
  final String companyType;
  final String? selectedPurpose;
  final String? selectedType;
  final Map<String, List<String>> purposeTypeMap;
  final String? errorMessage;
  final bool isInitialOpen; // New flag to mark initial popup open

  TransactionPopupOpened({
    required this.isDebit,
    required this.companyType,
    this.selectedPurpose,
    this.selectedType,
    required this.purposeTypeMap,
    this.errorMessage,
    required this.isInitialOpen,
  });

  TransactionPopupOpened copyWith({
    bool? isDebit,
    String? companyType,
    String? selectedPurpose,
    String? selectedType,
    Map<String, List<String>>? purposeTypeMap,
    String? errorMessage,
    bool? isInitialOpen,
  }) {
    return TransactionPopupOpened(
      isDebit: isDebit ?? this.isDebit,
      companyType: companyType ?? this.companyType,
      selectedPurpose: selectedPurpose,
      selectedType: selectedType,
      purposeTypeMap: purposeTypeMap ?? this.purposeTypeMap,
      errorMessage: errorMessage,
      isInitialOpen: isInitialOpen ?? this.isInitialOpen,
    );
  }
}

class TransactionAddSuccess extends AccountLedgerState {
  final String message;
  TransactionAddSuccess(this.message);
}

class TransactionAddFailed extends AccountLedgerState {
  final String message;
  TransactionAddFailed(this.message);
}