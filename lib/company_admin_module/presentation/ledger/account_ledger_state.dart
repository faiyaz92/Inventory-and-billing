// File: company_admin_module/data/ledger/account_ledger_state.dart
// Update AccountLedgerState to align with UserLedgerCubit
import 'package:equatable/equatable.dart';
import 'package:requirment_gathering_app/company_admin_module/data/ledger/account_ledger_model.dart';
import 'package:requirment_gathering_app/company_admin_module/data/ledger/account_transaction_model.dart';

abstract class AccountLedgerState extends Equatable {
  const AccountLedgerState();

  @override
  List<Object?> get props => [];
}

class AccountLedgerInitial extends AccountLedgerState {}

class AccountLedgerLoading extends AccountLedgerState {}

class AccountLedgerFetching extends AccountLedgerState {}

class AccountLedgerPosting extends AccountLedgerState {}

class AccountLedgerLoaded extends AccountLedgerState {
  final AccountLedger ledger;

  const AccountLedgerLoaded(this.ledger);

  @override
  List<Object?> get props => [ledger];
}

class AccountLedgerUpdated extends AccountLedgerState {
  final AccountLedger ledger;

  const AccountLedgerUpdated(this.ledger);

  @override
  List<Object?> get props => [ledger];
}

class AccountLedgerSuccess extends AccountLedgerState {
  final String message;

  const AccountLedgerSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class AccountLedgerError extends AccountLedgerState {
  final String message;

  const AccountLedgerError(this.message);

  @override
  List<Object?> get props => [message];
}

class TransactionPopupOpened extends AccountLedgerState {
  final bool isDebit;
  final String? companyType;
  final Map<String, List<String>> purposeTypeMap;
  final String? selectedPurpose;
  final String? selectedType;
  final bool isInitialOpen;
  final String? errorMessage;

  const TransactionPopupOpened({
    required this.isDebit,
    this.companyType,
    required this.purposeTypeMap,
    this.selectedPurpose,
    this.selectedType,
    this.isInitialOpen = false,
    this.errorMessage,
  });

  TransactionPopupOpened copyWith({
    bool? isDebit,
    String? companyType,
    Map<String, List<String>>? purposeTypeMap,
    String? selectedPurpose,
    String? selectedType,
    bool? isInitialOpen,
    String? errorMessage,
  }) {
    return TransactionPopupOpened(
      isDebit: isDebit ?? this.isDebit,
      companyType: companyType ?? this.companyType,
      purposeTypeMap: purposeTypeMap ?? this.purposeTypeMap,
      selectedPurpose: selectedPurpose ?? this.selectedPurpose,
      selectedType: selectedType ?? this.selectedType,
      isInitialOpen: isInitialOpen ?? this.isInitialOpen,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    isDebit,
    companyType,
    purposeTypeMap,
    selectedPurpose,
    selectedType,
    isInitialOpen,
    errorMessage,
  ];
}

class TransactionSuccess extends AccountLedgerState {
  final String message;

  const TransactionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class TransactionAddFailed extends AccountLedgerState {
  final String message;

  const TransactionAddFailed(this.message);

  @override
  List<Object?> get props => [message];
}