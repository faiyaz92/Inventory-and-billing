import 'package:requirment_gathering_app/company_admin_module/data/inventory/stock_model.dart';
import 'package:requirment_gathering_app/company_admin_module/data/inventory/transaction_model.dart';
import 'package:requirment_gathering_app/company_admin_module/repositories/stock_repository.dart';
import 'package:requirment_gathering_app/company_admin_module/repositories/transaction_repository.dart';
import 'package:requirment_gathering_app/core_module/repository/account_repository.dart';

abstract class TransactionService {
  Future<List<TransactionModel>> getTransactions(
      String storeId, {
        String? type,
        String? fromStoreId,
        String? toStoreId,
        String? userId,
        String? customerId,
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
        String? type,
        String? fromStoreId,
        String? toStoreId,
        String? userId,
        String? customerId,
        required int page,
        required int pageSize,
      }) async {
    final userInfo = await accountRepository.getUserInfo();
    final companyId = userInfo?.companyId ?? '';

    print('Fetching transactions for storeId: $storeId, type: $type, '
        'fromStoreId: $fromStoreId, toStoreId: $toStoreId, userId: $userId, '
        'customerId: $customerId, page: $page, pageSize: $pageSize');

    // Fetch all transactions for the store
    final transactionDtos = await transactionRepository.getTransactions(
      companyId,
      storeId,
      page: page,
      pageSize: pageSize,
    );

    final allTransactions = transactionDtos.map((dto) => TransactionModel.fromDto(dto)).toList();
    print('Retrieved ${allTransactions.length} transactions before filtering: '
        '${allTransactions.map((t) => "${t.id} (${t.type})").toList()}');

    // Filter transactions
    final filteredTransactions = allTransactions.where((transaction) {
      bool isTypeMatch = type == null || transaction.type.toLowerCase() == type.toLowerCase();
      bool isStoreMatch = transaction.type == 'received'
          ? transaction.toStoreId == storeId
          : transaction.fromStoreId == storeId;
      bool isFromStoreMatch = fromStoreId == null || transaction.fromStoreId == fromStoreId;
      bool isToStoreMatch = toStoreId == null || transaction.toStoreId == toStoreId;
      bool isUserMatch = userId == null || transaction.userId == userId;
      bool isCustomerMatch = customerId == null || transaction.customerId == customerId;

      if (!isTypeMatch || !isStoreMatch || !isFromStoreMatch || !isToStoreMatch || !isUserMatch || !isCustomerMatch) {
        print('Filtered out transaction ${transaction.id}: type=${transaction.type}, '
            'fromStoreId=${transaction.fromStoreId}, toStoreId=${transaction.toStoreId}, '
            'userId=${transaction.userId}, customerId=${transaction.customerId}, '
            'isTypeMatch=$isTypeMatch, isStoreMatch=$isStoreMatch, '
            'isFromStoreMatch=$isFromStoreMatch, isToStoreMatch=$isToStoreMatch, '
            'isUserMatch=$isUserMatch, isCustomerMatch=$isCustomerMatch');
      }

      return isTypeMatch && isStoreMatch && isFromStoreMatch && isToStoreMatch && isUserMatch && isCustomerMatch;
    }).toList();

    print('Total transactions after filtering: ${filteredTransactions.length}, '
        'types: ${filteredTransactions.map((t) => t.type).toSet()}');

    // Sort by timestamp descending
    filteredTransactions.sort((a, b) => b.timestamp.compareTo(a.timestamp));

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
      companyId,
      transaction.fromStoreId,
      transaction.productId,
    );
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
      userId: userId,
      productName: transaction.productName,
      remarks: transaction.remarks,
    );
    await transactionRepository.addTransaction(companyId, billingTransaction.toDto());
  }

  @override
  Future<void> addTransaction(TransactionModel transaction) async {
    final userInfo = await accountRepository.getUserInfo();
    final companyId = userInfo?.companyId ?? '';
    await transactionRepository.addTransaction(companyId, transaction.toDto());
  }
}