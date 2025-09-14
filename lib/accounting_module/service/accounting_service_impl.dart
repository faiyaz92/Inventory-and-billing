import 'package:requirment_gathering_app/accounting_module/data/TransactionModel.dart';
import 'package:requirment_gathering_app/accounting_module/repositories/accounting_repositories.dart';
import 'package:requirment_gathering_app/accounting_module/service/accounting_service.dart';
import 'package:requirment_gathering_app/core_module/repository/account_repository.dart';

class AccountingServiceImpl implements AccountingService {
  final AccountingRepository _accountingRepository;
  final AccountRepository _accountRepository;

  AccountingServiceImpl(this._accountingRepository, this._accountRepository);

  @override
  Future<void> initFirm(String firmId, String firmName) async {
    final userInfo = await _accountRepository.getUserInfo();
    if (userInfo == null || userInfo.companyId == null) {
      throw Exception("User not associated with any company.");
    }
    await _accountingRepository.initFirm(firmId, firmName);
  }

  @override
  Future<void> createStore(String firmId, String storeId, String storeName) async {
    final userInfo = await _accountRepository.getUserInfo();
    if (userInfo == null || userInfo.companyId == null) {
      throw Exception("User not associated with any company.");
    }
    await _accountingRepository.createStore(firmId, storeId, storeName);
  }

  @override
  Future<void> createPersonalAccount(String firmId, String name, String? storeId, String type) async {
    final userInfo = await _accountRepository.getUserInfo();
    if (userInfo == null || userInfo.companyId == null) {
      throw Exception("User not associated with any company.");
    }
    await _accountingRepository.createPersonalAccount(firmId, name, storeId, type);
  }

  @override
  Future<void> addEntry(String firmId, TransactionModel transaction) async {
    final userInfo = await _accountRepository.getUserInfo();
    if (userInfo == null || userInfo.companyId == null) {
      throw Exception("User not associated with any company.");
    }
    final transactionDto = transaction.toDto();
    await _accountingRepository.addEntry(firmId, transactionDto);
  }

  @override
  Future<Map<String, dynamic>> getBalanceSheet(String firmId, DateTime start, DateTime end) async {
    final userInfo = await _accountRepository.getUserInfo();
    if (userInfo == null || userInfo.companyId == null) {
      throw Exception("User not associated with any company.");
    }
    return await _accountingRepository.getBalanceSheet(firmId, start, end);
  }

  @override
  Future<Map<String, dynamic>> getIncomeStatement(String firmId, DateTime start, DateTime end) async {
    final userInfo = await _accountRepository.getUserInfo();
    if (userInfo == null || userInfo.companyId == null) {
      throw Exception("User not associated with any company.");
    }
    return await _accountingRepository.getIncomeStatement(firmId, start, end);
  }

  @override
  Future<List<Map<String, dynamic>>> getStock(String firmId) async {
    final userInfo = await _accountRepository.getUserInfo();
    if (userInfo == null || userInfo.companyId == null) {
      throw Exception("User not associated with any company.");
    }
    return await _accountingRepository.getStock(firmId);
  }

  @override
  Future<Map<String, dynamic>> getStockOfStore(String firmId, String storeId) async {
    final userInfo = await _accountRepository.getUserInfo();
    if (userInfo == null || userInfo.companyId == null) {
      throw Exception("User not associated with any company.");
    }
    return await _accountingRepository.getStockOfStore(firmId, storeId);
  }

  @override
  Future<Map<String, dynamic>> getAccountBalance(String firmId, String accountId, DateTime start, DateTime end) async {
    final userInfo = await _accountRepository.getUserInfo();
    if (userInfo == null || userInfo.companyId == null) {
      throw Exception("User not associated with any company.");
    }
    return await _accountingRepository.getAccountBalance(firmId, accountId, start, end);
  }
}