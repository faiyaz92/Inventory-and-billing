import 'package:requirment_gathering_app/company_admin_module/data/account_ledger_model.dart';
import 'package:requirment_gathering_app/company_admin_module/data/transaction_model.dart';
import 'package:requirment_gathering_app/company_admin_module/repositories/account_ledger_repository.dart';

abstract class IAccountLedgerService {
  Future<AccountLedger> getLedger(String companyId, String customerCompanyId);

  Future<void> addTransaction(
      String companyId, String customerCompanyId, TransactionModel transaction);
  Future<void> createLedger(String companyId, String customerCompanyId, AccountLedger ledger);
}

class AccountLedgerServiceImpl implements IAccountLedgerService {
  final IAccountLedgerRepository _accountLedgerRepository;

  AccountLedgerServiceImpl(this._accountLedgerRepository);

  @override
  Future<AccountLedger> getLedger(
      String companyId, String customerCompanyId) async {
    final dto =
        await _accountLedgerRepository.getAccountLedger(companyId, customerCompanyId);
    return AccountLedger.fromDto(dto);
  }

  @override
  Future<void> addTransaction(String companyId, String customerCompanyId,
      TransactionModel transaction) async {
    await _accountLedgerRepository.addTransaction(
        companyId, customerCompanyId, transaction.toDto());
  }

  @override
  Future<void> createLedger(String companyId, String customerCompanyId, AccountLedger ledger) async {
    final ledgerDto = ledger.toDto();
    await _accountLedgerRepository.createAccountLedger(companyId, ledgerDto);
  }
}
