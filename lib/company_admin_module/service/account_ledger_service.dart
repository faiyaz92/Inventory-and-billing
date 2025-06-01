import 'package:requirment_gathering_app/company_admin_module/data/ledger/account_ledger_model.dart';
import 'package:requirment_gathering_app/company_admin_module/data/ledger/transaction_model.dart';
import 'package:requirment_gathering_app/company_admin_module/repositories/account_ledger_repository.dart';
import 'package:requirment_gathering_app/core_module/repository/account_repository.dart';

abstract class IAccountLedgerService {
  Future<String> createLedger(AccountLedger ledger); // Modified to return ledgerId
  Future<AccountLedger> getLedger(String ledgerId);
  Future<void> updateLedger(String ledgerId, AccountLedger ledger);
  Future<void> addTransaction(String ledgerId, TransactionModel transaction);
  Future<void> deleteTransaction(String ledgerId, String transactionId);
}


class AccountLedgerServiceImpl implements IAccountLedgerService {
  final IAccountLedgerRepository _accountLedgerRepository;
  final AccountRepository _accountRepository;

  AccountLedgerServiceImpl(this._accountLedgerRepository, this._accountRepository,);

  @override
  Future<String> createLedger(AccountLedger ledger) async {
    final loggedIn = await _accountRepository.getUserInfo();
    final ledgerDto = ledger.toDto();
    final ledgerId = await _accountLedgerRepository.createAccountLedger(
        loggedIn?.companyId ?? '', ledgerDto);
    return ledgerId; // Return ledgerId
  }

  @override
  Future<AccountLedger> getLedger(String ledgerId) async {
    final loggedIn = await _accountRepository.getUserInfo();
    final dto = await _accountLedgerRepository.getAccountLedger(
        loggedIn?.companyId ?? '', ledgerId);
    return AccountLedger.fromDto(dto);
  }

  @override
  Future<void> addTransaction(String ledgerId, TransactionModel transaction) async {
    final loggedIn = await _accountRepository.getUserInfo();
    await _accountLedgerRepository.addTransaction(
        loggedIn?.companyId ?? '', ledgerId, transaction.toDto());
  }

  @override
  Future<void> deleteTransaction(String ledgerId, String transactionId) async {
    final loggedIn = await _accountRepository.getUserInfo();
    await _accountLedgerRepository.deleteTransaction(
        loggedIn?.companyId ?? '', ledgerId, transactionId);
  }

  @override
  Future<void> updateLedger(String ledgerId, AccountLedger updatedLedger) async {
    final loggedIn = await _accountRepository.getUserInfo();
    print("🔥 Updating Ledger ID: $ledgerId with New Outstanding: ${updatedLedger.totalOutstanding}");
    await _accountLedgerRepository.updateAccountLedger(
        loggedIn?.companyId ?? '', ledgerId, updatedLedger.toDto());
    print("✅ Ledger Updated Successfully");
  }
}
