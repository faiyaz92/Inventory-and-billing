import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:requirment_gathering_app/company_admin_module/data/account_ledger_model.dart';
import 'package:requirment_gathering_app/company_admin_module/data/transaction_model.dart';
import 'package:requirment_gathering_app/company_admin_module/presentation/account_ledger_state.dart';
import 'package:requirment_gathering_app/company_admin_module/service/account_ledger_service.dart';

class AccountLedgerCubit extends Cubit<AccountLedgerState> {
  final IAccountLedgerService _accountLedgerService;

  AccountLedgerCubit(this._accountLedgerService)
      : super(AccountLedgerInitial());

  Future<void> fetchLedger(String companyId, String customerCompanyId) async {
    emit(AccountLedgerLoading());
    try {
      final ledger =
          await _accountLedgerService.getLedger(companyId, customerCompanyId);
      emit(AccountLedgerLoaded(ledger));
    } catch (e) {
      emit(AccountLedgerError(e.toString()));
    }
  }

  Future<void> addTransaction(String companyId, String customerCompanyId,
      TransactionModel transaction) async {
    try {
      await _accountLedgerService.addTransaction(
          companyId, customerCompanyId, transaction);
      fetchLedger(
          companyId, customerCompanyId); // Refresh ledger after transaction
    } catch (e) {
      emit(AccountLedgerError(e.toString()));
    }
  }

  /// 🔹 Create a new ledger
  Future<void> createLedger(
      String companyId,
      String customerCompanyId,
      double totalOutstanding,
      double? promiseAmount,
      DateTime? promiseDate) async {
    try {
      emit(AccountLedgerLoading());

      final newLedger = AccountLedger(
        totalOutstanding: totalOutstanding,
        promiseAmount: promiseAmount,
        promiseDate: promiseDate,
        transactions: [],
      );

      await _accountLedgerService.createLedger(
          companyId, customerCompanyId, newLedger);

      emit(AccountLedgerSuccess("Ledger created successfully!"));
    } catch (e) {
      emit(AccountLedgerError("Ledger creation failed: $e"));
    }
  }
}
