import 'package:requirment_gathering_app/accounting_module/data/TransactionModel.dart';

abstract class AccountingService {
  Future<void> initFirm(String firmId, String firmName);
  Future<void> createStore(String firmId, String storeId, String storeName);
  Future<void> createPersonalAccount(String firmId, String name, String? storeId, String type);
  Future<void> addEntry(String firmId, TransactionModel transaction);
  Future<Map<String, dynamic>> getBalanceSheet(String firmId, DateTime start, DateTime end);
  Future<Map<String, dynamic>> getIncomeStatement(String firmId, DateTime start, DateTime end);
  Future<List<Map<String, dynamic>>> getStock(String firmId);
  Future<Map<String, dynamic>> getStockOfStore(String firmId, String storeId);
  Future<Map<String, dynamic>> getAccountBalance(String firmId, String accountId, DateTime start, DateTime end);
}