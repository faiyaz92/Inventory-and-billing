import 'package:requirment_gathering_app/company_admin_module/data/inventory/stock_model.dart';
import 'package:requirment_gathering_app/company_admin_module/data/inventory/transaction_model.dart';
import 'package:requirment_gathering_app/company_admin_module/repositories/stock_repository.dart';
import 'package:requirment_gathering_app/company_admin_module/repositories/transaction_repository.dart';
import 'package:requirment_gathering_app/core_module/repository/account_repository.dart';

abstract class TransactionService {
  Future<List<TransactionModel>> getTransactions(String storeId);


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
  Future<List<TransactionModel>> getTransactions(String storeId) async {
    final userInfo = await accountRepository.getUserInfo();
    final transactionDtos = await transactionRepository.getTransactions(
        userInfo?.companyId ?? '', storeId);
    final allTransactions =
        transactionDtos.map((dto) => TransactionModel.fromDto(dto)).toList();

    print('Fetching transactions for storeId: $storeId');
    print('Total transactions before filtering: ${allTransactions.length}');

    // Filter transactions based on type and store relevance
    final filteredTransactions = allTransactions.where((transaction) {
      if (transaction.type == 'out' ||
          transaction.type == 'add' ||
          transaction.type == 'billing') {
        // Show 'out', 'add', and 'billing' transactions in the source store (fromStoreId)
        final isMatch = transaction.fromStoreId == storeId;
        print(
            'Transaction ID: ${transaction.id}, Type: ${transaction.type}, fromStoreId: ${transaction.fromStoreId}, toStoreId: ${transaction.toStoreId}, Matches: $isMatch');
        return isMatch;
      } else if (transaction.type == 'received') {
        // Show 'received' transactions in the target store (toStoreId)
        final isMatch = transaction.toStoreId == storeId;
        print(
            'Transaction ID: ${transaction.id}, Type: ${transaction.type}, fromStoreId: ${transaction.fromStoreId}, toStoreId: ${transaction.toStoreId}, Matches: $isMatch');
        return isMatch;
      }

      if (transaction.fromStoreId == storeId) {}
      print(
          'Transaction ID: ${transaction.id}, Type: ${transaction.type}, Skipped (unknown type)');
      return false;
    }).toList();

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
      userId: userId,
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
