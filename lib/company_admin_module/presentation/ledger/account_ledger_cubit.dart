import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:requirment_gathering_app/company_admin_module/data/ledger/account_ledger_model.dart';
import 'package:requirment_gathering_app/company_admin_module/data/ledger/transaction_model.dart';
import 'package:requirment_gathering_app/company_admin_module/presentation/ledger/account_ledger_state.dart';
import 'package:requirment_gathering_app/company_admin_module/service/account_ledger_service.dart';
import 'package:requirment_gathering_app/core_module/repository/account_repository.dart';
import 'package:requirment_gathering_app/user_module/data/company.dart';

class AccountLedgerCubit extends Cubit<AccountLedgerState> {
  final IAccountLedgerService _accountLedgerService;
  final AccountRepository _accountRepository;

  AccountLedgerCubit(this._accountLedgerService, this._accountRepository)
      : super(AccountLedgerInitial());


  Future<void> fetchLedger(String? ledgerId) async {
    emit(AccountLedgerLoading());
    try {
      final ledger = await _accountLedgerService.getLedger(ledgerId ?? '');

      // ✅ Sort transactions by latest date first
      final sortedTransactions = List<TransactionModel>.from(ledger.transactions??[])
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt)); // 🔥 Sort by descending date

      // ✅ Create updated ledger with sorted transactions
      final updatedLedger = AccountLedger(
        ledgerId: ledger.ledgerId,
        totalOutstanding: ledger.totalOutstanding,
        promiseAmount: ledger.promiseAmount,
        promiseDate: ledger.promiseDate,
        transactions: sortedTransactions, // ✅ Latest first
      );

      emit(AccountLedgerLoaded(updatedLedger));
    } catch (e) {
      emit(AccountLedgerError(e.toString()));
    }
  }

  Future<void> addTransaction(String ledgerId, TransactionModel transaction) async {
    try {
      final loggedInInfo = await _accountRepository.getUserInfo();
      transaction = transaction.copyWith(receivedBy: loggedInInfo?.userId);

      // ✅ Fetch current ledger before adding transaction
      final AccountLedger currentLedger = await _accountLedgerService.getLedger(ledgerId);

      // ✅ Update totalOutstanding based on transaction type
      double updatedOutstanding = currentLedger.totalOutstanding;
      if (transaction.type == "Debit") {
        updatedOutstanding += transaction.amount; // Debit increases due
      } else {
        updatedOutstanding -= transaction.amount; // Credit decreases due
      }

      // ✅ Update ledger with new totalOutstanding
      final updatedLedger = AccountLedger(
        ledgerId: currentLedger.ledgerId,
        totalOutstanding: updatedOutstanding, // ✅ Updated totalOutstanding
        promiseAmount: currentLedger.promiseAmount,
        promiseDate: currentLedger.promiseDate,
        // transactions: [transaction, ...currentLedger.transactions], // ✅ Latest Transaction First
      );

      await _accountLedgerService.updateLedger(ledgerId, updatedLedger); // ✅ Save updated ledger

      await _accountLedgerService.addTransaction(ledgerId, transaction); // ✅ Add transaction to Firestore

      await fetchLedger(ledgerId); // ✅ Refresh ledger after transaction
    } catch (e) {
      emit(AccountLedgerError(e.toString()));
    }
  }

  /// 🔹 Create a new ledger
  Future<void> createLedger(Company company, double totalOutstanding,
      double? promiseAmount, DateTime? promiseDate) async {
    try {
      emit(AccountLedgerLoading());

      final newLedger = AccountLedger(
        totalOutstanding: totalOutstanding,
        promiseAmount: promiseAmount,
        promiseDate: promiseDate,
        transactions: [],
      );

      await _accountLedgerService.createLedger(company,newLedger);

      emit(AccountLedgerSuccess("Ledger created successfully!"));
    } catch (e) {
      emit(AccountLedgerError("Ledger creation failed: $e"));
    }
  }

  /// 🔥 **DELETE TRANSACTION**
  Future<void> deleteTransaction(String ledgerId,
      TransactionModel transaction) async {
    try {
      emit(AccountLedgerLoading()); // Show Loader while deleting

      // ✅ Firestore se transaction delete karna
      await _accountLedgerService.deleteTransaction(
          ledgerId, transaction.transactionId!);

      // ✅ Refresh ledger after deletion
      fetchLedger(ledgerId,);

      emit(AccountLedgerSuccess("Transaction deleted successfully!"));
    } catch (e) {
      emit(AccountLedgerError("Failed to delete transaction: $e"));
    }
  }
}
