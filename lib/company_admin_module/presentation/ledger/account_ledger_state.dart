import 'package:equatable/equatable.dart';
import 'package:requirment_gathering_app/company_admin_module/data/account_ledger_model.dart';

abstract class AccountLedgerState extends Equatable{}

class AccountLedgerInitial extends AccountLedgerState {
  @override
  // TODO: implement props
  List<Object?> get props => throw UnimplementedError();
}

class AccountLedgerLoading extends AccountLedgerState {
  @override
  // TODO: implement props
  List<Object?> get props => throw UnimplementedError();
}

class AccountLedgerLoaded extends AccountLedgerState {
  final AccountLedger ledger;
  AccountLedgerLoaded(this.ledger);

  @override
  // TODO: implement props
  List<Object?> get props => throw UnimplementedError();
}

class AccountLedgerError extends AccountLedgerState {
  final String message;
  AccountLedgerError(this.message);

  @override
  // TODO: implement props
  List<Object?> get props => throw UnimplementedError();
}
/// ✅ Success state for Ledger Creation
class AccountLedgerSuccess extends AccountLedgerState {
  final String message;

   AccountLedgerSuccess(this.message);

  @override
  List<Object?> get props => [message];
}
