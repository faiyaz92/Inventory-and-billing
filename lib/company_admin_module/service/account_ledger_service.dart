import 'package:requirment_gathering_app/company_admin_module/data/ledger/account_ledger_model.dart';
import 'package:requirment_gathering_app/company_admin_module/data/ledger/transaction_model.dart';
import 'package:requirment_gathering_app/company_admin_module/repositories/account_ledger_repository.dart';
import 'package:requirment_gathering_app/core_module/repository/account_repository.dart';
import 'package:requirment_gathering_app/user_module/data/partner.dart';
import 'package:requirment_gathering_app/user_module/services/customer_company_service.dart';

abstract class IAccountLedgerService {
  Future<AccountLedger> getLedger(String ledgerId);

  Future<void> addTransaction(String ledgerId, TransactionModel transaction);

  Future<void> createLedger(Partner company, AccountLedger ledger);

  Future<void> deleteTransaction(String ledgerId, String transactionId);
  Future<void> updateLedger(String ledgerId, AccountLedger updatedLedger); // ✅ New Method

}

class AccountLedgerServiceImpl implements IAccountLedgerService {
  final IAccountLedgerRepository _accountLedgerRepository;
  final AccountRepository _accountRepository;
  final CustomerCompanyService _companyService;

  AccountLedgerServiceImpl(this._accountLedgerRepository,
      this._accountRepository, this._companyService);

  @override
  Future<AccountLedger> getLedger(String ledgerId) async {
    final loggedIn = await _accountRepository.getUserInfo();

    final dto = await _accountLedgerRepository.getAccountLedger(
        loggedIn?.companyId ?? '', ledgerId);
    return AccountLedger.fromDto(dto);
  }

  @override
  Future<void> addTransaction(
      String ledgerId, TransactionModel transaction) async {
    final loggedIn = await _accountRepository.getUserInfo();
    await _accountLedgerRepository.addTransaction(
        loggedIn?.companyId ?? '', ledgerId, transaction.toDto());
  }

  @override
  Future<void> createLedger(Partner company, AccountLedger ledger) async {
    final ledgerDto = ledger.toDto();
    final loggedIn = await _accountRepository.getUserInfo();
    final ledgerId = await _accountLedgerRepository.createAccountLedger(
        loggedIn?.companyId ?? '', ledgerDto);
    company = company.copyWith(accountLedgerId: ledgerId);
    await _companyService.updateCompany(company.id, company);
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
        loggedIn?.companyId??'',ledgerId, updatedLedger.toDto());

    print("✅ Ledger Updated Successfully");
  }
}
