import 'package:requirment_gathering_app/company_admin_module/data/inventory/stock_model.dart';
import 'package:requirment_gathering_app/company_admin_module/data/inventory/transaction_model.dart';
import 'package:requirment_gathering_app/company_admin_module/repositories/stock_repository.dart';
import 'package:requirment_gathering_app/company_admin_module/repositories/transaction_repository.dart';
import 'package:requirment_gathering_app/core_module/repository/account_repository.dart';

abstract class TransactionService {
  Future<List<TransactionModel>> getTransactions(
      String storeId, {
        String? userId,
        String? fromStoreId,
        String? toStoreId,
        DateTime? startDate,
        DateTime? endDate,
        required int page,
        required int pageSize,
      });

  Future<void> createBilling(TransactionModel transaction);

  Future<void> addTransaction(TransactionModel transaction);
}

class TransactionServiceImpl implements TransactionService {
  final TransactionRepository transactionRepository;
  final StockRepository stockRepository;
  final AccountRepository accountRepository;

  TransactionServiceImpl({
    required this.transactionRepository,
    required this.stockRepository,
    required this.accountRepository,
  });

  @override
  Future<List<TransactionModel>> getTransactions(
      String storeId, {
        String? userId,
        String? fromStoreId,
        String? toStoreId,
        DateTime? startDate,
        DateTime? endDate,
        required int page,
        required int pageSize,
      }) async {
    final userInfo = await accountRepository.getUserInfo();
    final companyId = userInfo?.companyId ?? '';

    // Fetch transactions with pagination
    final transactionDtos = await transactionRepository.getTransactions(
      companyId,
      storeId,
      userId: userId,
      fromStoreId: fromStoreId,
      toStoreId: toStoreId,
      startDate: startDate,
      endDate: endDate,
      page: page,
      pageSize: pageSize,
    );

    final allTransactions = transactionDtos.map((dto) => TransactionModel.fromDto(dto)).toList();
    // Apply existing type-based filtering
    final filteredTransactions = allTransactions.where((transaction) {
      bool isMatch = false;
      if (transaction.type == 'out' ||
          transaction.type == 'add' ||
          transaction.type == 'billing') {
        isMatch = transaction.fromStoreId == storeId;
      } else if (transaction.type == 'received') {
        isMatch = transaction.toStoreId == storeId;
      }

      // Apply additional filters
      if (userId != null && transaction.userId != userId) {
        isMatch = false;
      }
      if (fromStoreId != null && transaction.fromStoreId != fromStoreId) {
        isMatch = false;
      }
      if (toStoreId != null && transaction.toStoreId != toStoreId) {
        isMatch = false;
      }
      if (startDate != null && transaction.timestamp.isBefore(startDate)) {
        isMatch = false;
      }
      if (endDate != null && transaction.timestamp.isAfter(endDate)) {
        isMatch = false;
      }
      return isMatch;
    }).toList();

    // Sort by timestamp descending
    filteredTransactions.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    print('Total transactions after filtering: ${filteredTransactions.length}');
    return filteredTransactions;
  }

  @override
  Future<void> createBilling(TransactionModel transaction) async {
    final userInfo = await accountRepository.getUserInfo();
    final companyId = userInfo?.companyId ?? '';
    final userName = userInfo?.userName ?? 'Unknown User';
    final userId = userInfo?.userId ?? 'unknown';

    // Reduce stock
    final stock = await stockRepository.getStockByProduct(
        companyId, transaction.fromStoreId, transaction.productId);
    if (stock == null || stock.quantity < transaction.quantity) {
      throw Exception('Insufficient stock for billing');
    }
    final updatedStock = StockModel(
      id: stock.id,
      productId: stock.productId,
      storeId: stock.storeId,
      quantity: stock.quantity - transaction.quantity,
      lastUpdated: DateTime.now(),
    );
    await stockRepository.updateStock(companyId, updatedStock.toDto());

    // Record transaction with userName and userId
    final billingTransaction = TransactionModel(
      id: transaction.id,
      type: transaction.type,
      productId: transaction.productId,
      quantity: transaction.quantity,
      fromStoreId: transaction.fromStoreId,
      toStoreId: null,
      customerId: transaction.customerId,
      timestamp: transaction.timestamp,
      userName: userName,
      userId: userId, productName: transaction.productName,
    );
    await transactionRepository.addTransaction(
        companyId, billingTransaction.toDto());
  }

  @override
  Future<void> addTransaction(TransactionModel transaction) async {
    final userInfo = await accountRepository.getUserInfo();
    final companyId = userInfo?.companyId ?? '';
    await transactionRepository.addTransaction(companyId, transaction.toDto());
  }
}